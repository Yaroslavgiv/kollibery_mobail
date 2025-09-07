import 'package:flutter/material.dart';
import '../../../common/styles/colors.dart';
import '../../../common/themes/theme.dart';

/// Кастомный виджет для текстового поля с поддержкой скрытия текста (для паролей).
class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final IconData? prefixIcon; // Добавлено поле для иконки

  const CustomTextField({
    Key? key,
    required this.hintText,
    required this.controller,
    this.obscureText = false,
    this.prefixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TAppTheme.lightTheme.textTheme.titleSmall,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TAppTheme
            .lightTheme.textTheme.titleSmall, // Используем текстовую тему
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: KColors.backgroundDark)
            : null,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: KColors.backgroundDark),
          borderRadius: BorderRadius.circular(12.0), // Закругленные углы
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: KColors.textCustom),
          borderRadius: BorderRadius.circular(12.0), // Закругленные углы
        ),
        filled: true,
        fillColor: KColors.backgroundLight, // Цвет фона из KColors
      ),
    );
  }
}
