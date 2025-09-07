import 'package:flutter/material.dart';
import 'package:kollibry/common/styles/sizes.dart';

import '../../../common/styles/colors.dart';

/// Кастомный виджет для кнопки с закругленными углами.
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({Key? key, required this.text, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,

      style: ElevatedButton.styleFrom(
        backgroundColor: KColors.primary, // Основной цвет кнопки.
        minimumSize:
            Size(double.infinity, KSizes.buttonElevationAuth), // Размер кнопки.
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              KSizes.borderRadiusLg), // Закругленные углы.
        ),
      ),
      child: Text(
        text,
        style: TextStyle(color: KColors.borderLight),
      ), // Текст кнопки.
    );
  }
}
