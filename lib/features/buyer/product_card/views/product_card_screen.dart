import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../common/styles/colors.dart';
import '../../../../common/styles/sizes.dart';
import '../../../../common/themes/text_theme.dart';
import '../../../../utils/device/screen_util.dart';
import '../../../../utils/helpers/hex_image.dart';
import '../controllers/product_card_controller.dart';
import '../../../home/models/product_model.dart';
import '../../../cart/controllers/cart_controller.dart';

class ProductCardScreen extends StatelessWidget {
  final ProductModel product;

  ProductCardScreen({required this.product});

  final ProductCardController controller = Get.put(ProductCardController());
  final CartController cartController = Get.put(CartController());
  final GetStorage box = GetStorage();

  @override
  Widget build(BuildContext context) {
    // Универсальный провайдер: Base64/HEX/HTTP/asset + безопасный фолбэк
    final imageProvider = HexImage.resolveImageProvider(product.image) ??
        const AssetImage('assets/logos/Logo_black.png');

    return Scaffold(
      backgroundColor: KColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          product.name,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: KColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(ScreenUtil.adaptiveWidth(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Картинка товара
              Center(
                child: Container(
                  height: ScreenUtil.percentHeight(50),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(KSizes.md),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              SizedBox(height: ScreenUtil.adaptiveHeight(20)),

              // Название товара
              Text(
                product.name,
                style: KTextTheme.darkTextTheme.headlineLarge?.copyWith(
                  color: Colors.black,
                ),
              ),
              SizedBox(height: ScreenUtil.adaptiveHeight(10)),

              // Цена товара
              Text(
                "${product.price.toStringAsFixed(2)} ₽",
                style: KTextTheme.lightTextTheme.titleMedium,
              ),
              SizedBox(height: ScreenUtil.adaptiveHeight(20)),

              // Описание товара
              Text(
                product.description,
                style: KTextTheme.lightTextTheme.titleMedium,
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: ScreenUtil.adaptiveHeight(30)),

              // Кнопки "Добавить в корзину" и "Оформить заказ" (только для покупателя)
              // Проверяем роль пользователя
              Builder(
                builder: (context) {
                  final role = box.read('role') ?? 'buyer';
                  // Скрываем кнопки для продавца и техника
                  if (role == 'seller' || role == 'technician' || role == 'tech') {
                    return SizedBox.shrink(); // Не показываем кнопки
                  }
                  
                  // Показываем кнопки только для покупателя
                  return Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            try {
                              cartController.addToCart(product.toJson());
                            } catch (e) {
                              Get.snackbar(
                                'Ошибка',
                                'Не удалось добавить товар в корзину',
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                                duration: Duration(seconds: 2),
                              );
                            }
                          },
                          icon: Icon(Icons.add_shopping_cart),
                          label: Text("Добавить в корзину"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KColors.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                vertical: ScreenUtil.adaptiveHeight(15),
                                horizontal: ScreenUtil.adaptiveHeight(5)),
                          ),
                        ),
                      ),
                      SizedBox(width: ScreenUtil.adaptiveWidth(10)),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Передаем данные о товаре в экран выбора точки доставки
                            final productData = {
                              'id': product.id,
                              'name': product.name,
                              'description': product.description,
                              'price': product.price,
                              'image': product.image,
                              'quantity': 1,
                              'fromCart': false,
                            };

                            Get.toNamed('/delivery-point', arguments: {
                              'role': 'buyer',
                              'productData': productData,
                            });
                          },
                          icon: Icon(Icons.shopping_bag),
                          label: Text("Оформить заказ"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KColors.buttonDark,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                vertical: ScreenUtil.adaptiveHeight(15),
                                horizontal: ScreenUtil.adaptiveHeight(5)),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


