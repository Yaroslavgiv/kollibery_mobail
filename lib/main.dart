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
  // Однократная очистка локальной истории заказов
  final box = GetStorage();
  final isHistoryCleared = box.read('local_history_cleared') == true;
  if (!isHistoryCleared) {
    await box.remove('seller_order_history');
    await box.remove('local_orders');
    await box.write('local_history_cleared', true);
  }

  // ВАЖНО: инициализация AuthController как singleton
  Get.put(AuthController(), permanent: true);

  runApp(App());
}
