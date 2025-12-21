import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/models/order_model.dart';
import '../../../utils/helpers/hex_image.dart';
import '../../../common/widgets/swipe_confirm_dialog.dart';

class TechOrdersScreen extends StatefulWidget {
  @override
  State<TechOrdersScreen> createState() => _TechOrdersScreenState();
}

class _TechOrdersScreenState extends State<TechOrdersScreen>
    with SingleTickerProviderStateMixin {
  final OrderRepository orderRepository = OrderRepository();
  late Future<List<OrderModel>> _future;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _future = orderRepository.fetchTechOrdersAsModels();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = orderRepository.fetchTechOrdersAsModels();
    });
    await _future;
  }

  // Фильтрация активных заказов (не завершенных и не отмененных)
  List<OrderModel> _getActiveOrders(List<OrderModel> orders) {
    final activeOrders = orders.where((order) {
      final status = order.status.toLowerCase();
      return status != 'delivered' && status != 'cancelled';
    }).toList();

    // Сортируем по дате создания (новые сверху)
    activeOrders.sort((a, b) {
      if (a.createdAt == null && b.createdAt == null) return 0;
      if (a.createdAt == null) return 1;
      if (b.createdAt == null) return -1;
      return b.createdAt!.compareTo(a.createdAt!);
    });

    return activeOrders;
  }

  // Фильтрация истории заказов (завершенных или отмененных)
  List<OrderModel> _getHistoryOrders(List<OrderModel> orders) {
    final historyOrders = orders.where((order) {
      final status = order.status.toLowerCase();
      return status == 'delivered' || status == 'cancelled';
    }).toList();

    // Сортируем по дате создания (новые сверху)
    historyOrders.sort((a, b) {
      if (a.createdAt == null && b.createdAt == null) return 0;
      if (a.createdAt == null) return 1;
      if (b.createdAt == null) return -1;
      return b.createdAt!.compareTo(a.createdAt!);
    });

    // Возвращаем только последние 5 заказов
    return historyOrders.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Заказы (Техник)'),
        backgroundColor: Colors.blue,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              icon: Icon(Icons.work),
              text: 'Активные',
            ),
            Tab(
              icon: Icon(Icons.history),
              text: 'История',
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Обновить',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Вкладка активных заказов
          _buildOrdersList(true),
          // Вкладка истории заказов
          _buildOrdersList(false),
        ],
      ),
    );
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
      case 'preparing':
        return Icon(Icons.inventory_2, color: Colors.blue.shade700);
      case 'in_transit':
        return Icon(Icons.local_shipping, color: Colors.green);
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

  Widget _buildOrdersList(bool isActive) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder<List<OrderModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Ошибка загрузки заказов:'),
                  SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isActive ? Icons.engineering : Icons.history,
                    size: 48,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    isActive ? 'Нет активных заказов' : 'История заказов пуста',
                  ),
                  SizedBox(height: 8),
                  Text(
                    isActive
                        ? 'Все заказы обработаны или ожидают поступления'
                        : 'Завершенные заказы будут отображаться здесь',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else {
            final allOrders = snapshot.data!;
            final filteredOrders = isActive
                ? _getActiveOrders(allOrders)
                : _getHistoryOrders(allOrders);

            if (filteredOrders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isActive ? Icons.engineering : Icons.history,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      isActive
                          ? 'Нет активных заказов'
                          : 'История заказов пуста',
                    ),
                    SizedBox(height: 8),
                    Text(
                      isActive
                          ? 'Все заказы обработаны или ожидают поступления'
                          : 'Завершенные заказы будут отображаться здесь',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                itemCount: filteredOrders.length,
                itemBuilder: (context, index) {
                  final order = filteredOrders[index];
                  final imageProvider =
                      HexImage.resolveImageProvider(order.productImage) ??
                          const AssetImage('assets/logos/Logo_black.png');

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                              Text('Статус: ${_getStatusText(order.status)}'),
                              Text('Количество: ${order.quantity}'),
                              Text('Цена: ${order.price.toStringAsFixed(2)} ₽'),
                              Text(
                                  'Продавец: ${order.sellerName.isNotEmpty ? order.sellerName : 'Не указан'}'),
                              if (order.createdAt != null)
                                Text('Дата: ${_formatDate(order.createdAt!)}'),
                              Text(
                                  'Координаты: ${order.deliveryLatitude.toStringAsFixed(6)}, ${order.deliveryLongitude.toStringAsFixed(6)}'),
                            ],
                          ),
                          trailing: _getStatusIcon(order.status),
                          isThreeLine: true,
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(right: 12.0, bottom: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  _showOrderDetails(context, order, isActive);
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
    );
  }

  void _showOrderDetails(
      BuildContext context, OrderModel order, bool isActive) {
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
                  'Продавец: ${order.sellerName.isNotEmpty ? order.sellerName : 'Не указан'}',
                  style: TextStyle(color: Colors.black)),
              SizedBox(height: 8),
              Text('Координаты доставки:',
                  style: TextStyle(color: Colors.black)),
              Text('  Широта: ${order.deliveryLatitude.toStringAsFixed(6)}',
                  style: TextStyle(color: Colors.black)),
              Text('  Долгота: ${order.deliveryLongitude.toStringAsFixed(6)}',
                  style: TextStyle(color: Colors.black)),
              if (order.createdAt != null) ...[
                SizedBox(height: 8),
                Text('Дата создания: ${_formatDate(order.createdAt!)}',
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
          // Кнопка "Взять в работу" показывается только для активных заказов
          if (isActive)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                SwipeConfirmDialog.show(
                  context: context,
                  title: 'Взять заказ в работу',
                  message:
                      'Вы уверены, что хотите взять заказ #${order.id} в работу?',
                  confirmText: 'Взять в работу',
                  confirmColor: Colors.blue,
                  icon: Icons.work,
                  onConfirm: () {
                    // Переходим к экрану выбора точки посадки дрона
                    Get.toNamed('/tech-pickup-location', arguments: order);
                  },
                );
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
}
