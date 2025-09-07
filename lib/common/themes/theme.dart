import 'package:flutter/material.dart';
import '../styles/colors.dart';
import 'appbar_theme.dart';
import 'bottom_sheet_theme.dart';
import 'chip_theme.dart';
import 'elevated_button_theme.dart';
import 'outlined_button_theme.dart';
import 'text_field_theme.dart';
import 'text_theme.dart';

/// Основной класс для управления темами приложения
class TAppTheme {
  TAppTheme._();

  /// **Светлая тема**
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Poppins',
    primaryColor: KColors.primary,
    focusColor: KColors.buttonText,
    hintColor: KColors.backgroundChipLight,
    scaffoldBackgroundColor: KColors.backgroundLight,
    textTheme: KTextTheme.lightTextTheme,
    appBarTheme: KAppBarTheme.lightAppBarTheme,
    elevatedButtonTheme: KElevatedButtonTheme.lightElevatedButtonTheme,
    outlinedButtonTheme: KOutlinedButtonTheme.lightOutlinedButtonTheme,
    inputDecorationTheme: KTextFormFieldTheme.lightInputDecorationTheme,
    chipTheme: KChipTheme.lightChipTheme,
    bottomSheetTheme: KBottomSheetTheme.lightBottomSheetTheme,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: KColors.backgroundLight,
      selectedItemColor: KColors.primary,
      unselectedItemColor: KColors.textSecondary,
      elevation: 10,
    ),
    colorScheme: ColorScheme.light(
      primary: KColors.primary,
      secondary: KColors.accent,
      background: KColors.backgroundLight,
      surface: KColors.backgroundLight,
    ),
  );

  /// **Темная тема**
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Poppins',
    primaryColor: KColors.primary,
    focusColor: KColors.textSecondary,
    hintColor: KColors.textDark,
    scaffoldBackgroundColor: KColors.backgroundDark,
    textTheme: KTextTheme.darkTextTheme,
    appBarTheme: KAppBarTheme.darkAppBarTheme.copyWith(
      backgroundColor: KColors.primary,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: KElevatedButtonTheme.darkElevatedButtonTheme,
    outlinedButtonTheme: KOutlinedButtonTheme.darkOutlinedButtonTheme,
    inputDecorationTheme: KTextFormFieldTheme.darkInputDecorationTheme,
    chipTheme: KChipTheme.darkChipTheme,
    bottomSheetTheme: KBottomSheetTheme.darkBottomSheetTheme,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: KColors.backgroundDark,
      selectedItemColor: Colors.white, // Выбранный элемент — белый
      unselectedItemColor: KColors.textSecondary,
      elevation: 10,
    ),
    colorScheme: ColorScheme.dark(
      primary: KColors.primary,
      secondary: KColors.accent,
      background: KColors.backgroundDark,
      surface: KColors.backgroundDark,
    ),
  );
}
