import 'package:flutter/material.dart';

import '../styles/colors.dart';

class KAppBarTheme {
  KAppBarTheme._();

  static const lightAppBarTheme = AppBarTheme(
    shadowColor: KColors.arcBackground,
    iconTheme: IconThemeData(color: KColors.backgroundLight),
    backgroundColor: KColors.backgroundDark,
    titleTextStyle: TextStyle(
        fontSize: 22.0,
        fontWeight: FontWeight.bold,
        color: KColors.textPrimary),
  );

  static const darkAppBarTheme = AppBarTheme(
    shadowColor: KColors.backgroundLight,
    iconTheme: IconThemeData(color: KColors.backgroundLight),
    backgroundColor: KColors.backgroundDark,
    titleTextStyle: TextStyle(
        fontSize: 22.0,
        fontWeight: FontWeight.bold,
        color: KColors.textPrimary),
  );
}
