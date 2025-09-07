import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/models/order_model.dart';
import '../../home/models/product_model.dart';
import '../../home/widgets/product_grid.dart';
import '../../../common/styles/colors.dart';
import '../../../utils/device/screen_util.dart';
import '../../../utils/helpers/hex_image.dart';
import 'seller_pickup_location_screen.dart';
import '../../../features/auth/controllers/auth_controller.dart';

class SellerMainScreen extends StatefulWidget {
  @override
  State<SellerMainScreen> createState() => _SellerMainScreenState();
}

class _SellerMainScreenState extends State<SellerMainScreen> {
  int _currentIndex = 0;
  final GetStorage box = GetStorage();
  final AuthController authController = Get.put(AuthController());

  // Две вкладки (примерные)
  final List<Widget> _tabs = [
    SellerProductsScreen(),
    SellerOrdersScreen(),
  ];

  String _getRoleDisplayName() {
    final role = box.read('role') ?? 'seller';
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

  /// Показывает диалог подтверждения выхода
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Выход из аккаунта",
            style: TextStyle(color: Colors.black),
          ),
          content: Text(
            "Вы уверены, что хотите выйти из аккаунта?",
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Отмена",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                authController.logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text("Выйти"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Роль: ${_getRoleDisplayName()}'),
        centerTitle: true,
        backgroundColor: KColors.primary,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _showLogoutDialog,
            tooltip: 'Выйти из аккаунта',
          ),
        ],
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Мои товары',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_basket),
            label: 'Заказы',
          ),
        ],
      ),
    );
  }
}

// Экран списка товаров
class SellerProductsScreen extends StatelessWidget {
  final ProductRepository productRepository = ProductRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(ScreenUtil.adaptiveWidth(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Мои товары',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: ScreenUtil.adaptiveHeight(16)),
              Expanded(
                child: FutureBuilder<List<ProductModel>>(
                  future: productRepository.getProducts(),
                  builder: (context, snapshot) {
                    print(
                        'SellerProductsScreen - FutureBuilder состояние: ${snapshot.connectionState}');
                    print(
                        'SellerProductsScreen - FutureBuilder ошибка: ${snapshot.error}');
                    print(
                        'SellerProductsScreen - FutureBuilder данные: ${snapshot.data?.length}');

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
                      print(
                          'SellerProductsScreen - Ошибка загрузки товаров: $errorMessage');

                      // Временное решение: показываем тестовые данные при ошибке API
                      if (errorMessage.contains('403') ||
                          errorMessage.contains('401') ||
                          errorMessage.contains('Ошибка сервера')) {
                        print(
                            'SellerProductsScreen - Показываем тестовые данные из-за ошибки API');
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
                            Expanded(
                                child: ProductGrid(products: testProducts)),
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
                      print(
                          'SellerProductsScreen - Отображение ${snapshot.data!.length} товаров');
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Экран списка заказов
class SellerOrdersScreen extends StatelessWidget {
  final OrderRepository orderRepository = OrderRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(ScreenUtil.adaptiveWidth(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Заказы покупателей',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: ScreenUtil.adaptiveHeight(16)),
              Expanded(
                child: FutureBuilder<List<OrderModel>>(
                  future: orderRepository.fetchSellerOrdersAsModels(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Загрузка заказов...'),
                          ],
                        ),
                      );
                    } else if (snapshot.hasError) {
                      // Показываем тестовые данные при ошибке API
                      print(
                          'SellerOrdersScreen - Показываем тестовые данные из-за ошибки API');
                      final testOrders = [
                        OrderModel(
                          id: 1,
                          userId: 'user_1', // Добавлен userId
                          productId: 1,
                          productName: 'iPhone 12',
                          productImage:
                              'assets/images/products/iphone_12_green.png',
                          quantity: 1,
                          price: 70000.0,
                          status:
                              'pending', // Статус для кнопки "Взять в работу"
                          buyerName: 'Иван Петров',
                          sellerName: 'Магазин Техники',
                          deliveryLatitude: 59.9343,
                          deliveryLongitude: 30.3351,
                          createdAt:
                              DateTime.now().subtract(Duration(hours: 2)),
                        ),
                        OrderModel(
                          id: 2,
                          userId: 'user_2', // Добавлен userId
                          productId: 2,
                          productName: 'Samsung Galaxy S21',
                          productImage:
                              'assets/images/products/samsung_s9_mobile_withback.png',
                          quantity: 1,
                          price: 55000.0,
                          status: 'processing', // Уже в работе
                          buyerName: 'Мария Сидорова',
                          sellerName: 'Магазин Техники',
                          deliveryLatitude: 59.9343,
                          deliveryLongitude: 30.3351,
                          createdAt:
                              DateTime.now().subtract(Duration(hours: 1)),
                        ),
                      ];

                      return Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 16),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warning, color: Colors.orange),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'API недоступен. Показаны тестовые данные.',
                                    style: TextStyle(color: Colors.orange[800]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: testOrders.length,
                              itemBuilder: (context, index) {
                                final order = testOrders[index];
                                final imageProvider =
                                    HexImage.resolveImageProvider(
                                            order.productImage) ??
                                        const AssetImage(
                                            'assets/logos/Logo_black.png');
                                return Card(
                                  margin: EdgeInsets.only(bottom: 12),
                                  child: Column(
                                    children: [
                                      ListTile(
                                        leading: CircleAvatar(
                                          radius: 24,
                                          backgroundImage: imageProvider,
                                          backgroundColor: Colors.grey.shade200,
                                        ),
                                        title: Text(
                                          order.productName.isNotEmpty
                                              ? order.productName
                                              : 'Товар #${order.productId}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 4),
                                            Text(
                                                'Статус: ${_getStatusText(order.status)}'),
                                            Text(
                                                'Количество: ${order.quantity}'),
                                            Text(
                                                'Цена: ${order.price.toStringAsFixed(2)} ₽'),
                                            Text(
                                                'Покупатель: ${order.buyerName.isNotEmpty ? order.buyerName : 'Не указан'}'),
                                            if (order.createdAt != null)
                                              Text(
                                                  'Дата: ${_formatDate(order.createdAt!)}'),
                                          ],
                                        ),
                                        trailing: _getStatusIcon(order.status),
                                        isThreeLine: true,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: 12.0, bottom: 12.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                _showOrderDetails(
                                                    context, order);
                                              },
                                              child: Text('Детали'),
                                            ),
                                            SizedBox(width: 8),
                                            if (order.status.toLowerCase() ==
                                                'pending')
                                              ElevatedButton(
                                                onPressed: () {
                                                  _takeOrderInWork(order);
                                                },
                                                child: Text('Взять в работу'),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_basket_outlined,
                                size: 48, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('Нет заказов'),
                            SizedBox(height: 8),
                            Text('Покупатели пока не оформили заказы',
                                style:
                                    TextStyle(fontSize: 14, color: Colors.grey),
                                textAlign: TextAlign.center),
                          ],
                        ),
                      );
                    } else {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final order = snapshot.data![index];
                          final imageProvider = HexImage.resolveImageProvider(
                                  order.productImage) ??
                              const AssetImage('assets/logos/Logo_black.png');
                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: CircleAvatar(
                                    radius: 24,
                                    backgroundImage: imageProvider,
                                    backgroundColor: Colors.grey.shade200,
                                  ),
                                  title: Text(
                                    order.productName.isNotEmpty
                                        ? order.productName
                                        : 'Товар #${order.productId}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 4),
                                      Text(
                                          'Статус: ${_getStatusText(order.status)}'),
                                      Text('Количество: ${order.quantity}'),
                                      Text(
                                          'Цена: ${order.price.toStringAsFixed(2)} ₽'),
                                      Text(
                                          'Покупатель: ${order.buyerName.isNotEmpty ? order.buyerName : 'Не указан'}'),
                                      if (order.createdAt != null)
                                        Text(
                                            'Дата: ${_formatDate(order.createdAt!)}'),
                                    ],
                                  ),
                                  trailing: _getStatusIcon(order.status),
                                  isThreeLine: true,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 12.0, bottom: 12.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          _showOrderDetails(context, order);
                                        },
                                        child: Text('Детали'),
                                      ),
                                      SizedBox(width: 8),
                                      if (order.status.toLowerCase() ==
                                          'pending')
                                        ElevatedButton(
                                          onPressed: () {
                                            _takeOrderInWork(order);
                                          },
                                          child: Text('Взять в работу'),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Ожидает обработки';
      case 'processing':
        return 'В обработке';
      case 'shipped':
        return 'Отправлен';
      case 'delivered':
        return 'Доставлен';
      case 'cancelled':
        return 'Отменен';
      default:
        return status;
    }
  }

  Widget _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icon(Icons.schedule, color: Colors.orange);
      case 'processing':
        return Icon(Icons.work, color: Colors.blue);
      case 'shipped':
        return Icon(Icons.local_shipping, color: Colors.green);
      case 'delivered':
        return Icon(Icons.check_circle, color: Colors.green);
      case 'cancelled':
        return Icon(Icons.cancel, color: Colors.red);
      default:
        return SizedBox.shrink();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  void _showOrderDetails(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Детали заказа #${order.id}',
          style: TextStyle(color: Colors.black),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Товар: ${order.productName.isNotEmpty ? order.productName : 'Товар #${order.productId}'}',
                style: TextStyle(color: Colors.black87),
              ),
              SizedBox(height: 8),
              Text('Статус: ${_getStatusText(order.status)}',
                  style: TextStyle(color: Colors.black87)),
              SizedBox(height: 8),
              Text('Количество: ${order.quantity}',
                  style: TextStyle(color: Colors.black87)),
              SizedBox(height: 8),
              Text('Цена: ${order.price.toStringAsFixed(2)} ₽',
                  style: TextStyle(color: Colors.black87)),
              SizedBox(height: 8),
              Text(
                  'Покупатель: ${order.buyerName.isNotEmpty ? order.buyerName : 'Не указан'}',
                  style: TextStyle(color: Colors.black87)),
              SizedBox(height: 8),
              Text('Координаты доставки:',
                  style: TextStyle(color: Colors.black87)),
              Text('  Широта: ${order.deliveryLatitude.toStringAsFixed(6)}',
                  style: TextStyle(color: Colors.black87)),
              Text('  Долгота: ${order.deliveryLongitude.toStringAsFixed(6)}',
                  style: TextStyle(color: Colors.black87)),
              if (order.createdAt != null) ...[
                SizedBox(height: 8),
                Text('Дата создания: ${_formatDate(order.createdAt!)}',
                    style: TextStyle(color: Colors.black87)),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Закрыть', style: TextStyle(color: Colors.black)),
          ),
          // Добавляем кнопку "Оформить заказ" для всех заказов
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processOrder(order);
            },
            child: Text('Оформить заказ'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
          // Оставляем кнопку "Взять в работу" только для pending заказов
          if (order.status.toLowerCase() == 'pending')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _takeOrderInWork(order);
              },
              child: Text('Взять в работу'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  // Изменяем метод _processOrder для перехода на карту как у техника
  void _processOrder(OrderModel order) {
    // Переходим на карту выбора точки посадки дрона (используем экран техника)
    Get.toNamed('/tech-pickup-location', arguments: order);
  }

  void _takeOrderInWork(OrderModel order) {
    Get.dialog(
      AlertDialog(
        title: Text('Взять заказ в работу'),
        content: Text('Вы уверены, что хотите взять этот заказ в работу?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Переход к экрану выбора точки отправки
              Get.toNamed('/seller-pickup-location', arguments: order);
            },
            child: Text('Взять в работу'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
