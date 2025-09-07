import 'package:flutter/material.dart';

import '../styles/colors.dart';

class KChipTheme {
  KChipTheme._();

  static ChipThemeData lightChipTheme = ChipThemeData(
    disabledColor: KColors.textSecondary.withOpacity(0.4),
    labelStyle: const TextStyle(color: KColors.primary),
    selectedColor: KColors.accent,
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
    checkmarkColor: KColors.textPrimary,
  );

  static ChipThemeData darkChipTheme = const ChipThemeData(
    disabledColor: KColors.textSecondary,
    labelStyle: TextStyle(color: KColors.textPrimary),
    selectedColor: KColors.accent,
    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
    checkmarkColor: KColors.textPrimary,
  );
}
