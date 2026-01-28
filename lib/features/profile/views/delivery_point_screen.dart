import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kollibry/common/themes/theme.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import '../../../common/styles/colors.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/models/order_model.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../orders/controllers/orders_controller.dart';
import '../../../utils/constants/strings.dart';
import '../../../utils/device/screen_util.dart';

/// Экран выбора точки доставки
class DeliveryPointScreen extends StatefulWidget {
  String? role; // Убираем final
  Map<String, dynamic>? productData; // Убираем final

  DeliveryPointScreen({
    // Убираем const
    Key? key,
    this.role,
    this.productData, // Данные о товаре из корзины или карточки товара
  }) : super(key: key);

  @override
  _DeliveryPointScreenState createState() => _DeliveryPointScreenState();
}

class _DeliveryPointScreenState extends State<DeliveryPointScreen> {
  // Контроллер для управления картой
  final MapController _mapController = MapController();
  // Контроллер для поля поиска адреса
  final TextEditingController _searchController = TextEditingController();
  // Экземпляр Location для работы с GPS
  Location _location = Location();
  // Текущее местоположение пользователя
  LatLng? _currentPosition;
  // Координаты по умолчанию (Санкт-Петербург)
  LatLng _defaultPosition = LatLng(59.9343, 30.3351);
  // Маркер, обозначающий выбранную точку доставки
  Marker? _deliveryMarker;

  // Переменная для хранения данных о товаре
  Map<String, dynamic>? _productData;

  // Сохраняем выбранную точку и адрес для кнопки "Заказать"
  LatLng? _selectedPoint;
  String? _selectedAddress;

  // Список вариантов адресов
  List<Map<String, dynamic>> _suggestions = [];

  // Локальное хранилище для истории поиска
  final GetStorage _storage = GetStorage();
  List<String> _searchHistory = [];

  // Тип карты: true - спутниковая, false - обычная
  bool _isSatelliteView = false;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    _checkAndRequestPermissions(); // Проверяем разрешения на геолокацию при запуске экрана

    // Получаем аргументы из Get.arguments
    final arguments = Get.arguments;
    if (arguments != null) {
      final role = arguments['role'] as String?;
      final productData = arguments['productData'] as Map<String, dynamic>?;
      final cartItems = arguments['cartItems'] as List<dynamic>?;
      final fromCart = arguments['fromCart'] as bool? ?? false;

      if (role != null) {
        widget.role = role;
      }

      // Если заказ из корзины, берем первый товар из списка
      if (fromCart && cartItems != null && cartItems.isNotEmpty) {
        final firstCartItem = cartItems.first as Map<String, dynamic>;
        // Устанавливаем флаг fromCart для товара
        firstCartItem['fromCart'] = true;
        setState(() {
          _productData = firstCartItem;
        });
      } else if (productData != null) {
        // Обновляем данные о товаре
        setState(() {
          _productData = productData;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Определяем роль для отображения
    String getRoleDisplayName() {
      final box = GetStorage();
      final role = box.read('role') ?? 'buyer';
      switch (role) {
        case 'buyer':
          return 'Покупатель';
        case 'seller':
          return 'Продавец';
        case 'tech':
          return 'Техник';
        default:
          return 'Пользователь';
      }
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '${Strings.appName} - ${getRoleDisplayName()}',
          style: TAppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        backgroundColor: KColors.primary,
      ),
      body: Stack(
        children: [
          /// Карта с возможностью выбора точки доставки
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition ?? _defaultPosition,
              initialZoom: 12.0,
              // Установка маркера при клике на карту
              onTap: (tapPosition, point) async {
                await _updateDeliveryPoint(point, showDialog: false);
              },
            ),
            children: [
              /// Слой с картами (обычная или спутниковая)
              TileLayer(
                urlTemplate: _isSatelliteView
                    ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.kollibry',
              ),

              /// Слой с маркером доставки (если он установлен)
              if (_deliveryMarker != null)
                MarkerLayer(
                  markers: [_deliveryMarker!],
                ),
            ],
          ),

          /// Поле поиска адреса
          Positioned(
            top: 10,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: "Введите адрес...",
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: _searchLocation,
                      ),
                    ),
                    onChanged: (text) => _fetchAddressSuggestions(text),
                    onSubmitted: (_) => _searchLocation(),
                  ),
                ),

                /// Отображение предложенных адресов и истории поиска
                _suggestions.isNotEmpty || _searchHistory.isNotEmpty
                    ? Container(
                        color: Colors.white,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount:
                              _suggestions.length + _searchHistory.length,
                          itemBuilder: (context, index) {
                            if (index < _searchHistory.length) {
                              // Отображение истории поиска
                              final historyItem = _searchHistory[index];
                              return ListTile(
                                leading:
                                    Icon(Icons.history, color: KColors.primary),
                                title: Text(historyItem),
                                onTap: () {
                                  _searchController.text = historyItem;
                                  _searchLocation();
                                },
                              );
                            } else {
                              // Отображение предложенных адресов
                              final suggestionIndex =
                                  index - _searchHistory.length;
                              final suggestion = _suggestions[suggestionIndex];
                              return ListTile(
                                leading: Icon(Icons.location_on,
                                    color: KColors.primary),
                                title: Text(suggestion['display_name']),
                                onTap: () {
                                  _searchController.text =
                                      suggestion['display_name'];
                                  _searchLocation();
                                },
                              );
                            }
                          },
                        ),
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ),

          /// Кнопки управления картой
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Кнопка переключения вида карты
                FloatingActionButton(
                  backgroundColor: KColors.primary,
                  onPressed: _toggleMapType,
                  heroTag: 'map_type',
                  child: Icon(
                    _isSatelliteView ? Icons.map : Icons.satellite,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),

                /// Кнопка для получения текущего местоположения
                FloatingActionButton(
                  backgroundColor: KColors.primary,
                  onPressed: _getCurrentLocation,
                  heroTag: 'my_location',
                  child: const Icon(Icons.my_location, color: Colors.white),
                ),
              ],
            ),
          ),

          /// Кнопка "Заказать" внизу экрана
          if (_deliveryMarker != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 100, // Оставляем место для кнопок справа
              child: ElevatedButton.icon(
                onPressed: _onOrderButtonPressed,
                icon: Icon(Icons.shopping_bag, color: Colors.white),
                label: Text(
                  'Заказать',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: KColors.buttonDark,
                  padding: EdgeInsets.symmetric(
                    vertical: ScreenUtil.adaptiveHeight(15),
                    horizontal: ScreenUtil.adaptiveWidth(20),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Проверка и запрос разрешений на геолокацию
  Future<void> _checkAndRequestPermissions() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Проверяем, включена ли служба GPS
    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    // Проверяем, есть ли разрешение на доступ к геолокации
    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted &&
          permissionGranted != PermissionStatus.grantedLimited) {
        return;
      }
    }

    // После получения разрешений автоматически определяем местоположение
    if (permissionGranted == PermissionStatus.granted ||
        permissionGranted == PermissionStatus.grantedLimited) {
      _getCurrentLocation();
    }
  }

  /// Переключение между обычным и спутниковым видом карты
  void _toggleMapType() {
    setState(() {
      _isSatelliteView = !_isSatelliteView;
    });
  }

  /// Получение списка адресов для автоподсказки
  Future<void> _fetchAddressSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions.clear();
      });
      return;
    }

    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      setState(() {
        _suggestions = data.cast<Map<String, dynamic>>();
      });
    }
  }

  /// Получение текущего местоположения пользователя
  Future<void> _getCurrentLocation() async {
    try {
      LocationData locationData = await _location.getLocation();
      final LatLng newLocation =
          LatLng(locationData.latitude!, locationData.longitude!);

      setState(() {
        _currentPosition = newLocation;
      });

      // Устанавливаем точку доставки без показа диалога
      await _updateDeliveryPoint(newLocation, showDialog: false);

      // Перемещаем карту к текущему местоположению
      _mapController.move(newLocation, 16.0);
    } catch (e) {}
  }

  /// Поиск местоположения по введенному адресу
  Future<void> _searchLocation() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      return;
    }

    // Отправляем запрос к API Nominatim (OpenStreetMap)
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      if (data.isNotEmpty) {
        final double lat = double.parse(data[0]['lat']);
        final double lon = double.parse(data[0]['lon']);
        final LatLng newLocation = LatLng(lat, lon);

        setState(() {
          _currentPosition = newLocation;
          _suggestions.clear(); // Очищаем список предложенных адресов
        });

        // Устанавливаем точку доставки без показа диалога
        await _updateDeliveryPoint(newLocation, showDialog: false);

        _mapController.move(newLocation, 16.0);

        _saveSearchHistory(query);
      }
    }
  }

  /// Устанавливает маркер точки доставки на карте
  Future<void> _updateDeliveryPoint(LatLng point,
      {bool showDialog = false}) async {
    setState(() {
      _deliveryMarker = Marker(
        point: point,
        width: 40,
        height: 40,
        child: const Icon(
          Icons.location_pin,
          color: Colors.red,
          size: 40,
        ),
      );
      _selectedPoint = point;
    });

    // Запрашиваем адрес по координатам
    String address = await _getAddressFromLatLng(point);
    _selectedAddress = address;

    // Если нужно показать диалог (при клике на карту или поиске)
    if (showDialog) {
      // Перемещаем карту к новому маркеру только если нужно показать диалог
      _mapController.move(point, 16.0);
      _showOrderConfirmationDialog(address, point);
    }
  }

  /// Обработчик нажатия на кнопку "Заказать"
  Future<void> _onOrderButtonPressed() async {
    if (_selectedPoint == null || _selectedAddress == null) {
      return;
    }

    // Показываем диалог подтверждения без изменения масштаба карты
    // Масштаб остается неизменным, так как мы не вызываем _mapController.move()
    _showOrderConfirmationDialog(_selectedAddress!, _selectedPoint!);
  }

  /// Сохранение истории поиска (до 3 последних запросов)
  void _saveSearchHistory(String query) {
    _searchHistory.remove(query);
    _searchHistory.insert(0, query);
    if (_searchHistory.length > 2) {
      _searchHistory.removeLast();
    }
    _storage.write('searchHistory', _searchHistory);
  }

  /// Загрузка истории поиска из локального хранилища
  void _loadSearchHistory() {
    _searchHistory = _storage.read<List>('searchHistory')?.cast<String>() ?? [];
  }

  /// Показывает окно подтверждения заказа
  /// Показывает окно подтверждения заказа с адресом
  void _showOrderConfirmationDialog(String address, LatLng point) {
    // Алерт-диалоги отключены по требованию
    final orderRole = widget.role ?? 'buyer';
    _placeOrder(address, point, orderRole);
  }

  /// Логика оформления заказа (здесь можно отправить данные на сервер)
  /// Оформление заказа с адресом
  Future<void> _placeOrder(String address, LatLng point, String role) async {
    final box = GetStorage();

    // Получаем userId из хранилища
    final userId = box.read('userId') ?? 'user_123';

    // Получаем данные о товаре
    int productId = 1; // Значение по умолчанию
    int quantity = 1; // Количество по умолчанию
    String productName = 'Товар';
    String productImage = '';
    double price = 0.0;
    bool isTechOrder = false;

    if (_productData != null) {
      // Если есть данные о товаре, используем их
      productId = _productData!['id'] ?? 1;
      quantity = _productData!['quantity'] ?? 1;
      productName = _productData!['name'] ?? 'Товар';
      productImage = _productData!['image'] ?? '';
      price = (_productData!['price'] ?? 0.0).toDouble();
      isTechOrder = _productData!['isTechOrder'] ?? false;
    }

    // Отправляем заказ на сервер
    try {
      print('📤 СОЗДАНИЕ ЗАКАЗА ПОКУПАТЕЛЕМ');
      print('   userId: $userId');
      print('   productId: $productId');
      print('   quantity: $quantity');
      print('   Координаты: ${point.latitude}, ${point.longitude}');

      final orderRepository = OrderRepository();
      final success = await orderRepository.placeOrder(
        userId: userId,
        productId: productId,
        quantity: quantity,
        deliveryLatitude: point.latitude,
        deliveryLongitude: point.longitude,
      );

      if (!success) {
        print('❌ Заказ НЕ был размещен на сервере!');
        return;
      }

      print('✅ Заказ успешно отправлен на сервер!');
      print('   Теперь продавец должен увидеть этот заказ в списке');

      // Обновляем список заказов после успешного создания (если контроллер инициализирован)
      try {
        if (Get.isRegistered<OrdersController>()) {
          final ordersController = Get.find<OrdersController>();
          await ordersController.loadOrders();
        }
      } catch (e) {
        // Игнорируем ошибки обновления списка заказов
        print('Не удалось обновить список заказов: $e');
      }
    } catch (e) {
      return;
    }

    // Создаем объект заказа для передачи на экран статусов
    final orderModel = OrderModel(
      id: DateTime.now().millisecondsSinceEpoch, // Временный ID
      userId: userId,
      productId: productId,
      quantity: quantity,
      deliveryLatitude: point.latitude,
      deliveryLongitude: point.longitude,
      status: 'pending',
      productName: productName,
      productImage: productImage,
      price: price,
      buyerName: box.read('firstName') ?? 'Покупатель',
      sellerName: 'Продавец',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Локальное сохранение истории отключено по требованию

    // Заказ оформлен

    // Очищаем корзину если заказ был из корзины
    if (_productData != null && _productData!['fromCart'] == true) {
      try {
        final cartController = Get.find<CartController>();
        cartController.clearCart();
      } catch (e) {
        // Игнорируем ошибки с корзиной
      }
    }

    // Для техника показываем снекбар с кнопкой "Вызвать дрон"
    if (role == 'technician' || isTechOrder) {
      _showDroneCallSnackBar(orderModel, address);
    } else {
      // Сразу переходим на экран статусов доставки с данными заказа
      Get.toNamed('/delivery-status', arguments: orderModel);
    }
  }

  /// Показывает снекбар с кнопкой "Вызвать дрон" для техника
  void _showDroneCallSnackBar(OrderModel orderModel, String address) {
    // Вызываем дрон напрямую
    _callDrone(orderModel);
  }

  /// Вызывает дрон и переходит к статусам продавца
  void _callDrone(OrderModel orderModel) {
    // Переходим к статусам продавца
    Get.toNamed('/seller-order-status', arguments: orderModel);
  }

  /// Получает адрес по координатам с помощью API Nominatim (OpenStreetMap)
  Future<String> _getAddressFromLatLng(LatLng point) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=${point.latitude}&lon=${point.longitude}&format=json');

    final String fallback =
        '${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}';

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['display_name']; // Полный адрес
        if (address is String && address.trim().isNotEmpty) {
          return address;
        } else {
          return fallback; // Если адрес пустой
        }
      } else {
        return fallback; // Если не 200 — возвращаем координаты
      }
    } catch (e) {
      return fallback; // При любой ошибке сети — координаты
    }
  }
}
