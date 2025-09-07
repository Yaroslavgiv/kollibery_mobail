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
import '../../favorites/views/favorites_screen.dart';
import '../../profile/controllers/profile_controller.dart'; // Импорт контроллера профиля
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final CartController cartController = Get.put(CartController());
  final ProfileController profileController = Get.put(ProfileController());
  final AuthController authController = Get.put(AuthController());
  final GetStorage box = GetStorage();

  final List<Widget> _pages = [
    HomePage(),
    FavoritesScreen(),
    CartScreen(),
  ];

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
            ListTile(
              leading: Icon(Icons.logout, color: KColors.primary),
              title: Text(
                Strings.logout,
                style: KTextTheme.lightTextTheme.titleMedium,
              ),
              onTap: () {
                authController.logout();
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
              icon: Icon(Icons.favorite),
              label: Strings.favorites,
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
