import 'package:flutter/material.dart';

/// Универсальный диалог подтверждения действия с возможностью подтверждения свайпом
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

class _SwipeConfirmDialogState extends State<SwipeConfirmDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _dragPosition = 0.0;
  bool _isConfirmed = false;
  final double _maxDragDistance = 200.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragPosition += details.primaryDelta ?? 0.0;
      if (_dragPosition < 0) _dragPosition = 0;
      if (_dragPosition > _maxDragDistance) {
        _dragPosition = _maxDragDistance;
        if (!_isConfirmed) {
          _isConfirmed = true;
          _controller.forward();
        }
      } else {
        if (_isConfirmed) {
          _isConfirmed = false;
          _controller.reverse();
        }
      }
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dragPosition >= _maxDragDistance * 0.8) {
      // Подтверждение при достижении 80% расстояния
      _confirmAction();
    } else {
      // Возврат в исходное положение
      setState(() {
        _dragPosition = 0.0;
        _isConfirmed = false;
        _controller.reset();
      });
    }
  }

  void _confirmAction() {
    Navigator.of(context).pop(true);
    widget.onConfirm();
  }

  void _cancelAction() {
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_dragPosition / _maxDragDistance).clamp(0.0, 1.0);

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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.message,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          // Кнопка свайпа для подтверждения
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.grey[400]!,
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                // Фон прогресса
                AnimatedContainer(
                  duration: Duration(milliseconds: 100),
                  decoration: BoxDecoration(
                    color: widget.confirmColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  width: _dragPosition,
                ),
                // Кнопка свайпа
                Positioned(
                  left: _dragPosition.clamp(0.0, _maxDragDistance - 56),
                  child: GestureDetector(
                    onHorizontalDragUpdate: _onDragUpdate,
                    onHorizontalDragEnd: _onDragEnd,
                    child: Container(
                      width: 56,
                      height: 56,
                      margin: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Color.lerp(
                          widget.confirmColor,
                          Colors.green,
                          progress,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isConfirmed ? Icons.check : Icons.arrow_forward,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
                // Текст инструкции
                Center(
                  child: Text(
                    _isConfirmed
                        ? 'Отпустите для подтверждения'
                        : 'Свайпните для подтверждения',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Или используйте кнопки ниже',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
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
