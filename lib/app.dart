import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'common/themes/theme.dart';
import 'presentation/providers/session_provider.dart';
import 'routes/app_routes.dart';

/// Корневой виджет. Маршрут выбирает SessionProvider, а не View.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.lightTheme,
      initialRoute: Get.find<SessionProvider>().initialRoute,
      getPages: AppRoutes.pages,
      unknownRoute: GetPage(
        name: AppRoutes.notFound,
        page: () => const Scaffold(
          body: Center(
            child: Text('Маршрут не найден'),
          ),
        ),
      ),
    );
  }
}
