import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kollibry/common/themes/theme.dart';
import '../../../common/styles/colors.dart'; // Стили
import '../../../utils/device/screen_util.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/category_list.dart';
import '../widgets/product_grid.dart'; // Адаптивность
import '../../../data/repositories/auth_repository.dart';
import '../models/product_model.dart';
import '../../auth/controllers/auth_controller.dart';

class HomePage extends StatelessWidget {
  final List<String> banners = [
    'assets/images/banners/banner_1.jpg',
    'assets/images/banners/banner_2.jpg',
    'assets/images/banners/banner_3.jpg',
    'assets/images/banners/banner_4.jpg',
    'assets/images/banners/banner_5.jpg',
  ];

  final List<Map<String, String>> categories = [
    {
      'title': 'Боулинг',
      'icon': 'assets/images/category/icons8-bowling-64.png'
    },
    {
      'title': 'Косметика',
      'icon': 'assets/images/category/icons8-cosmetics-64.png'
    },
    {
      'title': 'Мебель',
      'icon': 'assets/images/category/icons8-dining-chair-64.png'
    },
    {
      'title': 'Для питомцев',
      'icon': 'assets/images/category/icons8-dog-heart-64.png'
    },
    {
      'title': 'Школьная форма',
      'icon': 'assets/images/category/icons8-school-uniform-64.png'
    },
  ];

  final ProductRepository productRepository = ProductRepository();

  @override
  Widget build(BuildContext context) {
    // Убеждаемся, что AuthController инициализирован
    final authController = Get.find<AuthController>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
                right: ScreenUtil.adaptiveWidth(8),
                left: ScreenUtil.adaptiveWidth(8),
                bottom: ScreenUtil.adaptiveWidth(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                    height: ScreenUtil.adaptiveHeight(40)), // Отступ сверху
                // Поле поиска
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Искать товары...',
                    prefixIcon:
                        Icon(Icons.search, color: KColors.textSecondary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: TAppTheme.lightTheme.focusColor,
                  ),
                ),
                SizedBox(
                    height:
                        ScreenUtil.adaptiveHeight(20)), // Отступ после поиска
                // Баннеры
                BannerCarousel(banners: banners),
                SizedBox(
                    height:
                        ScreenUtil.adaptiveHeight(20)), // Отступ после баннеров
                // Категории
                CategoryList(categories: categories),
                SizedBox(
                    height: ScreenUtil.adaptiveHeight(
                        25)), // Отступ после категорий
                // Товары
                FutureBuilder<List<ProductModel>>(
                  future: productRepository.getProducts(),
                  builder: (context, snapshot) {
                    print(
                        'FutureBuilder состояние: ${snapshot.connectionState}');
                    print('FutureBuilder ошибка: ${snapshot.error}');
                    print('FutureBuilder данные: ${snapshot.data?.length}');

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Загрузка товаров...'),
                          ],
                        ),
                      );
                    } else if (snapshot.hasError) {
                      final errorMessage = snapshot.error.toString();
                      print('Ошибка загрузки товаров: $errorMessage');

                      // Временное решение: показываем тестовые данные при ошибке API
                      if (errorMessage.contains('403') ||
                          errorMessage.contains('401') ||
                          errorMessage.contains('Ошибка сервера')) {
                        print('Показываем тестовые данные из-за ошибки API');
                        final testProducts = [
                          {
                            'id': 1,
                            'name': 'iPhone 12',
                            'description':
                                'Современный смартфон с мощными функциями.',
                            'price': 70000.0,
                            'image':
                                'assets/images/products/iphone_12_green.png',
                          },
                          {
                            'id': 2,
                            'name': 'Samsung S9',
                            'description':
                                'Высокопроизводительный телефон для работы и развлечений.',
                            'price': 50000.0,
                            'image':
                                'assets/images/products/samsung_s9_mobile_withback.png',
                          },
                          {
                            'id': 3,
                            'name': 'Acer Laptop',
                            'description':
                                'Ноутбук для повседневных задач и развлечений.',
                            'price': 45000.0,
                            'image':
                                'assets/images/products/acer_laptop_var_4.png',
                          },
                          {
                            'id': 4,
                            'name': 'Тапочки',
                            'description': 'Удобные домашние тапочки.',
                            'price': 1500.0,
                            'image':
                                'assets/images/products/slipper-product.png',
                          },
                        ];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(16),
                              margin: EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.warning, color: Colors.orange),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'API недоступен. Показаны тестовые данные.',
                                          style: TextStyle(
                                              color: Colors.orange[800]),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (errorMessage.contains('авторизация') ||
                                      errorMessage.contains('401') ||
                                      errorMessage.contains('403'))
                                    Padding(
                                      padding: EdgeInsets.only(top: 8),
                                      child: ElevatedButton(
                                        onPressed: () => Get.toNamed('/login'),
                                        child: Text('Войти в систему'),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            ProductGrid(products: testProducts),
                          ],
                        );
                      }

                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, size: 48, color: Colors.red),
                            SizedBox(height: 16),
                            Text('Ошибка загрузки товаров:'),
                            SizedBox(height: 8),
                            Text(errorMessage,
                                style: TextStyle(fontSize: 12),
                                textAlign: TextAlign.center),
                            SizedBox(height: 16),
                            if (errorMessage.contains('авторизация'))
                              ElevatedButton(
                                onPressed: () => Get.toNamed('/login'),
                                child: Text('Войти в систему'),
                              ),
                          ],
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2,
                                size: 48, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('Товары не найдены'),
                          ],
                        ),
                      );
                    } else {
                      print('Отображение ${snapshot.data!.length} товаров');
                      // Преобразуем ProductModel в Map для ProductGrid
                      final products = snapshot.data!
                          .map((p) => {
                                'id': p.id,
                                'name': p.name,
                                'description': p.description,
                                'price': p.price,
                                'image': p.image,
                                'category': p.category,
                                'quantityInStock': p.quantityInStock,
                              })
                          .toList();
                      return ProductGrid(products: products);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
