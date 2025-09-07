import 'package:flutter/material.dart';
import '../styles/colors.dart';

/// Кастомная тема текста для светлой и темной темы
class KTextTheme {
  KTextTheme._();

  /// **Светлая тема текста**
  static TextTheme lightTextTheme = TextTheme(
    // 🔹 Основные заголовки
    displayLarge: TextStyle(
        fontSize: 30.0,
        fontWeight: FontWeight.bold,
        color: KColors.textPrimary),
    displayMedium: TextStyle(
        fontSize: 26.0,
        fontWeight: FontWeight.bold,
        color: KColors.textPrimary),
    displaySmall: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
        color: KColors.textPrimary),

    // 🔹 Средние заголовки (H4-H6)
    headlineLarge: TextStyle(
        fontSize: 24.0, fontWeight: FontWeight.bold, color: KColors.primary),
    headlineMedium: TextStyle(
        fontSize: 20.0, fontWeight: FontWeight.w600, color: KColors.primary),
    headlineSmall: TextStyle(
        fontSize: 18.0, fontWeight: FontWeight.w500, color: KColors.primary),

    // 🔹 Основной текст
    bodyLarge: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.normal,
        color: KColors.textPrimary),
    bodyMedium: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.normal,
        color: KColors.textPrimary),
    bodySmall: TextStyle(
        fontSize: 12.0,
        fontWeight: FontWeight.normal,
        color: KColors.textSecondary),

    // 🔹 Подписи и кнопки
    titleLarge: TextStyle(
        fontSize: 18.0, fontWeight: FontWeight.bold, color: KColors.primary),
    titleMedium: TextStyle(
        fontSize: 16.0, fontWeight: FontWeight.bold, color: KColors.primary),
    titleSmall: TextStyle(
        fontSize: 14.0, fontWeight: FontWeight.bold, color: KColors.primary),

    // 🔹 Метки и подписи
    labelLarge: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        color: KColors.backgroundDark),
    labelMedium: TextStyle(
        fontSize: 12.0,
        fontWeight: FontWeight.w500,
        color: KColors.backgroundDark),
    labelSmall: TextStyle(
        fontSize: 10.0,
        fontWeight: FontWeight.w400,
        color: KColors.backgroundDark),
  );

  /// **Темная тема текста (белый текст)**
  static TextTheme darkTextTheme = TextTheme(
    // 🔹 Основные заголовки
    displayLarge: TextStyle(
        fontSize: 36.0, fontWeight: FontWeight.bold, color: Colors.white),
    displayMedium: TextStyle(
        fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.white),
    displaySmall: TextStyle(
        fontSize: 28.0, fontWeight: FontWeight.bold, color: Colors.white),

    // 🔹 Средние заголовки (H4-H6)
    headlineLarge: TextStyle(
        fontSize: 24.0, fontWeight: FontWeight.bold, color: KColors.accent),
    headlineMedium: TextStyle(
        fontSize: 20.0, fontWeight: FontWeight.w600, color: KColors.accent),
    headlineSmall: TextStyle(
        fontSize: 18.0, fontWeight: FontWeight.w500, color: KColors.accent),

    // 🔹 Основной текст
    bodyLarge: TextStyle(
        fontSize: 16.0, fontWeight: FontWeight.normal, color: Colors.white),
    bodyMedium: TextStyle(
        fontSize: 14.0, fontWeight: FontWeight.normal, color: Colors.white),
    bodySmall: TextStyle(
        fontSize: 12.0,
        fontWeight: FontWeight.normal,
        color: KColors.textSecondary),

    // 🔹 Подписи и кнопки
    titleLarge: TextStyle(
        fontSize: 18.0, fontWeight: FontWeight.bold, color: KColors.accent),
    titleMedium: TextStyle(
        fontSize: 16.0, fontWeight: FontWeight.bold, color: KColors.accent),
    titleSmall: TextStyle(
        fontSize: 14.0, fontWeight: FontWeight.bold, color: KColors.accent),

    // 🔹 Метки и подписи
    labelLarge: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        color: KColors.textSecondary),
    labelMedium: TextStyle(
        fontSize: 12.0, fontWeight: FontWeight.w500, color: KColors.buttonText),
    labelSmall: TextStyle(
        fontSize: 10.0,
        fontWeight: FontWeight.w400,
        color: KColors.textSecondary),
  );
}
