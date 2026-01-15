import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/product_repository.dart';
import '../../home/widgets/product_grid.dart';
import '../../home/models/product_model.dart';
import 'tech_product_card_screen.dart';

class TechProductsScreen extends StatefulWidget {
  @override
  State<TechProductsScreen> createState() => _TechProductsScreenState();
}

class _TechProductsScreenState extends State<TechProductsScreen> {
  final ProductRepository productRepository = ProductRepository();
  late Future<List<ProductModel>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = productRepository.getProducts();
  }

  void _refreshProducts() {
    setState(() {
      _productsFuture = productRepository.getProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Товары для заказа (Техник)')),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshProducts();
          // Ждем завершения загрузки
          await _productsFuture;
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: FutureBuilder<List<ProductModel>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                print('=== TECH PRODUCTS DEBUG ===');
                print('Connection state: ${snapshot.connectionState}');
                print('Has error: ${snapshot.hasError}');
                print('Error: ${snapshot.error}');
                print('Has data: ${snapshot.hasData}');
                print('Data length: ${snapshot.data?.length}');
                print('=== END TECH PRODUCTS DEBUG ===');

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: MediaQuery.of(context).size.height - 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Загрузка товаров...',
                              style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  final errorMessage = snapshot.error.toString();
                  print('Ошибка загрузки товаров: $errorMessage');

                  return Container(
                    height: MediaQuery.of(context).size.height - 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, size: 48, color: Colors.red),
                          SizedBox(height: 16),
                          Text('Ошибка загрузки товаров:',
                              style: TextStyle(color: Colors.black)),
                          SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32.0),
                            child: Text(errorMessage,
                                style: TextStyle(fontSize: 12, color: Colors.black),
                                textAlign: TextAlign.center),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _refreshProducts,
                            child: Text('Повторить'),
                          ),
                          if (errorMessage.contains('авторизация') ||
                              errorMessage.contains('401'))
                            SizedBox(height: 8),
                          if (errorMessage.contains('авторизация') ||
                              errorMessage.contains('401'))
                            ElevatedButton(
                              onPressed: () => Get.toNamed('/login'),
                              child: Text('Войти в систему'),
                            ),
                        ],
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Container(
                    height: MediaQuery.of(context).size.height - 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Товары не найдены',
                              style: TextStyle(color: Colors.black)),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _refreshProducts,
                            child: Text('Обновить'),
                          ),
                        ],
                      ),
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
                  return ProductGrid(
                    products: products,
                    onProductTap: (productMap) {
                      final product = ProductModel.fromJson(productMap);
                      Get.to(() => TechProductCardScreen(product: product));
                    },
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
