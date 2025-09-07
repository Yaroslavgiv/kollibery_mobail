import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kollibry/app.dart';
import 'package:get/get.dart';
import 'features/auth/controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent, // прозрачный низ
    statusBarColor: Colors.transparent, // прозрачный верх (если нужно)
    systemNavigationBarIconBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.light,
  ));
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  await GetStorage.init(); // Инициализация GetStorage

  // ВАЖНО: инициализация AuthController как singleton
  Get.put(AuthController(), permanent: true);

  runApp(App());
}
