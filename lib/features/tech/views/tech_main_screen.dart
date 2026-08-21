import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kollibry/common/themes/theme.dart';
import 'package:kollibry/routes/app_routes.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../../common/styles/colors.dart';
import '../../../common/themes/text_theme.dart';
import '../../../utils/device/screen_util.dart';
import 'tech_products_screen.dart';
import 'tech_orders_screen.dart';
import 'tech_drone_screen.dart';
import 'tech_dronebox_screen.dart';

class TechMainScreen extends StatefulWidget {
  @override
  _TechMainScreenState createState() => _TechMainScreenState();
}

class _TechMainScreenState extends State<TechMainScreen> {
  int _selectedIndex = 0;
  final GetStorage box = GetStorage();
  final AuthController authController = Get.find<AuthController>();
  // Пытаемся найти существующий контроллер, если нет - создаем новый
  late final ProfileController profileController;

  final List<Widget> _screens = [
    TechProductsScreen(),
    TechOrdersScreen(),
    TechDroneScreen(),
    TechDroneboxScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Пытаемся найти существующий контроллер, если нет - создаем новый
    profileController = Get.find<ProfileController>();
    
    // Загружаем данные профиля при инициализации экрана
    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileController.fetchProfileData();
    });
  }

  String _getRoleDisplayName() {
    final role = box.read('role') ?? 'tech';
    switch (role) {
      case 'buyer':
        return 'Покупатель';
      case 'seller':
        return 'Продавец';
      case 'tech':
      case 'technician':
        return 'Техник';
      default:
        return 'Техник';
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
                      left: ScreenUtil.adaptiveWidth(20),
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
                          profileController.email.value.isNotEmpty
                              ? profileController.email.value
                              : (box.read('email') ?? ''),
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
                              profileController.phone.value.isNotEmpty
                                  ? profileController.phone.value
                                  : 'Телефон не указан',
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
        title: Text('Роль: ${_getRoleDisplayName()}'),
        backgroundColor: KColors.primary,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _showLogoutDialog,
            tooltip: 'Выйти из аккаунта',
          ),
        ],
      ),
      body: _screens[_selectedIndex],
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
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          elevation: 8.0,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: KColors.buttonDark,
          unselectedItemColor: KColors.buttonText,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Покупатель',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt),
              label: 'Продавец',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.flight),
              label: 'Дрон',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_remote),
              label: 'Дронбокс',
            ),
          ],
        ),
      ),
    );
  }
}
