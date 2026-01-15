import "package:flutter/material.dart";
import "package:get/get.dart";
import "../../../data/sources/api/flight_api.dart";
import "../../../data/models/order_model.dart";
import "../../../data/repositories/order_repository.dart";
import "../../../data/repositories/order_history_repository.dart";
import "../../../common/widgets/swipe_confirm_dialog.dart";

class SellerOrderCompletedScreen extends StatefulWidget {
  @override
  State<SellerOrderCompletedScreen> createState() =>
      _SellerOrderCompletedScreenState();
}

class _SellerOrderCompletedScreenState
    extends State<SellerOrderCompletedScreen> {
  bool isDroneOpen = false;
  bool isOpeningDrone = false; // Флаг загрузки для кнопки открытия/закрытия отсека
  final OrderRepository _orderRepository = OrderRepository();
  final OrderHistoryRepository _historyRepository = OrderHistoryRepository();
  OrderModel? _orderData;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    // Получаем заказ из аргументов
    final arguments = Get.arguments;
    if (arguments != null && arguments is OrderModel) {
      _orderData = arguments;
      print('✅ SellerOrderCompletedScreen: Получен заказ ${_orderData?.id}');
    } else {
      print(
          '⚠️ SellerOrderCompletedScreen: Аргументы не переданы или неверного типа');
      // Показываем предупреждение пользователю
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Предупреждение',
          'Данные заказа не найдены',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Отправка товара'),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 44),
          child: Column(
            children: [
              SizedBox(
                height: screenHeight * 0.25,
                width: double.infinity,
                child: Image.asset(
                  'assets/images/drone/delivery.gif',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Дрон готов доставить товар!',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
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
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Грузовой отсек: ${isDroneOpen ? "ОТКРЫТ" : "ЗАКРЫТ"}',
                            style: TextStyle(
                              color: Colors.white,
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
                          onPressed: isOpeningDrone
                              ? null
                              : () async {
                                  // Сохраняем предыдущее состояние для возможного отката
                                  final previousState = isDroneOpen;
                                  
                                  // Оптимистичное обновление: сразу меняем состояние и кнопку
                                  setState(() {
                                    isDroneOpen = !isDroneOpen;
                                    isOpeningDrone = false; // Сразу делаем кнопку активной, не ждем ответа сервера
                                  });
                                  
                                  try {
                                    // Вызываем API для открытия/закрытия бокса
                                    final response =
                                        await FlightApi.openDroneBox(!previousState); // Используем предыдущее состояние для запроса

                                    // Выводим ответ сервера в консоль
                                    print('Ответ сервера при управлении боксом:');
                                    print('Status Code: ${response.statusCode}');
                                    print('Response Body: ${response.body}');

                                    if (response.statusCode >= 200 && response.statusCode < 300) {
                                      final responseBody =
                                          response.body.toLowerCase();
                                      if (responseBody.contains('успех') ||
                                          responseBody.contains('success') ||
                                          responseBody.contains('ok') ||
                                          responseBody.isEmpty) {
                                        print(
                                            '✅ Сервер вернул успешный ответ: ${response.body}');
                                      }

                                      // Состояние уже обновлено оптимистично, ничего не делаем
                                    } else {
                                      print(
                                          '❌ Ошибка при управлении боксом: ${response.statusCode} - ${response.body}');
                                      // Откатываем состояние при ошибке
                                      if (mounted) {
                                        setState(() {
                                          isDroneOpen = previousState; // Возвращаем предыдущее состояние
                                          isOpeningDrone = false;
                                        });
                                      }
                                      Get.snackbar(
                                        'Ошибка',
                                        'Не удалось ${previousState ? 'закрыть' : 'открыть'} отсек. Код: ${response.statusCode}',
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                        duration: Duration(seconds: 3),
                                      );
                                    }
                                  } catch (e) {
                                    print('❌ Исключение при управлении боксом: $e');
                                    // Откатываем состояние при исключении
                                    if (mounted) {
                                      setState(() {
                                        isDroneOpen = previousState; // Возвращаем предыдущее состояние
                                        isOpeningDrone = false;
                                      });
                                    }
                                    Get.snackbar(
                                      'Ошибка',
                                      'Ошибка сети: ${e.toString()}',
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                      duration: Duration(seconds: 3),
                                    );
                                  }
                                },
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
              const Spacer(),
              // Кнопка отправить дрон
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSending ? null : _sendDroneBack,
                  icon: _isSending
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(Icons.flight_takeoff, size: 28),
                  label: Text(
                    _isSending ? 'Отправка...' : 'Отправить дрон к покупателю',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendDroneBack() {
    if (_orderData == null) {
      return;
    }

    SwipeConfirmDialog.show(
      context: context,
      title: 'Отправить дрон',
      message:
          'Вы уверены, что хотите отправить дрон к покупателю? Заказ будет перемещен в историю.',
      confirmText: 'Отправить',
      confirmColor: Colors.blue.shade700,
      icon: Icons.flight_takeoff,
      onConfirm: () async {
        setState(() {
          _isSending = true;
        });

        try {
          // Сначала обновляем статус заказа на "delivered" (доставлен)
          await _orderRepository.updateOrderStatus(
            _orderData!.id.toString(),
            'delivered',
          );

          // Сохраняем заказ в историю перед удалением
          final orderToSave = OrderModel(
            id: _orderData!.id,
            userId: _orderData!.userId,
            productId: _orderData!.productId,
            quantity: _orderData!.quantity,
            deliveryLatitude: _orderData!.deliveryLatitude,
            deliveryLongitude: _orderData!.deliveryLongitude,
            status: 'delivered', // Сохраняем как доставленный
            productName: _orderData!.productName,
            productImage: _orderData!.productImage,
            price: _orderData!.price,
            buyerName: _orderData!.buyerName,
            sellerName: _orderData!.sellerName,
            createdAt: _orderData!.createdAt,
            updatedAt: DateTime.now(), // Обновляем время
            productDescription: _orderData!.productDescription,
            productCategory: _orderData!.productCategory,
          );
          await _historyRepository.saveOrderToHistory(orderToSave);

          // Затем удаляем заказ с сервера
          await _orderRepository.deleteOrder(
            _orderData!.id.toString(),
          );

          // Переход на главный экран продавца после отправки дрона покупателю
          Get.offAllNamed('/seller-home');
        } catch (e) {
          print('❌ Ошибка при отправке дрона: $e');
          Get.snackbar(
            'Ошибка',
            'Ошибка при отправке дрона: $e',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          // Переход на главный экран продавца даже при ошибке
          Get.offAllNamed('/seller-home');
        } finally {
          if (mounted) {
            setState(() {
              _isSending = false;
            });
          }
        }
      },
    );
  }
}
