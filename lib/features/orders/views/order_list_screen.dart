import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../../../common/styles/colors.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/models/order_model.dart';
import '../../../utils/helpers/hex_image.dart';

/// Экран истории заказов для покупателя
class OrderListScreen extends StatefulWidget {
  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen>
    with WidgetsBindingObserver {
  final OrderRepository orderRepository = OrderRepository();
  late Future<List<OrderModel>> _future;
  bool _isFirstBuild = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _future = _loadBuyerOrders();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Обновляем список заказов при возврате на экран (кроме первого раза)
    if (!_isFirstBuild) {
      _refresh();
    }
    _isFirstBuild = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Обновляем список заказов при возврате в приложение
    if (state == AppLifecycleState.resumed) {
      _refresh();
    }
  }

  /// Загрузка заказов покупателя
  Future<List<OrderModel>> _loadBuyerOrders() async {
    try {
      // Используем fetchOrdersByRole для получения заказов покупателя
      final ordersData = await orderRepository.fetchOrdersByRole('buyer');
      final orders =
          ordersData.map((data) => OrderModel.fromJson(data)).toList();
      // Применяем локально сохраненные статусы
      final ordersWithLocalStatuses = _applyLocalStatuses(orders);

      // Добавляем локально сохраненные заказы (если API не вернул их)
      final localOrders = _getLocalOrders();
      final allOrders = <OrderModel>[];

      // Добавляем заказы с сервера
      allOrders.addAll(ordersWithLocalStatuses);

      // Добавляем локальные заказы, которых нет на сервере
      for (final localOrder in localOrders) {
        if (!allOrders.any((o) => o.id == localOrder.id)) {
          allOrders.add(localOrder);
        }
      }

      // Сортируем от новых к старым
      allOrders.sort((a, b) {
        final dateA = a.createdAt ?? DateTime(1970);
        final dateB = b.createdAt ?? DateTime(1970);
        return dateB.compareTo(dateA);
      });

      return allOrders;
    } catch (e) {
      print('Ошибка загрузки заказов покупателя: $e');
      // При ошибке возвращаем только локальные заказы
      return _getLocalOrders();
    }
  }

  /// Получение локально сохраненных заказов
  List<OrderModel> _getLocalOrders() {
    final box = GetStorage();
    final localOrdersData = box.read<List<dynamic>>('local_orders') ?? [];
    return localOrdersData
        .map((data) {
          try {
            if (data is Map<String, dynamic>) {
              return OrderModel.fromJson(data);
            }
            return null;
          } catch (e) {
            print('Ошибка парсинга локального заказа: $e');
            return null;
          }
        })
        .whereType<OrderModel>()
        .toList();
  }

  /// Применение локально сохраненных статусов к списку заказов
  List<OrderModel> _applyLocalStatuses(List<OrderModel> orders) {
    // Получаем локальные статусы из хранилища
    final box = GetStorage();
    final statuses = box.read<Map<String, dynamic>>('order_statuses') ?? {};

    if (statuses.isEmpty) {
      return orders;
    }

    return orders.map((order) {
      final localStatus = statuses[order.id.toString()] as String?;
      if (localStatus != null && localStatus != order.status) {
        // Создаем новый заказ с обновленным статусом
        return OrderModel(
          id: order.id,
          userId: order.userId,
          productId: order.productId,
          quantity: order.quantity,
          deliveryLatitude: order.deliveryLatitude,
          deliveryLongitude: order.deliveryLongitude,
          status: localStatus,
          productName: order.productName,
          productImage: order.productImage,
          price: order.price,
          buyerName: order.buyerName,
          sellerName: order.sellerName,
          createdAt: order.createdAt,
          updatedAt: DateTime.now(),
          productDescription: order.productDescription,
          productCategory: order.productCategory,
        );
      }
      return order;
    }).toList();
  }

  /// Обновление списка заказов
  Future<void> _refresh() async {
    setState(() {
      _future = _loadBuyerOrders();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('История заказов'),
        backgroundColor: KColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Обновить',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<OrderModel>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Загрузка заказов...'),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Ошибка загрузки заказов',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refresh,
                      child: Text('Повторить попытку'),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_bag_outlined,
                        size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'История заказов пуста',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Вы еще не делали заказы',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            } else {
              // Сортируем заказы по дате создания (новые сверху)
              // Последний заказ будет первым в списке, более старые - ниже
              final sortedOrders = List<OrderModel>.from(snapshot.data!);
              sortedOrders.sort((a, b) {
                if (a.createdAt == null && b.createdAt == null) return 0;
                if (a.createdAt == null) return 1; // Заказы без даты в конец
                if (b.createdAt == null) return -1; // Заказы без даты в конец
                return b.createdAt!
                    .compareTo(a.createdAt!); // Новые сверху (убывание)
              });

              // Берем только последние 5 заказов (первые 5 после сортировки)
              final last5Orders = sortedOrders.take(5).toList();

              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: last5Orders.length,
                itemBuilder: (context, index) {
                  final order = last5Orders[index];
                  final imageProvider =
                      HexImage.resolveImageProvider(order.productImage) ??
                          const AssetImage('assets/logos/Logo_black.png');

                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () {
                        _showOrderDetails(context, order);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Изображение товара
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image(
                                image: imageProvider,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 12),
                            // Информация о заказе
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order.productName.isNotEmpty
                                        ? order.productName
                                        : 'Товар #${order.productId}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Количество: ${order.quantity}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '${(order.price * order.quantity).toStringAsFixed(2)} ₽',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: KColors.primary,
                                    ),
                                  ),
                                  if (order.createdAt != null) ...[
                                    SizedBox(height: 4),
                                    Text(
                                      _formatDate(order.createdAt!),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  /// Форматирование даты с временем. Время с сервера на 3 часа меньше московского — прибавляем 3 часа при отображении.
  String _formatDate(DateTime date) {
    final moscow = date.add(const Duration(hours: 3));
    final day = moscow.day.toString().padLeft(2, '0');
    final month = moscow.month.toString().padLeft(2, '0');
    final year = moscow.year;
    final hour = moscow.hour.toString().padLeft(2, '0');
    final minute = moscow.minute.toString().padLeft(2, '0');
    return '$day.$month.$year $hour:$minute';
  }

  /// Показ деталей заказа
  void _showOrderDetails(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Заказ #${order.id}',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
                      'Товар:',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      order.productName.isNotEmpty
                          ? order.productName
                          : 'Товар #${order.productId}',
                      style: TextStyle(color: Colors.black),
                    ),
                    if (order.productDescription.isNotEmpty) ...[
                      SizedBox(height: 4),
                      Text(
                        order.productDescription,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
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
                  fontSize: 16,
                ),
              ),
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
        ],
      ),
    );
  }
}
