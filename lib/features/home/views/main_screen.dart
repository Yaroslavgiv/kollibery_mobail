import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kollibry/common/themes/theme.dart';
import 'package:kollibry/routes/app_routes.dart';
import 'package:get_storage/get_storage.dart';

import '../../../common/styles/colors.dart';
import '../../../common/themes/text_theme.dart';
import '../../../utils/constants/strings.dart';
import '../../../utils/device/screen_util.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../cart/views/cart_screen.dart';
import '../../orders/views/order_list_screen.dart';
import '../../profile/controllers/profile_controller.dart'; // Импорт контроллера профиля
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final CartController cartController = Get.put(CartController());
  // Пытаемся найти существующий контроллер, если нет - создаем новый
  late final ProfileController profileController;
  final AuthController authController = Get.put(AuthController());
  final GetStorage box = GetStorage();

  final List<Widget> _pages = [
    HomePage(),
    OrderListScreen(),
    CartScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Пытаемся найти существующий контроллер, если нет - создаем новый
    try {
      profileController = Get.find<ProfileController>();
    } catch (e) {
      profileController = Get.put(ProfileController());
    }
    
    // Загружаем данные профиля при инициализации экрана
    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileController.fetchProfileData();
    });
  }

  String _getRoleDisplayName() {
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Обновляем данные профиля при возврате на экран (например, после редактирования)
    profileController.fetchProfileData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TAppTheme.lightTheme.scaffoldBackgroundColor,
      onDrawerChanged: (isOpened) {
        // Обновляем данные профиля при открытии drawer
        if (isOpened) {
          profileController.fetchProfileData();
        }
      },
      drawer: Drawer(
        backgroundColor: TAppTheme.lightTheme.appBarTheme.shadowColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Obx(() {
              // Отображаем данные из ProfileController
              // Данные автоматически обновляются при изменении значений в контроллере
              return Container(
                decoration: BoxDecoration(
                  color: KColors.primary,
                ),
                child: InkWell(
                  onTap: () async {
                    // Обновляем данные перед переходом на экран профиля
                    await profileController.fetchProfileData();
                    // Переходим на экран профиля и ждем результат
                    final result = await Get.toNamed(AppRoutes.profile);
                    // Обновляем данные после возврата с экрана профиля
                    if (result == true || result == null) {
                      profileController.fetchProfileData();
                    }
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
                          (profileController.firstName.value.isNotEmpty || 
                           profileController.lastName.value.isNotEmpty)
                              ? '${profileController.firstName.value} ${profileController.lastName.value}'.trim()
                              : (profileController.email.value.isNotEmpty 
                                  ? profileController.email.value.split('@')[0]
                                  : 'Пользователь'),
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
                        // Убрали отображение геоданных (точки доставки)
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
              icon: Icon(Icons.home),
              label: Strings.home,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: Strings.orderHistory,
            ),
            BottomNavigationBarItem(
              icon: Obx(() {
                final count = cartController.cartItems.length;
                return Stack(
                  children: [
                    Icon(Icons.shopping_cart),
                    if (count > 0)
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$count',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                  ],
                );
              }),
              label: Strings.cart,
            ),
          ],
        ),
      ),
    );
  }
}
