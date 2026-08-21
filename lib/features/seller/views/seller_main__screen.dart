import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kollibry/common/themes/theme.dart';
import 'package:kollibry/routes/app_routes.dart';
import '../../../domain/services/order_service.dart';
import '../../../presentation/managers/catalog_manager.dart';
import '../../../data/models/order_model.dart';
import '../../home/models/product_model.dart';
import '../widgets/seller_product_card.dart';
import 'order_history_screen.dart';
import '../../../common/styles/colors.dart';
import '../../../common/themes/text_theme.dart';
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
  final AuthController authController = Get.find<AuthController>();
  // Пытаемся найти существующий контроллер, если нет - создаем новый
  late final ProfileController profileController;

  // Вкладки для продавца
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Пытаемся найти существующий контроллер, если нет - создаем новый
    profileController = Get.find<ProfileController>();

    _pages = [
      SellerProductsScreen(),
      SellerOrdersScreen(),
      OrderHistoryScreen(),
    ];

    // Загружаем данные профиля при инициализации экрана
    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileController.fetchProfileData();
    });
  }

  // Метод для обновления списка товаров
  void _refreshProductsList() {
    setState(() {
      _pages[0] = SellerProductsScreen();
    });
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
              return Container(
                decoration: BoxDecoration(
                  color: KColors.primary,
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed(AppRoutes.profile);
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: ScreenUtil.adaptiveHeight(50),
                      right: ScreenUtil.adaptiveHeight(30),
                      left: ScreenUtil.adaptiveWidth(20),
                      bottom: ScreenUtil.adaptiveHeight(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        Text(
                          (profileController.firstName.value.isNotEmpty ||
                                  profileController.lastName.value.isNotEmpty)
                              ? '${profileController.firstName.value} ${profileController.lastName.value}'
                                  .trim()
                              : (profileController.email.value.isNotEmpty
                                  ? profileController.email.value.split('@')[0]
                                  : 'Пользователь'),
                          style: KTextTheme.lightTextTheme.displaySmall,
                        ),
                        SizedBox(height: ScreenUtil.adaptiveHeight(5)),
                        Text(
                          profileController.email.value.isNotEmpty
                              ? profileController.email.value
                              : (box.read('email') ?? ''),
                          style: KTextTheme.darkTextTheme.labelLarge,
                        ),
                        SizedBox(height: ScreenUtil.adaptiveHeight(5)),
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
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('Продавец'),
        backgroundColor: KColors.primary,
        foregroundColor: Colors.white,
        actions: [
          // Кнопка "Добавить товар" только на вкладке "Мои товары"
          if (_currentIndex == 0)
            Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Get.toNamed('/add-edit-product');
                  if (result == true) {
                    // Обновляем список товаров
                    _refreshProductsList();
                  }
                },
                icon: Icon(Icons.add, color: Colors.white),
                label: Text(
                  'Добавить товар',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          // Кнопка "Выйти из аккаунта"
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _showLogoutDialog,
            tooltip: 'Выйти из аккаунта',
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: KColors.backgroundLight.withOpacity(0.9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.8),
              blurRadius: 10,
              offset: Offset(0, -2),
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
              // Обновляем историю заказов при переходе на вкладку истории
              if (index == 2) {
                _pages[2] = OrderHistoryScreen();
              }
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
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'История',
            ),
          ],
        ),
      ),
    );
  }
}

// Экран списка товаров
class SellerProductsScreen extends StatefulWidget {
  @override
  State<SellerProductsScreen> createState() => _SellerProductsScreenState();
}

class _SellerProductsScreenState extends State<SellerProductsScreen>
    with WidgetsBindingObserver {
  final CatalogManager catalogManager = Get.find<CatalogManager>();
  late Future<List<ProductModel>> _productsFuture;
  bool _isFirstBuild = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _productsFuture = catalogManager.fetchProducts();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Обновляем список товаров при возврате на экран (кроме первого раза)
    if (!_isFirstBuild) {
      _refreshProducts();
    }
    _isFirstBuild = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Обновляем список товаров при возврате в приложение
    if (state == AppLifecycleState.resumed) {
      _refreshProducts();
    }
  }

  void _refreshProducts() {
    setState(() {
      _productsFuture = catalogManager.fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: ScreenUtil.adaptiveWidth(16),
              right: ScreenUtil.adaptiveWidth(16),
              top: ScreenUtil.adaptiveHeight(16),
              bottom: ScreenUtil.adaptiveHeight(80), // Большой отступ снизу
            ),
            child: FutureBuilder<List<ProductModel>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(ScreenUtil.adaptiveHeight(50)),
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(ScreenUtil.adaptiveHeight(50)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 48, color: Colors.red),
                          SizedBox(height: 16),
                          Text(
                            'Ошибка загрузки товаров',
                            style: TextStyle(color: Colors.red),
                          ),
                          SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _refreshProducts,
                            child: Text('Повторить'),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(ScreenUtil.adaptiveHeight(50)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined,
                              size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Нет товаров',
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Нажмите + чтобы добавить товар',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: ScreenUtil.adaptiveWidth(10),
                      mainAxisSpacing: ScreenUtil.adaptiveHeight(10),
                      childAspectRatio: 0.8,
                    ),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return SellerProductCard(
                        product: snapshot.data![index],
                        onDeleted: () {
                          // Обновляем список товаров после удаления
                          _refreshProducts();
                        },
                      );
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

// Экран списка заказов продавца
class SellerOrdersScreen extends StatefulWidget {
  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen>
    with WidgetsBindingObserver {
  final OrderService _orderService = Get.find<OrderService>();
  late Future<List<OrderModel>> _future;
  bool _isFirstBuild = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _future = _orderService.getSellerOrders().then((orders) {
      orders.sort((a, b) => (b.createdAt ?? DateTime(1970))
          .compareTo(a.createdAt ?? DateTime(1970)));
      return orders;
    });
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

  /// Время с сервера на 3 часа меньше московского — прибавляем 3 часа при отображении.
  String _formatOrderDate(DateTime? date) {
    if (date == null) return 'Дата не указана';
    final moscow = date.add(const Duration(hours: 3));
    final d = moscow.day.toString().padLeft(2, '0');
    final m = moscow.month.toString().padLeft(2, '0');
    final y = moscow.year;
    final h = moscow.hour.toString().padLeft(2, '0');
    final min = moscow.minute.toString().padLeft(2, '0');
    return '$d.$m.$y $h:$min';
  }

  Future<void> _refresh() async {
    print('🔄 Обновление списка заказов продавца...');
    setState(() {
      _future = _orderService.getSellerOrders().then((orders) {
        print(
            '✅ Загружено ${orders.length} заказов для продавца (GET /order/getorders)');
        print(
            '🔍 ДИАГНОСТИКА: Список пришёл с сервера. Если только что удалили заказ и он всё ещё здесь — бэкенд не исключает удалённые заказы из getorders (проблема на сервере).');
        orders.sort((a, b) => (b.createdAt ?? DateTime(1970))
            .compareTo(a.createdAt ?? DateTime(1970)));
        if (orders.isEmpty) {
          print('⚠️ ВНИМАНИЕ: Список заказов пуст!');
          print('   Проверьте:');
          print('   1. Создан ли заказ покупателем');
          print('   2. Правильно ли бэкенд определяет продавца по productId');
          print('   3. Фильтрует ли бэкенд заказы по текущему продавцу');
        } else {
          print('📋 Список заказов:');
          for (final order in orders) {
            print(
                '   - Заказ #${order.id}: ${order.productName} (productId: ${order.productId})');
          }
        }
        return orders;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<List<OrderModel>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red),
                      SizedBox(height: 16),
                      Text('Ошибка загрузки заказов'),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _refresh,
                        child: Text('Повторить'),
                      ),
                    ],
                  ),
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
                    ],
                  ),
                );
              } else {
                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final order = snapshot.data![index];
                    final imageProvider =
                        HexImage.resolveImageProvider(order.productImage) ??
                            const AssetImage('assets/logos/Logo_black.png');
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
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
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Количество: ${order.quantity}'),
                                Text(
                                    'Цена: ${order.price.toStringAsFixed(2)} ₽'),
                                Text(
                                    'Дата: ${_formatOrderDate(order.createdAt ?? order.updatedAt)}'),
                              ],
                            ),
                            isThreeLine: true,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: 12,
                            ),
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
                                ElevatedButton(
                                  onPressed: () {
                                    _sendProduct(order);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text('Отправить товар'),
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
    );
  }

  void _showOrderDetails(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Детали заказа',
            style: TextStyle(color: Colors.black),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Товар: ${order.productName}',
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
                    style: TextStyle(color: Colors.black)),
                SizedBox(height: 8),
                Text(
                    'Покупатель: ${order.buyerName.isNotEmpty ? order.buyerName : 'Не указан'}',
                    style: TextStyle(color: Colors.black)),
                SizedBox(height: 8),
                Text(
                    'Координаты доставки: ${order.deliveryLatitude}, ${order.deliveryLongitude}',
                    style: TextStyle(color: Colors.black)),
                SizedBox(height: 8),
                Text(
                    'Дата создания: ${order.createdAt != null ? order.createdAt.toString().substring(0, 19) : 'Не указана'}',
                    style: TextStyle(color: Colors.black)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Закрыть', style: TextStyle(color: Colors.black)),
            ),
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
        );
      },
    );
  }

  void _sendProduct(OrderModel order) async {
    try {
      final orderToSave = OrderModel(
        id: order.id,
        userId: order.userId,
        productId: order.productId,
        quantity: order.quantity,
        deliveryLatitude: order.deliveryLatitude,
        deliveryLongitude: order.deliveryLongitude,
        status: 'shipped',
        productName: order.productName,
        productImage: order.productImage,
        price: order.price,
        buyerName: order.buyerName,
        sellerName: order.sellerName,
        createdAt: order.createdAt,
        updatedAt: DateTime.now(),
        productDescription: order.productDescription,
        productCategory: order.productCategory,
      );
      await _orderService.archiveDelivered(orderToSave);
      Get.toNamed('/seller-pickup-location', arguments: order);
    } catch (e) {
      print('❌ Ошибка при сохранении заказа в историю: $e');
    }
  }
}
