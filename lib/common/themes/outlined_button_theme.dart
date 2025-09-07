import 'package:flutter/material.dart';

import '../styles/colors.dart';
import '../styles/sizes.dart';

/* -- Light & Dark Outlined Button Themes -- */
class KOutlinedButtonTheme {
  KOutlinedButtonTheme._(); // To avoid creating instances

  static final lightOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: KColors.primary,
      side: const BorderSide(color: KColors.primary),
      textStyle: const TextStyle(
        fontSize: 16,
        color: KColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: KSizes.buttonHeight,
        horizontal: 20,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KSizes.buttonRadius),
      ),
    ),
  );

  static final darkOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: KColors.textPrimary,
      side: const BorderSide(color: KColors.textPrimary),
      textStyle: const TextStyle(
        fontSize: 16,
        color: KColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: KSizes.buttonHeight,
        horizontal: 20,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KSizes.buttonRadius),
      ),
    ),
  );
}
