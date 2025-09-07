// Главный класс приложения
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'common/themes/theme.dart';
import 'routes/app_routes.dart';

class App extends StatelessWidget {
  App({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    bool isLoggedIn = box.read('loggedIn') ?? false;
    final String role = box.read('role') ?? 'buyer';

    // Отладочная информация
    print('=== APP.DART DEBUG ===');
    print('isLoggedIn: $isLoggedIn');
    print('role from storage: $role');

    // Если пользователь не авторизован, идём на логин.
    // Если авторизован и роль - 'seller', идём на SellerMainScreen.
    // Если роль - 'tech', идём на TechMainScreen.
    // Иначе - на обычный MainScreen.
    final initialRoute = !isLoggedIn
        ? AppRoutes.login
        : (role == 'seller'
            ? AppRoutes.sellerHome
            : role == 'tech'
                ? AppRoutes.techHome
                : AppRoutes.home);

    print('initialRoute: $initialRoute');
    print('=== END DEBUG ===');
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.lightTheme, // Установка темной темы (по умолчанию)
      initialRoute: initialRoute, // Указание начального маршрута
      getPages: AppRoutes.pages, // Передача списка маршрутов в GetMaterialApp
      unknownRoute: GetPage(
        name: AppRoutes.notFound,
        page: () => Scaffold(
          body: Center(
            child: Text('Маршрут не найден'),
          ),
        ),
      ),
    );
  }
}
