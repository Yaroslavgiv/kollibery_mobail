import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/styles/colors.dart';
import '../../../common/themes/text_theme.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_history_repository.dart';
import '../../../utils/device/screen_util.dart';
import '../../../utils/helpers/hex_image.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final OrderHistoryRepository _historyRepository = OrderHistoryRepository();
  late List<OrderModel> _historyOrders;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    setState(() {
      _historyOrders = _historyRepository.getOrderHistory();
    });
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Ожидает обработки';
      case 'processing':
        return 'В обработке';
      case 'preparing':
        return 'Готовится';
      case 'in_transit':
        return 'В пути';
      case 'shipped':
        return 'Отправлен';
      case 'delivered':
        return 'Доставлен';
      case 'cancelled':
        return 'Отменен';
      default:
        return status;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Дата не указана';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day.$month.$year $hour:$minute';
  }

  void _showOrderDetails(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Детали заказа #${order.id}',
          style: TextStyle(color: Colors.black),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Информация о товаре
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Информация о товаре:',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Название: ${order.productName.isNotEmpty ? order.productName : 'Товар #${order.productId}'}',
                      style: TextStyle(color: Colors.black),
                    ),
                    if (order.productDescription.isNotEmpty) ...[
                      SizedBox(height: 4),
                      Text(
                        'Описание: ${order.productDescription}',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                    if (order.productCategory.isNotEmpty) ...[
                      SizedBox(height: 4),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Категория: ${order.productCategory}',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 12),

              // Детали заказа
              Text(
                'Детали заказа:',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Text('Количество: ${order.quantity}',
                  style: TextStyle(color: Colors.black)),
              SizedBox(height: 8),
              Text('Цена за единицу: ${order.price.toStringAsFixed(2)} ₽',
                  style: TextStyle(color: Colors.black)),
              SizedBox(height: 8),
              Text(
                  'Общая стоимость: ${(order.price * order.quantity).toStringAsFixed(2)} ₽',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  )),
              SizedBox(height: 8),
              Text(
                  'Покупатель: ${order.buyerName.isNotEmpty ? order.buyerName : 'Не указан'}',
                  style: TextStyle(color: Colors.black)),
              SizedBox(height: 8),
              Text('Координаты доставки:',
                  style: TextStyle(color: Colors.black)),
              Text('  Широта: ${order.deliveryLatitude.toStringAsFixed(6)}',
                  style: TextStyle(color: Colors.black)),
              Text('  Долгота: ${order.deliveryLongitude.toStringAsFixed(6)}',
                  style: TextStyle(color: Colors.black)),
              SizedBox(height: 8),
              Text(
                  'Дата создания: ${_formatDate(order.createdAt ?? order.updatedAt)}',
                  style: TextStyle(color: Colors.black)),
              if (order.updatedAt != null && order.createdAt != null &&
                  order.updatedAt != order.createdAt) ...[
                SizedBox(height: 8),
                Text(
                    'Дата обновления: ${_formatDate(order.updatedAt)}',
                    style: TextStyle(color: Colors.black)),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Закрыть', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Future<void> _clearHistory() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Очистить историю',
          style: TextStyle(color: Colors.black),
        ),
        content: Text(
          'Вы уверены, что хотите очистить всю историю заказов?',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Отмена',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Очистить'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _historyRepository.clearHistory();
      _loadHistory();
      Get.snackbar(
        'Успех',
        'История заказов очищена',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(ScreenUtil.adaptiveWidth(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'История заказов',
                    style: KTextTheme.lightTextTheme.titleMedium?.copyWith(
                      color: KColors.textDark,
                    ),
                  ),
                  if (_historyOrders.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.delete_sweep),
                      onPressed: _clearHistory,
                      tooltip: 'Очистить историю',
                    ),
                ],
              ),
              SizedBox(height: ScreenUtil.adaptiveHeight(16)),
              Expanded(
                child: _historyOrders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history, size: 48, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'История заказов пуста',
                              style: TextStyle(
                                color: KColors.textDark,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Завершенные заказы будут отображаться здесь',
                              style: TextStyle(
                                color: KColors.textSecondary,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          _loadHistory();
                        },
                        child: ListView.builder(
                          itemCount: _historyOrders.length,
                          itemBuilder: (context, index) {
                            final order = _historyOrders[index];
                            final imageProvider = HexImage.resolveImageProvider(
                                    order.productImage) ??
                                const AssetImage('assets/logos/Logo_black.png');
                            return Card(
                              margin: EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: () => _showOrderDetails(context, order),
                                child: Column(
                                  children: [
                                    ListTile(
                                      leading: CircleAvatar(
                                        radius: 24,
                                        backgroundImage: imageProvider,
                                        backgroundColor: Colors.grey.shade200,
                                      ),
                                      title: Text(
                                        order.productName.isNotEmpty
                                            ? order.productName
                                            : 'Товар #${order.productId}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: KColors.textDark,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 4),
                                          Text(
                                            'Статус: ${_getStatusText(order.status)}',
                                            style: TextStyle(
                                              color: KColors.textDark,
                                            ),
                                          ),
                                          Text(
                                            'Количество: ${order.quantity}',
                                            style: TextStyle(
                                              color: KColors.textDark,
                                            ),
                                          ),
                                          Text(
                                            'Цена: ${order.price.toStringAsFixed(2)} ₽',
                                            style: TextStyle(
                                              color: KColors.textDark,
                                            ),
                                          ),
                                          Text(
                                            'Покупатель: ${order.buyerName.isNotEmpty ? order.buyerName : 'Не указан'}',
                                            style: TextStyle(
                                              color: KColors.textDark,
                                            ),
                                          ),
                                          Text(
                                            'Дата: ${_formatDate(order.createdAt ?? order.updatedAt)}',
                                            style: TextStyle(
                                              color: KColors.textDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                      isThreeLine: true,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 12.0, bottom: 12.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              _showOrderDetails(context, order);
                                            },
                                            child: Text('Детали'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
