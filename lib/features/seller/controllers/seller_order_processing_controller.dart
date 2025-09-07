import "package:get/get.dart";
import "dart:async";
import "package:flutter/material.dart";
import "../../../data/models/order_model.dart";
import "../../../data/repositories/order_repository.dart";

class SellerOrderProcessingController extends GetxController {
  final OrderRepository _orderRepository = OrderRepository();

  var currentStep =
      (-1).obs; // Начинаем с -1, чтобы первая галочка не показывалась сразу
  var orderData = Rxn<OrderModel>();

  // Изменяем список статусов как у техника
  final List<String> statuses = [
    "Дрон вылетел к вам",
    "Дрон на месте, можно отправлять товар",
  ];

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    if (arguments != null && arguments is OrderModel) {
      orderData.value = arguments;
    }
    startOrderProcessing();
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
      Get.toNamed('/seller-order-completed', arguments: orderData.value);
    });
  }

  void startOrderProcessing() {
    // Убираем старую логику, теперь используем _startAutomaticStatusUpdate
  }

  // Добавляем методы навигации
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
              style: TextStyle(color: Colors.black87),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                    _openCargoBay();
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
                    _closeCargoBay();
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
                _sendDroneBack();
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
    Get.snackbar(
      "Грузовой отсек",
      "Грузовой отсек открыт",
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void _closeCargoBay() {
    Get.snackbar(
      "Грузовой отсек",
      "Грузовой отсек закрыт",
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  void _sendDroneBack() {
    Get.snackbar(
      "Дрон отправлен",
      "Дрон возвращается на базу",
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
    // Можно добавить переход на главный экран или обновление списка заказов
    Get.back(); // Возвращаемся к списку заказов
  }

  void resetProcess() {
    currentStep.value = -1;
    _startAutomaticStatusUpdate();
  }

  String getCurrentStatus() {
    if (currentStep.value < statuses.length && currentStep.value >= 0) {
      return statuses[currentStep.value];
    }
    return "Ожидание дрона";
  }

  bool get isProcessCompleted => currentStep.value >= statuses.length;

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      // Временно используем заглушку, пока не будет реализован API
      print('Обновление статуса заказа $orderId на $status');
      Get.snackbar('Успех', 'Статус заказа обновлен');
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
