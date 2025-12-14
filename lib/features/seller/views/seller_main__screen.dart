import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kollibry/common/themes/theme.dart';
import 'package:kollibry/routes/app_routes.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/models/order_model.dart';
import '../../home/models/product_model.dart';
import '../../home/widgets/product_grid.dart';
import '../../../common/styles/colors.dart';
import '../../../common/themes/text_theme.dart';
import '../../../utils/constants/strings.dart';
import '../../../utils/device/screen_util.dart';
import '../../../utils/helpers/hex_image.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class SellerMainScreen extends StatefulWidget {
  @override
  State<SellerMainScreen> createState() => _SellerMainScreenState();
}

class _SellerMainScreenState extends State<SellerMainScreen> {
  int _currentIndex = 0;
  final GetStorage box = GetStorage();
  final AuthController authController = Get.put(AuthController());
  final ProfileController profileController = Get.put(ProfileController());

  // Вкладки для продавца
  final List<Widget> _pages = [
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
      backgroundColor: TAppTheme.lightTheme.scaffoldBackgroundColor,
      drawer: Drawer(
        backgroundColor: TAppTheme.lightTheme.appBarTheme.shadowColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Obx(() {
              // Отображаем данные из ProfileController
              return Container(
                decoration: BoxDecoration(
                  color: KColors.primary,
                ),
                child: InkWell(
                  onTap: () {
                    Get.toNamed(AppRoutes.profile);
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: ScreenUtil.adaptiveHeight(50),
                      right: ScreenUtil.adaptiveHeight(30),
                      left: ScreenUtil.adaptiveHeight(20),
                      bottom: ScreenUtil.adaptiveHeight(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Фото профиля
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: KColors.backgroundLight,
                          backgroundImage: profileController
                                  .profileImage.value.isEmpty
                              ? null
                              : FileImage(
                                  File(profileController.profileImage.value)),
                          child: profileController.profileImage.value.isEmpty
                              ? Icon(Icons.person,
                                  size: 40, color: KColors.primary)
                              : null,
                        ),
                        SizedBox(height: ScreenUtil.adaptiveHeight(10)),
                        // Имя и фамилия
                        Text(
                          '${profileController.firstName.value} ${profileController.lastName.value}',
                          style: KTextTheme.lightTextTheme.displaySmall,
                        ),
                        SizedBox(height: ScreenUtil.adaptiveHeight(5)),
                        // Email
                        Text(
                          profileController.email.value,
                          style: KTextTheme.darkTextTheme.labelLarge,
                        ),
                        SizedBox(height: ScreenUtil.adaptiveHeight(5)),
                        // Телефон
                        Row(
                          children: [
                            Icon(Icons.phone,
                                color: KColors.textPrimary, size: 16),
                            SizedBox(width: ScreenUtil.adaptiveWidth(5)),
                            Text(
                              profileController.phone.value,
                              style: KTextTheme.darkTextTheme.labelLarge,
                            ),
                          ],
                        ),
                        SizedBox(height: ScreenUtil.adaptiveHeight(5)),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                color: KColors.textPrimary, size: 16),
                            SizedBox(width: ScreenUtil.adaptiveWidth(5)),
                            Flexible(
                              child: Text(
                                profileController.deliveryPoint.value,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: KColors.textPrimary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            }),
            ListTile(
              leading: Icon(Icons.dashboard, color: KColors.primary),
              title: Text(
                Strings.dashboard,
                style: KTextTheme.lightTextTheme.titleMedium,
              ),
              onTap: () {
                // Navigate to dashboard
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: KColors.primary),
              title: Text(
                Strings.settings,
                style: KTextTheme.lightTextTheme.titleMedium,
              ),
              onTap: () {
                // Navigate to settings
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '${Strings.appName} - ${_getRoleDisplayName()}',
          style: TAppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        backgroundColor: KColors.primary,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _showLogoutDialog,
            tooltip: 'Выйти из аккаунта',
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: KColors.backgroundLight.withOpacity(0.9), // Полупрозрачный фон
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.8),
              blurRadius: 10,
              offset: Offset(0, -2), // Тень сверху
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          iconSize: 30,
          currentIndex: _currentIndex,
          elevation: 8.0,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: KColors.buttonDark,
          unselectedItemColor: KColors.buttonText,
          items: [
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
                    hintText: Strings.searchHint,
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
                Text(
                  'Мои товары',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: ScreenUtil.adaptiveHeight(16)),
                FutureBuilder<List<ProductModel>>(
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
                            ProductGrid(
                              products: testProducts,
                              showCartButton:
                                  false, // Убираем корзину для продавца
                            ),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(16),
                            margin: EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.error, color: Colors.red),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Ошибка загрузки товаров: $errorMessage',
                                        style:
                                            TextStyle(color: Colors.red[800]),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Column(
                        children: [
                          SizedBox(height: 50),
                          Icon(Icons.inventory_2, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Товары не найдены'),
                        ],
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
                      // Для продавца используем ProductGrid без корзины
                      return ProductGrid(
                        products: products,
                        showCartButton: false, // Убираем корзину для продавца
                      );
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

// Экран списка заказов
class SellerOrdersScreen extends StatefulWidget {
  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen>
    with WidgetsBindingObserver {
  final OrderRepository orderRepository = OrderRepository();
  late Future<List<OrderModel>> _future;
  bool _isFirstBuild = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _future = orderRepository.fetchSellerOrdersAsModels();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Обновляем список заказов при возврате на экран (кроме первого раза)
    if (!_isFirstBuild) {
      _refresh();
    }
    _isFirstBuild = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Обновляем список заказов при возврате в приложение
    if (state == AppLifecycleState.resumed) {
      _refresh();
    }
  }

  Future<void> _refresh() async {
    print('🔄 Обновление списка заказов продавца...');
    final box = GetStorage();
    final currentUserId = box.read('userId');
    final currentRole = box.read('role');
    print('👤 Текущий пользователь: userId=$currentUserId, role=$currentRole');

    setState(() {
      _future = orderRepository.fetchSellerOrdersAsModels();
    });
    try {
      final orders = await _future;
      print('✅ Загружено ${orders.length} заказов для продавца');
      if (orders.isEmpty) {
        print('⚠️ ВНИМАНИЕ: Список заказов пуст!');
        print('   Возможные причины:');
        print('   1. Бэкенд не возвращает заказы для текущего продавца');
        print('   2. Заказы не связаны с продавцом по productId');
        print('   3. Токен не содержит правильную информацию о пользователе');
      } else {
        print('📋 Список заказов:');
        for (var order in orders) {
          print(
              '   - Заказ #${order.id}: ${order.productName} (productId: ${order.productId}, статус: ${order.status})');
          // Проверяем условия для кнопок
          final statusLower = order.status.toLowerCase();
          print('     Статус: "$statusLower"');
          print(
              '     Показывать "Взять в работу": ${statusLower == "pending"}');
          print(
              '     Показывать "Отправить товар": ${statusLower == "processing" || statusLower == "preparing"}');
        }
      }
    } catch (e) {
      print('❌ Ошибка загрузки заказов продавца: $e');
      print('   Stack trace: ${StackTrace.current}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(ScreenUtil.adaptiveWidth(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Заказы покупателей',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: _refresh,
                    tooltip: 'Обновить',
                  ),
                ],
              ),
              SizedBox(height: ScreenUtil.adaptiveHeight(16)),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: FutureBuilder<List<OrderModel>>(
                    future: _future,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ListView(
                          children: [
                            SizedBox(height: 200),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text('Загрузка заказов...'),
                                ],
                              ),
                            ),
                          ],
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

                        // Сортируем тестовые заказы от новых к старым
                        testOrders.sort((a, b) {
                          // Используем createdAt, если есть, иначе updatedAt, иначе очень старую дату
                          final dateA =
                              a.createdAt ?? a.updatedAt ?? DateTime(1970);
                          final dateB =
                              b.createdAt ?? b.updatedAt ?? DateTime(1970);
                          // Заказы без даты идут в конец
                          if (dateA == DateTime(1970) &&
                              dateB != DateTime(1970)) return 1;
                          if (dateB == DateTime(1970) &&
                              dateA != DateTime(1970)) return -1;
                          return dateB.compareTo(
                              dateA); // Обратный порядок: новые первыми
                        });

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
                                      style:
                                          TextStyle(color: Colors.orange[800]),
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
                                            backgroundColor:
                                                Colors.grey.shade200,
                                          ),
                                          title: Text(
                                            order.productName.isNotEmpty
                                                ? order.productName
                                                : 'Товар #${order.productId}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(height: 4),
                                              Text(
                                                  'Статус: ${_getStatusText(order.status)} (${order.status})'),
                                              Text(
                                                  'Количество: ${order.quantity}'),
                                              Text(
                                                  'Цена: ${order.price.toStringAsFixed(2)} ₽'),
                                              Text(
                                                  'Покупатель: ${order.buyerName.isNotEmpty ? order.buyerName : 'Не указан'}'),
                                              Text(
                                                  'Дата: ${_formatDate(order.createdAt ?? order.updatedAt ?? DateTime.now())}'),
                                            ],
                                          ),
                                          trailing:
                                              _getStatusIcon(order.status),
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
                                              // Кнопка "Отправить товар" для всех активных статусов кроме pending, delivered, cancelled
                                              if (order.status.toLowerCase() !=
                                                      'pending' &&
                                                  order.status.toLowerCase() !=
                                                      'delivered' &&
                                                  order.status.toLowerCase() !=
                                                      'cancelled')
                                                ElevatedButton(
                                                  onPressed: () {
                                                    _sendProduct(order);
                                                  },
                                                  child:
                                                      Text('Отправить товар'),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.green,
                                                    foregroundColor:
                                                        Colors.white,
                                                  ),
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
                        return ListView(
                          children: [
                            SizedBox(height: 100),
                            Icon(Icons.shopping_basket_outlined,
                                size: 48, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Нет заказов',
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Text('Покупатели пока не оформили заказы',
                                style:
                                    TextStyle(fontSize: 14, color: Colors.grey),
                                textAlign: TextAlign.center),
                          ],
                        );
                      } else {
                        // Сортируем заказы от новых к старым
                        final sortedOrders =
                            List<OrderModel>.from(snapshot.data!);
                        sortedOrders.sort((a, b) {
                          // Используем createdAt, если есть, иначе updatedAt, иначе очень старую дату
                          final dateA =
                              a.createdAt ?? a.updatedAt ?? DateTime(1970);
                          final dateB =
                              b.createdAt ?? b.updatedAt ?? DateTime(1970);
                          // Заказы без даты идут в конец
                          if (dateA == DateTime(1970) &&
                              dateB != DateTime(1970)) return 1;
                          if (dateB == DateTime(1970) &&
                              dateA != DateTime(1970)) return -1;
                          return dateB.compareTo(
                              dateA); // Обратный порядок: новые первыми
                        });

                        return ListView.builder(
                          itemCount: sortedOrders.length,
                          itemBuilder: (context, index) {
                            final order = sortedOrders[index];
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
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 4),
                                        Text(
                                            'Статус: ${_getStatusText(order.status)} (${order.status})'),
                                        Text('Количество: ${order.quantity}'),
                                        Text(
                                            'Цена: ${order.price.toStringAsFixed(2)} ₽'),
                                        Text(
                                            'Покупатель: ${order.buyerName.isNotEmpty ? order.buyerName : 'Не указан'}'),
                                        Text(
                                            'Дата: ${_formatDate(order.createdAt ?? order.updatedAt ?? DateTime.now())}'),
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
                                        // Кнопка "Отправить товар" для всех активных статусов кроме pending, delivered, cancelled
                                        if (order.status.toLowerCase() !=
                                                'pending' &&
                                            order.status.toLowerCase() !=
                                                'delivered' &&
                                            order.status.toLowerCase() !=
                                                'cancelled')
                                          ElevatedButton(
                                            onPressed: () {
                                              _sendProduct(order);
                                            },
                                            child: Text('Отправить товар'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                            ),
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
      case 'preparing':
        return 'Готовится';
      case 'in_transit':
        return 'В пути';
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
      case 'preparing':
        return Icon(Icons.inventory_2, color: Colors.blue.shade700);
      case 'in_transit':
        return Icon(Icons.local_shipping, color: Colors.green);
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
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day.$month.$year $hour:$minute';
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
              // Информация о товаре
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Информация о товаре:',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Название: ${order.productName.isNotEmpty ? order.productName : 'Товар #${order.productId}'}',
                      style: TextStyle(color: Colors.black),
                    ),
                    if (order.productDescription.isNotEmpty) ...[
                      SizedBox(height: 4),
                      Text(
                        'Описание: ${order.productDescription}',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                    if (order.productCategory.isNotEmpty) ...[
                      SizedBox(height: 4),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Категория: ${order.productCategory}',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 12),

              // Детали заказа
              Text(
                'Детали заказа:',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Text('Статус: ${_getStatusText(order.status)} (${order.status})',
                  style: TextStyle(color: Colors.black)),
              SizedBox(height: 8),
              Text('Количество: ${order.quantity}',
                  style: TextStyle(color: Colors.black)),
              SizedBox(height: 8),
              Text('Цена за единицу: ${order.price.toStringAsFixed(2)} ₽',
                  style: TextStyle(color: Colors.black)),
              SizedBox(height: 8),
              Text(
                  'Общая стоимость: ${(order.price * order.quantity).toStringAsFixed(2)} ₽',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  )),
              SizedBox(height: 8),
              Text(
                  'Продавец: ${order.sellerName.isNotEmpty ? order.sellerName : 'Не указан'}',
                  style: TextStyle(color: Colors.black)),
              SizedBox(height: 8),
              Text('Координаты доставки:',
                  style: TextStyle(color: Colors.black)),
              Text('  Широта: ${order.deliveryLatitude.toStringAsFixed(6)}',
                  style: TextStyle(color: Colors.black)),
              Text('  Долгота: ${order.deliveryLongitude.toStringAsFixed(6)}',
                  style: TextStyle(color: Colors.black)),
              SizedBox(height: 8),
              Text(
                  'Дата создания: ${_formatDate(order.createdAt ?? order.updatedAt ?? DateTime.now())}',
                  style: TextStyle(color: Colors.black)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Закрыть', style: TextStyle(color: Colors.black)),
          ),
          // Кнопка "Взять в работу" только для pending заказов
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
          // Кнопка "Отправить товар" для всех активных статусов кроме pending, delivered, cancelled
          if (order.status.toLowerCase() != 'pending' &&
              order.status.toLowerCase() != 'delivered' &&
              order.status.toLowerCase() != 'cancelled')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _sendProduct(order);
              },
              child: Text('Отправить товар'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  void _takeOrderInWork(OrderModel order) {
    Get.dialog(
      AlertDialog(
        title:
            Text('Взять заказ в работу', style: TextStyle(color: Colors.black)),
        content: Text('Вы уверены, что хотите взять этот заказ в работу?',
            style: TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Отмена', style: TextStyle(color: Colors.black)),
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

  void _sendProduct(OrderModel order) {
    Get.dialog(
      AlertDialog(
        title: Text('Отправить товар', style: TextStyle(color: Colors.black)),
        content: Text(
            'Вы уверены, что хотите отправить товар? Выберите точку отправки на карте.',
            style: TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Отмена', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Переход к экрану выбора точки отправки
              Get.toNamed('/seller-pickup-location', arguments: order);
            },
            child: Text('Отправить товар'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
