import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../common/styles/colors.dart';
import '../../../common/themes/text_theme.dart';
import '../../../presentation/managers/catalog_manager.dart';
import '../../../features/home/models/product_model.dart';
import '../../../utils/device/screen_util.dart';
import '../../../utils/helpers/hex_image.dart';

class AddEditProductScreen extends StatefulWidget {
  final ProductModel? product; // Если null - добавление, иначе - редактирование

  const AddEditProductScreen({Key? key, this.product}) : super(key: key);

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _catalogManager = Get.find<CatalogManager>();
  final _imagePicker = ImagePicker();
  bool _isLoading = false;
  String? _selectedImagePath;
  XFile? _pickedImageFile; // Файл изображения из галереи

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      // Заполняем поля при редактировании
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description;
      _priceController.text = widget.product!.price.toString();
      _quantityController.text = widget.product!.quantityInStock.toString();
      _selectedImagePath = widget.product!.image;
    }
  }

  /// Выбор изображения из галереи
  Future<void> _pickImageFromGallery() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50, // Уменьшаем качество для меньшего размера файла
      );
      
      if (pickedFile != null) {
      setState(() {
        _pickedImageFile = pickedFile;
        _selectedImagePath = pickedFile.path;
      });
      }
    } catch (e) {
    }
  }

  /// Сжатие существующего base64 изображения
  Future<String> _compressBase64Image(String base64String) async {
    try {
      // Декодируем base64
      final imageBytes = base64Decode(base64String);
      final originalSizeKB = imageBytes.length / 1024;
      final originalBase64SizeKB = base64String.length / 1024;
      print('📸 Размер существующего base64 изображения:');
      print('   - Декодированные байты: ${originalSizeKB.toStringAsFixed(2)} KB');
      print('   - Base64 строка: ${originalBase64SizeKB.toStringAsFixed(2)} KB');
      
      // Всегда сжимаем, если base64 строка больше 200 KB (примерно 150 KB декодированных)
      if (originalBase64SizeKB < 200) {
        print('✅ Изображение уже достаточно маленькое, используем как есть');
        return base64String;
      }
      
      print('🔄 Сжатие существующего изображения...');
      
      // Загружаем изображение с меньшим размером для начала
      final codec = await ui.instantiateImageCodec(
        imageBytes,
        targetWidth: 600,
        targetHeight: 600,
      );
      final frame = await codec.getNextFrame();
      final image = frame.image;
      
      // Конвертируем в PNG
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final compressedBytes = byteData!.buffer.asUint8List();
      
      final compressedSizeKB = compressedBytes.length / 1024;
      final compressedBase64 = base64Encode(compressedBytes);
      final compressedBase64SizeKB = compressedBase64.length / 1024;
      
      print('✅ Размер после сжатия:');
      print('   - Декодированные байты: ${compressedSizeKB.toStringAsFixed(2)} KB');
      print('   - Base64 строка: ${compressedBase64SizeKB.toStringAsFixed(2)} KB');
      
      // Если base64 все еще больше 200 KB, пробуем еще раз с меньшим размером
      if (compressedBase64SizeKB > 200) {
        print('🔄 Дополнительное сжатие до 400x400...');
        final codec2 = await ui.instantiateImageCodec(
          compressedBytes,
          targetWidth: 400,
          targetHeight: 400,
        );
        final frame2 = await codec2.getNextFrame();
        final image2 = frame2.image;
        final byteData2 = await image2.toByteData(format: ui.ImageByteFormat.png);
        final finalBytes = byteData2!.buffer.asUint8List();
        
        final finalSizeKB = finalBytes.length / 1024;
        final finalBase64 = base64Encode(finalBytes);
        final finalBase64SizeKB = finalBase64.length / 1024;
        
        print('✅ Финальный размер:');
        print('   - Декодированные байты: ${finalSizeKB.toStringAsFixed(2)} KB');
        print('   - Base64 строка: ${finalBase64SizeKB.toStringAsFixed(2)} KB');
        
        image.dispose();
        image2.dispose();
        return finalBase64;
      }
      
      image.dispose();
      return compressedBase64;
    } catch (e) {
      print('❌ Ошибка сжатия base64 изображения: $e');
      print('   Stack trace: ${StackTrace.current}');
      // В случае ошибки возвращаем оригинал, но предупреждаем
      print('⚠️ ВНИМАНИЕ: Используется несжатое изображение, возможна ошибка 413!');
      return base64String;
    }
  }

  /// Сжатие и конвертация изображения в base64
  Future<String> _convertImageToBase64(String imagePath) async {
    try {
      final file = File(imagePath);
      final originalBytes = await file.readAsBytes();
      
      // Проверяем размер файла
      final fileSizeKB = originalBytes.length / 1024;
      print('📸 Размер оригинального изображения: ${fileSizeKB.toStringAsFixed(2)} KB');
      
      // Всегда сжимаем изображения для уменьшения размера base64
      // Base64 строка примерно на 33% больше исходных байтов
      print('🔄 Сжатие изображения...');
      
      // Начинаем с более агрессивного сжатия (600x600)
      final codec = await ui.instantiateImageCodec(
        originalBytes,
        targetWidth: 600,
        targetHeight: 600,
      );
      final frame = await codec.getNextFrame();
      final image = frame.image;
      
      // Конвертируем в PNG
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final compressedBytes = byteData!.buffer.asUint8List();
      
      final compressedSizeKB = compressedBytes.length / 1024;
      final compressedBase64 = base64Encode(compressedBytes);
      final compressedBase64SizeKB = compressedBase64.length / 1024;
      
      print('✅ Размер после сжатия:');
      print('   - Декодированные байты: ${compressedSizeKB.toStringAsFixed(2)} KB');
      print('   - Base64 строка: ${compressedBase64SizeKB.toStringAsFixed(2)} KB');
      
      // Если base64 все еще больше 200 KB, пробуем еще раз с меньшим размером
      if (compressedBase64SizeKB > 200) {
        print('🔄 Дополнительное сжатие до 400x400...');
        final codec2 = await ui.instantiateImageCodec(
          compressedBytes,
          targetWidth: 400,
          targetHeight: 400,
        );
        final frame2 = await codec2.getNextFrame();
        final image2 = frame2.image;
        final byteData2 = await image2.toByteData(format: ui.ImageByteFormat.png);
        final finalBytes = byteData2!.buffer.asUint8List();
        
        final finalSizeKB = finalBytes.length / 1024;
        final finalBase64 = base64Encode(finalBytes);
        final finalBase64SizeKB = finalBase64.length / 1024;
        
        print('✅ Финальный размер:');
        print('   - Декодированные байты: ${finalSizeKB.toStringAsFixed(2)} KB');
        print('   - Base64 строка: ${finalBase64SizeKB.toStringAsFixed(2)} KB');
        
        image.dispose();
        image2.dispose();
        return finalBase64;
      }
      
      image.dispose();
      return compressedBase64;
    } catch (e) {
      print('❌ Ошибка сжатия изображения: $e');
      print('   Stack trace: ${StackTrace.current}');
      // В случае ошибки пробуем отправить оригинал, но с предупреждением
      try {
        final file = File(imagePath);
        final bytes = await file.readAsBytes();
        final base64 = base64Encode(bytes);
        final base64SizeKB = base64.length / 1024;
        print('⚠️ ВНИМАНИЕ: Используется несжатое изображение!');
        print('   - Размер base64: ${base64SizeKB.toStringAsFixed(2)} KB');
        if (base64SizeKB > 200) {
          print('   ⚠️ Изображение слишком большое, возможна ошибка 413!');
        }
        return base64;
      } catch (e2) {
        throw Exception('Ошибка конвертации изображения: $e2');
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    // Проверяем наличие изображения
    if (_selectedImagePath == null || _selectedImagePath!.isEmpty) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
      final quantity = int.tryParse(_quantityController.text.trim()) ?? 0;
      final category = ''; // Категория не используется
      
      // Обработка изображения
      String image;
      if (_pickedImageFile != null && _selectedImagePath == _pickedImageFile!.path) {
        // Новое изображение из галереи - конвертируем в base64
        image = await _convertImageToBase64(_pickedImageFile!.path);
        print('📸 Используется новое изображение из галереи');
      } else if (_selectedImagePath != null && _selectedImagePath!.isNotEmpty) {
        // Проверяем, является ли это уже base64 строкой или URL
        final isBase64 = HexImage.looksLikeBase64(_selectedImagePath!);
        final isUrl = _selectedImagePath!.startsWith('http://') || _selectedImagePath!.startsWith('https://');
        
        if (isBase64) {
          // Base64 изображение - проверяем размер и сжимаем при необходимости
          final sizeKB = _selectedImagePath!.length / 1024;
          print('📸 Используется существующее base64 изображение');
          print('   - Размер base64: ${sizeKB.toStringAsFixed(2)} KB');
          
          // Всегда проверяем и сжимаем, если нужно (порог снижен до 200 KB)
          if (sizeKB > 200) {
            print('   ⚠️ Изображение слишком большое (${sizeKB.toStringAsFixed(2)} KB), сжимаем...');
            image = await _compressBase64Image(_selectedImagePath!);
            final finalSizeKB = image.length / 1024;
            print('   ✅ Размер после сжатия: ${finalSizeKB.toStringAsFixed(2)} KB');
          } else {
            image = _selectedImagePath!;
            print('   ✅ Изображение достаточно маленькое, используем как есть');
          }
        } else if (isUrl) {
          // URL - используем как есть
          image = _selectedImagePath!;
          print('📸 Используется существующее изображение (URL)');
        } else {
          // Возможно, это путь к файлу - пробуем загрузить и конвертировать
          try {
            final file = File(_selectedImagePath!);
            if (await file.exists()) {
              image = await _convertImageToBase64(_selectedImagePath!);
              print('📸 Конвертировано изображение из файла');
            } else {
              // Если файл не существует, используем путь как есть (может быть asset)
              image = _selectedImagePath!;
              print('📸 Используется путь к изображению (asset?)');
            }
          } catch (e) {
            // В случае ошибки используем путь как есть
            image = _selectedImagePath!;
            print('📸 Используется путь к изображению (ошибка загрузки: $e)');
          }
        }
      } else {
        throw Exception('Изображение не выбрано');
      }

      bool success;
      if (widget.product == null) {
        // Добавление нового товара
        success = await _catalogManager.addProduct(
          name: name,
          description: description,
          price: price,
          quantityInStock: quantity,
          category: category,
          image: image,
        );
        if (success) {
        }
      } else {
        // Редактирование существующего товара
        success = await _catalogManager.updateProduct(
          productId: widget.product!.id,
          name: name,
          description: description,
          price: price,
          quantityInStock: quantity,
          category: category,
          image: image,
        );
        if (success) {
        }
      }

      if (success) {
        // Показываем сообщение об успехе
        
        // Переходим на главный экран продавца
        // Используем offAllNamed чтобы закрыть все предыдущие экраны
        Get.offAllNamed('/seller-home');
      } else {
      }
    } catch (e) {
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product == null ? 'Добавить товар' : 'Редактировать товар',
          style: KTextTheme.lightTextTheme.titleLarge,
        ),
        backgroundColor: KColors.primary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(ScreenUtil.adaptiveWidth(16)),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Выбор изображения из галереи
                Text(
                  'Изображение товара',
                  style: KTextTheme.lightTextTheme.titleMedium?.copyWith(
                    color: KColors.textDark,
                  ),
                ),
                SizedBox(height: ScreenUtil.adaptiveHeight(8)),
                // Контейнер для выбора из галереи
                GestureDetector(
                  onTap: _pickImageFromGallery,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: (_pickedImageFile != null || (_selectedImagePath != null && _selectedImagePath!.isNotEmpty)) 
                            ? KColors.primary 
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade50,
                    ),
                    child: (_pickedImageFile != null || (_selectedImagePath != null && _selectedImagePath!.isNotEmpty))
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(
                              children: [
                                // Если выбрано новое изображение из галереи
                                _pickedImageFile != null
                                    ? Image.file(
                                        File(_pickedImageFile!.path),
                                        fit: BoxFit.contain, // Показываем изображение полностью
                                        width: double.infinity,
                                        height: double.infinity,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Center(
                                            child: Icon(Icons.error, color: Colors.red),
                                          );
                                        },
                                      )
                                    // Если это существующее изображение (base64 или URL)
                                    : Builder(
                                        builder: (context) {
                                          final imageProvider = HexImage.resolveImageProvider(_selectedImagePath!);
                                          if (imageProvider != null) {
                                            return Image(
                                              image: imageProvider,
                                              fit: BoxFit.contain, // Показываем изображение полностью
                                              width: double.infinity,
                                              height: double.infinity,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Center(
                                                  child: Icon(Icons.error, color: Colors.red),
                                                );
                                              },
                                              loadingBuilder: (context, child, loadingProgress) {
                                                if (loadingProgress == null) return child;
                                                return Center(
                                                  child: CircularProgressIndicator(
                                                    value: loadingProgress.expectedTotalBytes != null
                                                        ? loadingProgress.cumulativeBytesLoaded /
                                                            loadingProgress.expectedTotalBytes!
                                                        : null,
                                                  ),
                                                );
                                              },
                                            );
                                          } else {
                                            return Center(
                                              child: Icon(Icons.image_not_supported, color: Colors.grey),
                                            );
                                          }
                                        },
                                      ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.photo_library,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Нажмите, чтобы выбрать из галереи',
                                style: KTextTheme.lightTextTheme.bodyMedium?.copyWith(
                                  color: KColors.textDark,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                SizedBox(height: ScreenUtil.adaptiveHeight(16)),
                TextFormField(
                  controller: _nameController,
                  style: TextStyle(color: KColors.textDark),
                  decoration: InputDecoration(
                    labelText: 'Название товара',
                    labelStyle: TextStyle(color: KColors.textDark),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.shopping_bag, color: KColors.textDark),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Введите название товара';
                    }
                    return null;
                  },
                ),
                SizedBox(height: ScreenUtil.adaptiveHeight(16)),
                TextFormField(
                  controller: _descriptionController,
                  style: TextStyle(color: KColors.textDark),
                  decoration: InputDecoration(
                    labelText: 'Описание',
                    labelStyle: TextStyle(color: KColors.textDark),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description, color: KColors.textDark),
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Введите описание товара';
                    }
                    return null;
                  },
                ),
                SizedBox(height: ScreenUtil.adaptiveHeight(16)),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        style: TextStyle(color: KColors.textDark),
                        decoration: InputDecoration(
                          labelText: 'Цена',
                          labelStyle: TextStyle(color: KColors.textDark),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.currency_ruble, color: KColors.textDark),
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Введите цену';
                          }
                          final price = double.tryParse(value.trim());
                          if (price == null || price <= 0) {
                            return 'Введите корректную цену';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: ScreenUtil.adaptiveWidth(16)),
                    Expanded(
                      child: TextFormField(
                        controller: _quantityController,
                        style: TextStyle(color: KColors.textDark),
                        decoration: InputDecoration(
                          labelText: 'Количество',
                          labelStyle: TextStyle(color: KColors.textDark),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.inventory, color: KColors.textDark),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Введите количество';
                          }
                          final quantity = int.tryParse(value.trim());
                          if (quantity == null || quantity < 0) {
                            return 'Введите корректное количество';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ScreenUtil.adaptiveHeight(24)),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: ScreenUtil.adaptiveHeight(16),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          widget.product == null ? 'Добавить товар' : 'Сохранить изменения',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

