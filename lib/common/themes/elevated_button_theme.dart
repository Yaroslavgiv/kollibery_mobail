import 'package:flutter/material.dart';

import '../styles/colors.dart';

/* -- Light & Dark Elevated Button Themes -- */
class KElevatedButtonTheme {
  KElevatedButtonTheme._();

  static final lightElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: KColors.textPrimary,
      backgroundColor: KColors.buttonDark,
      textStyle: TextStyle(fontWeight: FontWeight.bold),
    ),
  );

  static final darkElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: KColors.textPrimary,
      backgroundColor: KColors.buttonDark,
      textStyle: TextStyle(fontWeight: FontWeight.bold),
    ),
  );
}
