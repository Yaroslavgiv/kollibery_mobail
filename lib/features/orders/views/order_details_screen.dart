import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/styles/colors.dart';
import '../../../../common/styles/sizes.dart';
import '../../../../common/themes/text_theme.dart';
import '../../../../utils/device/screen_util.dart';

class OrderDetailsScreen extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String description;
  final double price;
  final int productId; // Добавить этот параметр

  OrderDetailsScreen({
    required this.imageUrl,
    required this.name,
    required this.description,
    required this.price,
    required this.productId, // Добавить в конструктор
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.backgroundLight,
      appBar: AppBar(
        title: Text(name, style: Theme.of(context).textTheme.titleLarge),
        backgroundColor: KColors.primary,
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
                      image: AssetImage(imageUrl),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              SizedBox(height: ScreenUtil.adaptiveHeight(20)),

              // Название товара
              Text(
                name,
                style: KTextTheme.darkTextTheme.headlineLarge,
              ),
              SizedBox(height: ScreenUtil.adaptiveHeight(10)),

              // Цена товара
              Text(
                "${price.toStringAsFixed(2)} ₽",
                style: KTextTheme.lightTextTheme.titleMedium,
              ),
              SizedBox(height: ScreenUtil.adaptiveHeight(20)),

              // Описание товара
              Text(
                description,
                style: KTextTheme.lightTextTheme.titleMedium,
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: ScreenUtil.adaptiveHeight(30)),

              // Кнопка "Заказать"
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Передаем данные о товаре в экран выбора точки доставки
                    final productData = {
                      'id': productId, // Использовать переданный productId
                      'name': name,
                      'description': description,
                      'price': price,
                      'image': imageUrl,
                      'quantity': 1,
                      'fromCart': false,
                    };

                    Get.toNamed('/delivery-point', arguments: {
                      'role':
                          'buyer', // Всегда как покупатель при заказе товара
                      'productData': productData,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KColors.primary,
                    padding: EdgeInsets.symmetric(
                        vertical: ScreenUtil.adaptiveHeight(15),
                        horizontal: ScreenUtil.adaptiveWidth(50)),
                  ),
                  child: Text(
                    "Заказать",
                    style: KTextTheme.darkTextTheme.bodyLarge,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
