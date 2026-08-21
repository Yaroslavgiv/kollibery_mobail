import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kollibry/app.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kollibry/app.dart';

import 'core/constants/storage_keys.dart';
import 'core/di/app_bindings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    statusBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.light,
  ));

  await GetStorage.init();

  /// Однократная очистка устаревшей локальной истории.
  final box = GetStorage();
  final isHistoryCleared = box.read(StorageKeys.localHistoryCleared) == true;
  if (!isHistoryCleared) {
    await box.remove(StorageKeys.sellerOrderHistory);
    await box.remove(StorageKeys.localOrders);
    await box.write(StorageKeys.localHistoryCleared, true);
  }

  /// Регистрируем слои до запуска UI.
  AppBindings().dependencies();

  runApp(const App());
}

