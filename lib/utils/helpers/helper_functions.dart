import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class KHelperFunctions {
  static Color? getColor(String value) {
    final colorMap = {
      'Green': Colors.green,
      'Red': Colors.red,
      'Blue': Colors.blue,
      'Pink': Colors.pink,
      'Grey': Colors.grey,
      'Purple': Colors.purple,
      'Black': Colors.black,
      'White': Colors.white,
      'Yellow': Colors.yellow,
      'Orange': Colors.deepOrange,
      'Brown': Colors.brown,
      'Teal': Colors.teal,
      'Indigo': Colors.indigo
    };
    return colorMap[value];
  }

  static void showSnackBar(String message,
      {Duration duration = const Duration(seconds: 2)}) {
    // Всплывающие подсказки отключены по требованию
  }

  static void showAlert(String title, String message) {
    // Алерт-диалоги отключены по требованию
  }

  static void navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  static String truncateText(String text, int maxLength) {
    return text.length > maxLength
        ? '${text.substring(0, maxLength)}...'
        : text;
  }

  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Size screenSize() {
    return MediaQuery.of(Get.context!).size;
  }

  static double screenHeight() {
    return MediaQuery.of(Get.context!).size.height;
  }

  static double screenWidth() {
    return MediaQuery.of(Get.context!).size.width;
  }

  static String getFormattedDate(DateTime date,
      {String format = 'dd.MM.yyyy'}) {
    return DateFormat(format).format(date);
  }

  static List<T> removeDuplicates<T>(List<T> list) {
    return list.toSet().toList();
  }

  static List<Widget> wrapWidgets(List<Widget> widgets, int rowSize) {
    return [
      for (var i = 0; i < widgets.length; i += rowSize)
        Row(
            children: widgets.sublist(i,
                (i + rowSize > widgets.length) ? widgets.length : i + rowSize))
    ];
  }

  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}
