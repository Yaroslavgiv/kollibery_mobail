import 'package:get/get.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';
import 'package:flutter/material.dart';
import '../../../common/widgets/swipe_confirm_dialog.dart';

class TechDeliveryStatusController extends GetxController {
  final OrderRepository _orderRepository = OrderRepository();

  var orders = <OrderModel>[].obs;
  var isLoading = false.obs;
  var selectedOrder = Rxn<OrderModel>();
  var currentStep =
      (-1).obs; // Начинаем с -1, чтобы первая галочка не показывалась сразу

  // Изменяем список статусов
  final List<String> statuses = [
    'Дрон вылетел к вам',
    'Дрон на месте, можно отправлять товар',
  ];

  // Добавить методы навигации
  void nextStep() {
    if (currentStep.value < statuses.length - 1) {
      currentStep.value++;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  // Добавляем метод для завершения доставки
  void showFinalScreen() {
    if (currentStep.value == statuses.length - 1) {
      // Показываем финальный экран с кнопками
      _showFinalScreen();
    }
  }

  void _showFinalScreen() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          "Доставка завершена",
          style: TextStyle(color: Colors.black),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Дрон доставил товар. Выберите действие:",
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                    SwipeConfirmDialog.show(
                      context: Get.context!,
                      title: 'Открыть грузовой отсек',
                      message:
                          'Вы уверены, что хотите открыть грузовой отсек дрона?',
                      confirmText: 'Открыть',
                      confirmColor: Colors.green,
                      icon: Icons.lock_open,
                      onConfirm: _openCargoBay,
                    );
                  },
                  child: Text("Открыть грузовой отсек"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                    SwipeConfirmDialog.show(
                      context: Get.context!,
                      title: 'Закрыть грузовой отсек',
                      message:
                          'Вы уверены, что хотите закрыть грузовой отсек дрона?',
                      confirmText: 'Закрыть',
                      confirmColor: Colors.orange,
                      icon: Icons.lock,
                      onConfirm: _closeCargoBay,
                    );
                  },
                  child: Text("Закрыть грузовой отсек"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Get.back();
                SwipeConfirmDialog.show(
                  context: Get.context!,
                  title: 'Отправить дрон',
                  message: 'Вы уверены, что хотите отправить дрон на базу?',
                  confirmText: 'Отправить',
                  confirmColor: Colors.blue,
                  icon: Icons.flight_takeoff,
                  onConfirm: _sendDroneBack,
                );
              },
              child: Text("Отправить дрон"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCargoBay() {
    // Грузовой отсек открыт
  }

  void _closeCargoBay() {
    // Грузовой отсек закрыт
  }

  void _sendDroneBack() {
    // Можно добавить переход на главный экран или обновление списка заказов
    Get.back(); // Возвращаемся к списку заказов
  }

  @override
  void onInit() {
    super.onInit();
    // Получаем заказ из аргументов при инициализации
    final arguments = Get.arguments;
    if (arguments != null && arguments is OrderModel) {
      selectedOrder.value = arguments;
    }
    fetchTechOrders();
    // Запускаем автоматическое обновление статусов
    _startAutomaticStatusUpdate();
  }

  void _startAutomaticStatusUpdate() {
    // Первая галочка через 5 секунд
    Future.delayed(Duration(seconds: 5), () {
      currentStep.value = 0; // Показываем первую галочку
    });

    // Вторая галочка через 10 секунд после первой (5 + 10 = 15 секунд)
    Future.delayed(Duration(seconds: 15), () {
      currentStep.value = 1; // Показываем вторую галочку
    });

    // Переход на экран итогов через 5 секунд после второй галочки (15 + 5 = 20 секунд)
    Future.delayed(Duration(seconds: 20), () {
      // Переходим на отдельную страницу завершения доставки
      // Передаем заказ в аргументах, если он был выбран
      Get.toNamed('/tech-delivery-completed', arguments: selectedOrder.value);
    });
  }

  Future<void> fetchTechOrders() async {
    try {
      isLoading.value = true;
      final fetchedOrders = await _orderRepository.fetchTechOrdersAsModels();
      orders.value = fetchedOrders;
    } catch (e) {
      Get.snackbar('Ошибка', 'Не удалось загрузить заказы: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectOrder(OrderModel order) {
    selectedOrder.value = order;
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      // Временно используем заглушку, пока не будет реализован API
      print('Обновление статуса заказа $orderId на $status');
      await fetchTechOrders(); // Обновляем список
    } catch (e) {
      Get.snackbar('Ошибка', 'Не удалось обновить статус: $e');
    }
  }

  Future<void> startDelivery(OrderModel order) async {
    await updateOrderStatus(order.id.toString(), 'in_transit');
  }

  Future<void> completeDelivery(OrderModel order) async {
    await updateOrderStatus(order.id.toString(), 'delivered');
  }
}
