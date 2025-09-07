import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/models/order_model.dart';
import '../../../utils/helpers/hex_image.dart';

class TechOrdersScreen extends StatefulWidget {
  @override
  State<TechOrdersScreen> createState() => _TechOrdersScreenState();
}

class _TechOrdersScreenState extends State<TechOrdersScreen> {
  final OrderRepository orderRepository = OrderRepository();
  late Future<List<OrderModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = orderRepository.fetchTechOrdersAsModels();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = orderRepository.fetchTechOrdersAsModels();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Заказы (Техник)'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Обновить',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: FutureBuilder<List<OrderModel>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  height: MediaQuery.of(context).size.height - 200,
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return Container(
                  height: MediaQuery.of(context).size.height - 200,
                  child: Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 48, color: Colors.red),
                      SizedBox(height: 16),
                      Text('Ошибка загрузки заказов:'),
                      SizedBox(height: 8),
                      Text(snapshot.error.toString(),
                          style: TextStyle(fontSize: 12),
                          textAlign: TextAlign.center),
                    ],
                  )),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Container(
                  height: MediaQuery.of(context).size.height - 200,
                  child: Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.engineering, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Нет заказов для обработки'),
                      SizedBox(height: 8),
                      Text('Все заказы обработаны или ожидают поступления',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                          textAlign: TextAlign.center),
                    ],
                  )),
                );
              } else {
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final order = snapshot.data![index];
                      final imageProvider =
                          HexImage.resolveImageProvider(order.productImage) ??
                              const AssetImage('assets/logos/Logo_black.png');

                      return Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
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
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4),
                                  Text(
                                      'Статус: ${_getStatusText(order.status)}'),
                                  Text('Количество: ${order.quantity}'),
                                  Text(
                                      'Цена: ${order.price.toStringAsFixed(2)} ₽'),
                                  Text(
                                      'Покупатель: ${order.buyerName.isNotEmpty ? order.buyerName : 'Не указан'}'),
                                  Text(
                                      'Продавец: ${order.sellerName.isNotEmpty ? order.sellerName : 'Не указан'}'),
                                  if (order.createdAt != null)
                                    Text(
                                        'Дата: ${_formatDate(order.createdAt!)}'),
                                  Text(
                                      'Координаты: ${order.deliveryLatitude.toStringAsFixed(6)}, ${order.deliveryLongitude.toStringAsFixed(6)}'),
                                ],
                              ),
                              trailing: _getStatusIcon(order.status),
                              isThreeLine: true,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: 12.0, bottom: 12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
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
                      );
                    },
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Ожидает обработки';
      case 'processing':
        return 'В обработке';
      case 'shipped':
        return 'Отправлен';
      case 'delivered':
        return 'Доставлен';
      case 'cancelled':
        return 'Отменен';
      case 'tech_review':
        return 'На техническом осмотре';
      case 'ready_for_delivery':
        return 'Готов к доставке';
      default:
        return status;
    }
  }

  Widget _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icon(Icons.schedule, color: Colors.orange);
      case 'processing':
        return Icon(Icons.work, color: Colors.blue);
      case 'shipped':
        return Icon(Icons.local_shipping, color: Colors.green);
      case 'delivered':
        return Icon(Icons.check_circle, color: Colors.green);
      case 'cancelled':
        return Icon(Icons.cancel, color: Colors.red);
      case 'tech_review':
        return Icon(Icons.engineering, color: Colors.purple);
      case 'ready_for_delivery':
        return Icon(Icons.delivery_dining, color: Colors.green);
      default:
        return SizedBox.shrink();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
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
              Text(
                'Товар: ${order.productName.isNotEmpty ? order.productName : 'Товар #${order.productId}'}',
                style: TextStyle(color: Colors.black87),
              ),
              SizedBox(height: 8),
              Text('Статус: ${_getStatusText(order.status)}',
                  style: TextStyle(color: Colors.black87)),
              SizedBox(height: 8),
              Text('Количество: ${order.quantity}',
                  style: TextStyle(color: Colors.black87)),
              SizedBox(height: 8),
              Text('Цена: ${order.price.toStringAsFixed(2)} ₽',
                  style: TextStyle(color: Colors.black87)),
              SizedBox(height: 8),
              Text(
                  'Покупатель: ${order.buyerName.isNotEmpty ? order.buyerName : 'Не указан'}',
                  style: TextStyle(color: Colors.black87)),
              SizedBox(height: 8),
              Text(
                  'Продавец: ${order.sellerName.isNotEmpty ? order.sellerName : 'Не указан'}',
                  style: TextStyle(color: Colors.black87)),
              SizedBox(height: 8),
              Text('Координаты доставки:',
                  style: TextStyle(color: Colors.black87)),
              Text('  Широта: ${order.deliveryLatitude.toStringAsFixed(6)}',
                  style: TextStyle(color: Colors.black87)),
              Text('  Долгота: ${order.deliveryLongitude.toStringAsFixed(6)}',
                  style: TextStyle(color: Colors.black87)),
              if (order.createdAt != null) ...[
                SizedBox(height: 8),
                Text('Дата создания: ${_formatDate(order.createdAt!)}',
                    style: TextStyle(color: Colors.black87)),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Закрыть', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Сразу переходим к экрану выбора точки посадки дрона
              Get.toNamed('/tech-pickup-location', arguments: order);
            },
            child: Text('Взять в работу'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _takeOrderInWork(OrderModel order) {
    // Убираем диалог подтверждения, сразу переходим к экрану
    Get.toNamed('/tech-pickup-location', arguments: order);
  }

  void _updateOrderStatus(int orderId, String newStatus) {
    // Здесь можно добавить логику обновления статуса заказа
    Get.snackbar(
      'Статус обновлен',
      'Заказ #$orderId взят в работу',
      duration: Duration(seconds: 2),
      backgroundColor: Colors.green,
      colorText: Colors.black,
    );
  }
}
