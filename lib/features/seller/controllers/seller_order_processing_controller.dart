import "package:get/get.dart";
import "dart:async";
import "package:flutter/material.dart";
import "../../../data/models/order_model.dart";
import "../../../data/repositories/order_repository.dart";

class SellerOrderProcessingController extends GetxController {
  // Репозиторий для работы с заказами (может использоваться в будущем)
  // ignore: unused_field
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
    // Получаем аргументы из навигации
    final arguments = Get.arguments;
    if (arguments != null && arguments is OrderModel) {
      orderData.value = arguments;
      print(
          '✅ SellerOrderProcessingController: Получен заказ ${orderData.value?.id}');
    } else {
      print(
          '⚠️ SellerOrderProcessingController: Аргументы не переданы или неверного типа');
    }
    startOrderProcessing();
    // Запускаем автоматическое обновление статусов
    _startAutomaticStatusUpdate();
  }

  @override
  void onClose() {
    // Очищаем ресурсы при закрытии контроллера
    super.onClose();
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
              style: TextStyle(color: Colors.black),
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
    // Грузовой отсек открыт
  }

  void _closeCargoBay() {
    // Грузовой отсек закрыт
  }

  void _sendDroneBack() async {
    // Небольшая задержка для закрытия диалога
    await Future.delayed(Duration(milliseconds: 300));
    // Переход на главный экран после отправки дрона покупателю
    Get.offAllNamed('/home');
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
