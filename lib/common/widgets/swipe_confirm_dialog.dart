import 'package:flutter/material.dart';

/// Универсальный диалог подтверждения действия
class SwipeConfirmDialog extends StatefulWidget {
  /// Заголовок диалога
  final String title;

  /// Текст сообщения
  final String message;

  /// Текст на кнопке подтверждения
  final String confirmText;

  /// Текст на кнопке отмены
  final String cancelText;

  /// Цвет кнопки подтверждения
  final Color confirmColor;

  /// Функция, которая будет вызвана при подтверждении
  final VoidCallback onConfirm;

  /// Иконка для диалога (опционально)
  final IconData? icon;

  /// Цвет иконки (опционально)
  final Color? iconColor;

  const SwipeConfirmDialog({
    Key? key,
    required this.title,
    required this.message,
    this.confirmText = 'Подтвердить',
    this.cancelText = 'Отмена',
    this.confirmColor = Colors.blue,
    required this.onConfirm,
    this.icon,
    this.iconColor,
  }) : super(key: key);

  /// Статический метод для показа диалога
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Подтвердить',
    String cancelText = 'Отмена',
    Color confirmColor = Colors.blue,
    required VoidCallback onConfirm,
    IconData? icon,
    Color? iconColor,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SwipeConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
        onConfirm: onConfirm,
        icon: icon,
        iconColor: iconColor,
      ),
    );
  }

  @override
  State<SwipeConfirmDialog> createState() => _SwipeConfirmDialogState();
}

class _SwipeConfirmDialogState extends State<SwipeConfirmDialog> {
  void _confirmAction() {
    Navigator.of(context).pop(true);
    widget.onConfirm();
  }

  void _cancelAction() {
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          if (widget.icon != null) ...[
            Icon(
              widget.icon,
              color: widget.iconColor ?? widget.confirmColor,
              size: 28,
            ),
            SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              widget.title,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        widget.message,
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: _cancelAction,
          child: Text(
            widget.cancelText,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _confirmAction,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.confirmColor,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            widget.confirmText,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
