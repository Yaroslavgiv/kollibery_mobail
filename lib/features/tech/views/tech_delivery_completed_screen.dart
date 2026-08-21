import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../presentation/managers/device_command_manager.dart';
import '../../../common/widgets/swipe_confirm_dialog.dart';
import '../../../data/models/order_model.dart';
import '../../../domain/services/order_service.dart';

class TechDeliveryCompletedScreen extends StatefulWidget {
  const TechDeliveryCompletedScreen({Key? key}) : super(key: key);

  @override
  State<TechDeliveryCompletedScreen> createState() =>
      _TechDeliveryCompletedScreenState();
}

class _TechDeliveryCompletedScreenState
    extends State<TechDeliveryCompletedScreen> {
  bool isDroneOpen = false;
  bool isOpeningDrone = false;
  bool isSendingDrone = false;
  final OrderService _orderService = Get.find<OrderService>();
  OrderModel? _orderData;

  @override
  void initState() {
    super.initState();
    // Получаем заказ из аргументов
    final arguments = Get.arguments;
    if (arguments != null && arguments is OrderModel) {
      _orderData = arguments;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Отправка товара'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 44),
          child: Column(
            children: [
              SizedBox(
                height: screenHeight * 0.3,
                width: double.infinity,
                child: Image.asset(
                  'assets/images/drone/delivery.gif',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Дрон готов доставить товар!',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              // Управление грузовым отсеком с индикатором
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDroneOpen ? Colors.green : Colors.grey.shade400,
                    width: 2,
                  ),
                  color:
                      isDroneOpen ? Colors.green.shade50 : Colors.grey.shade50,
                ),
                child: Column(
                  children: [
                    // Индикатор состояния
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color:
                            isDroneOpen ? Colors.green : Colors.grey.shade300,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isDroneOpen ? Icons.lock_open : Icons.lock,
                            color: Colors.black,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Грузовой отсек: ${isDroneOpen ? "ОТКРЫТ" : "ЗАКРЫТ"}',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Кнопка управления
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _toggleCargoBay,
                          icon: isOpeningDrone
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Icon(
                                  isDroneOpen
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  size: 28,
                                ),
                          label: Text(
                            isOpeningDrone
                                ? (isDroneOpen
                                    ? 'Закрываем...'
                                    : 'Открываем...')
                                : (isDroneOpen
                                    ? 'Закрыть отсек'
                                    : 'Открыть отсек'),
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 18),
                            backgroundColor: isDroneOpen
                                ? Colors.orange.shade600
                                : Colors.green.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Кнопка отправки дрона
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isSendingDrone
                      ? null
                      : () {
                          SwipeConfirmDialog.show(
                            context: context,
                            title: 'Отправить дрон',
                            message:
                                'Вы уверены, что хотите отправить дрон на базу?',
                            confirmText: 'Отправить',
                            confirmColor: Colors.blue,
                            icon: Icons.flight_takeoff,
                            onConfirm: () {
                              _sendDroneBack();
                            },
                          );
                        },
                  icon: isSendingDrone
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(Icons.flight_takeoff, size: 24),
                  label: Text(
                    isSendingDrone ? 'Отправляем...' : 'Отправить дрон',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleCargoBay() async {
    print(
        '🔄 Начало открытия/закрытия отсека. Текущее состояние: isDroneOpen=$isDroneOpen');

    // Сохраняем предыдущее состояние для возможного отката
    final previousState = isDroneOpen;

    // Оптимистичное обновление: сразу меняем состояние и кнопку
    setState(() {
      isDroneOpen = !isDroneOpen;
      isOpeningDrone =
          false; // Сразу делаем кнопку активной, не ждем ответа сервера
    });
    print('✅ Состояние обновлено оптимистично. isDroneOpen=$isDroneOpen');

    try {
      // Вызываем API для открытия/закрытия отсека
      final response = await Get.find<DeviceCommandManager>().openDroneBox(
          !previousState); // Используем предыдущее состояние для запроса

      if (response) {
        print('✅ Успешно! Состояние подтверждено: isDroneOpen=$isDroneOpen');
      } else {
        print('❌ Ошибка при управлении отсеком');
        // Откатываем состояние при ошибке
        if (mounted) {
          setState(() {
            isDroneOpen = previousState; // Возвращаем предыдущее состояние
            isOpeningDrone = false;
          });
          print('⚠️ Состояние откачено. isDroneOpen=$isDroneOpen');
        }
      }
    } catch (e) {
      print('❌ Исключение при управлении отсеком: $e');
      print('   Stack trace: ${StackTrace.current}');
      // Откатываем состояние при исключении
      if (mounted) {
        setState(() {
          isDroneOpen = previousState; // Возвращаем предыдущее состояние
          isOpeningDrone = false;
        });
        print(
            '⚠️ Состояние откачено из-за исключения. isDroneOpen=$isDroneOpen');
      }
    }
  }

  void _sendDroneBack() async {
    if (_orderData == null) {
      return;
    }

    setState(() {
      isSendingDrone = true;
    });

    try {
      // Обновляем статус заказа на "delivered"
      await _orderService.updateStatus(
        _orderData!.id.toString(),
        'delivered',
      );

      // Сохраняем заказ в локальную историю техника перед удалением
      try {
        final orderToSave = OrderModel(
          id: _orderData!.id,
          userId: _orderData!.userId,
          productId: _orderData!.productId,
          quantity: _orderData!.quantity,
          deliveryLatitude: _orderData!.deliveryLatitude,
          deliveryLongitude: _orderData!.deliveryLongitude,
          status: 'delivered',
          productName: _orderData!.productName,
          productImage: _orderData!.productImage,
          price: _orderData!.price,
          buyerName: _orderData!.buyerName,
          sellerName: _orderData!.sellerName,
          createdAt: _orderData!.createdAt,
          updatedAt: DateTime.now(),
          productDescription: _orderData!.productDescription,
          productCategory: _orderData!.productCategory,
        );
        await _orderService.archiveTechDelivered(orderToSave);
      } catch (e) {
        print('❌ Ошибка при сохранении заказа в историю техника: $e');
      }

      // Удаляем заказ с сервера — он исчезнет из списка заказов (API: DELETE /order/deleteorder/{orderId})
      await _orderService.deleteOrder(_orderData!.id.toString());

      // Имитация задержки отправки
      await Future.delayed(Duration(milliseconds: 500));

      Get.offAllNamed('/tech-home');
    } catch (e) {
      print('❌ Неожиданная ошибка при отправке дрона: $e');
    } finally {
      if (mounted) {
        setState(() {
          isSendingDrone = false;
        });
      }
    }
  }
}
