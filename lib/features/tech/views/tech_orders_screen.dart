import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/services/order_service.dart';
import '../../../data/models/order_model.dart';
import '../../../utils/helpers/hex_image.dart';

class TechOrdersScreen extends StatefulWidget {
  @override
  State<TechOrdersScreen> createState() => _TechOrdersScreenState();
}

class _TechOrdersScreenState extends State<TechOrdersScreen>
    with SingleTickerProviderStateMixin {
  final OrderService _orderService = Get.find<OrderService>();
  late Future<List<OrderModel>> _future;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _future = _orderService.getTechOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _orderService.getTechOrders();
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
    // Сначала загружаем локальную историю для быстрого отображения
    final localHistory = _orderService.techHistory();
    
    // Фильтруем заказы с сервера (завершенные или отмененные)
    final serverHistoryOrders = orders.where((order) {
      final status = order.status.toLowerCase();
      return status == 'delivered' || status == 'cancelled';
    }).toList();

    // Объединяем локальную и серверную историю, убираем дубликаты
    final allHistory = <OrderModel>[];
    final seenIds = <int>{};
    
    // Сначала добавляем серверные заказы
    for (final order in serverHistoryOrders) {
      if (seenIds.add(order.id)) {
        allHistory.add(order);
      }
    }
    
    // Затем добавляем локальные заказы, которых нет на сервере
    for (final order in localHistory) {
      if (seenIds.add(order.id)) {
        allHistory.add(order);
      }
    }

    // Сортируем по дате создания (новые сверху)
    allHistory.sort((a, b) {
      if (a.createdAt == null && b.createdAt == null) return 0;
      if (a.createdAt == null) return 1;
      if (b.createdAt == null) return -1;
      return b.createdAt!.compareTo(a.createdAt!);
    });

    // Возвращаем только последние 5 заказов
    return allHistory.take(5).toList();
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

  /// Время с сервера на 3 часа меньше московского — прибавляем 3 часа при отображении.
  String _formatOrderDate(DateTime? date) {
    if (date == null) return 'Дата не указана';
    final moscow = date.add(const Duration(hours: 3));
    final d = moscow.day.toString().padLeft(2, '0');
    final m = moscow.month.toString().padLeft(2, '0');
    final y = moscow.year;
    final h = moscow.hour.toString().padLeft(2, '0');
    final min = moscow.minute.toString().padLeft(2, '0');
    return '$d.$m.$y $h:$min';
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
                padding: EdgeInsets.all(16),
                itemCount: filteredOrders.length,
                itemBuilder: (context, index) {
                  final order = filteredOrders[index];
                  final imageProvider =
                      HexImage.resolveImageProvider(order.productImage) ??
                          const AssetImage('assets/logos/Logo_black.png');

                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
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
                              Text('Количество: ${order.quantity}'),
                              Text(
                                  'Цена: ${order.price.toStringAsFixed(2)} ₽'),
                              Text(
                                  'Дата: ${_formatOrderDate(order.createdAt ?? order.updatedAt)}'),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 12,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  _showOrderDetails(context, order, isActive);
                                },
                                child: Text('Детали'),
                              ),
                              // Кнопка "Взять в работу" показывается только для активных заказов
                              if (isActive) ...[
                                SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    // Переходим к экрану выбора точки посадки дрона
                                    Get.toNamed('/tech-pickup-location', arguments: order);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text('Взять в работу'),
                                ),
                              ],
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
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Детали заказа',
            style: TextStyle(color: Colors.black),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Товар: ${order.productName.isNotEmpty ? order.productName : 'Товар #${order.productId}'}',
                    style: TextStyle(color: Colors.black)),
                SizedBox(height: 8),
                Text('Количество: ${order.quantity}',
                    style: TextStyle(color: Colors.black)),
                SizedBox(height: 8),
                Text('Цена за единицу: ${order.price.toStringAsFixed(2)} ₽',
                    style: TextStyle(color: Colors.black)),
                SizedBox(height: 8),
                Text(
                    'Общая стоимость: ${(order.price * order.quantity).toStringAsFixed(2)} ₽',
                    style: TextStyle(color: Colors.black)),
                SizedBox(height: 8),
                Text(
                    'Покупатель: ${order.buyerName.isNotEmpty ? order.buyerName : 'Не указан'}',
                    style: TextStyle(color: Colors.black)),
                SizedBox(height: 8),
                Text(
                    'Координаты доставки: ${order.deliveryLatitude.toStringAsFixed(6)}, ${order.deliveryLongitude.toStringAsFixed(6)}',
                    style: TextStyle(color: Colors.black)),
                SizedBox(height: 8),
                Text(
                    'Дата создания: ${_formatOrderDate(order.createdAt ?? order.updatedAt)}',
                    style: TextStyle(color: Colors.black)),
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
                  // Переходим к экрану выбора точки посадки дрона
                  Get.toNamed('/tech-pickup-location', arguments: order);
                },
                child: Text('Взять в работу'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        );
      },
    );
  }
}
