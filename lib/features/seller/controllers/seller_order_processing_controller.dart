import "package:get/get.dart";
import "dart:async";
import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "../../../data/models/order_model.dart";
import "../../../data/sources/api/flight_api.dart";

class SellerOrderProcessingController extends GetxController {
  var currentStep = 0.obs; // Начинаем с 0 ("Заказ принят")
  var orderData = Rxn<OrderModel>();

  // Список статусов согласно таблице для продавца
  final List<String> statuses = [
    "Заказ принят", // 0
    "Дрон вылетел к вам", // 1
    "Дрон на месте, загрузите товар", // 2
    "Дрон вылетел к покупателю", // 3
    "Дрон у покупателя", // 4
    "Заказ выполнен", // 5
  ];

  Timer? _statusPollingTimer;

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
  }

  @override
  void onClose() {
    _statusPollingTimer?.cancel();
    super.onClose();
  }

  void startOrderProcessing() {
    // Устанавливаем начальный статус "Заказ принят"
    currentStep.value = 0;
    
    // Обновляем статусы каждые 3 секунды (захардкожено)
    const interval = Duration(seconds: 3);
    
    // Статус 1: Дрон вылетел к вам (через 3 секунды)
    Future.delayed(interval * 1, () {
      currentStep.value = 1;
    });
    
    // Статус 2: Дрон на месте, загрузите товар (через 6 секунд)
    Future.delayed(interval * 2, () {
      currentStep.value = 2;
    });
    
    // Статус 3: Дрон вылетел к покупателю (через 9 секунд)
    Future.delayed(interval * 3, () {
      currentStep.value = 3;
    });
    
    // Статус 4: Дрон у покупателя (через 12 секунд)
    Future.delayed(interval * 4, () {
      currentStep.value = 4;
    });
    
    // Статус 5: Заказ выполнен (через 15 секунд) и переход на финальный экран
    Future.delayed(interval * 5, () {
      currentStep.value = 5;
      // Переход на экран завершения доставки
      Future.delayed(const Duration(seconds: 1), () {
        Get.toNamed('/seller-order-completed', arguments: orderData.value);
      });
    });
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
    FlightApi.openDroneBox(true).catchError((e) {
      print('❌ Ошибка при открытии отсека: $e');
      return http.Response('', 500);
    });
  }

  void _closeCargoBay() {
    FlightApi.openDroneBox(false).catchError((e) {
      print('❌ Ошибка при закрытии отсека: $e');
      return http.Response('', 500);
    });
  }

  void _sendDroneBack() async {
    // Небольшая задержка для закрытия диалога
    await Future.delayed(Duration(milliseconds: 300));
    // Переход на главный экран продавца после отправки дрона покупателю
    Get.offAllNamed('/seller-home');
  }

  void resetProcess() {
    currentStep.value = 0;
    startOrderProcessing();
  }

  String getCurrentStatus() {
    if (currentStep.value < statuses.length && currentStep.value >= 0) {
      return statuses[currentStep.value];
    }
    return "Ожидание...";
  }

  bool get isProcessCompleted => currentStep.value >= statuses.length;

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      // Временно используем заглушку, пока не будет реализован API
      print('Обновление статуса заказа $orderId на $status');
    } catch (e) {
    }
  }

  Future<void> startDelivery(OrderModel order) async {
    await updateOrderStatus(order.id.toString(), 'in_transit');
  }

  Future<void> completeDelivery(OrderModel order) async {
    await updateOrderStatus(order.id.toString(), 'delivered');
  }
}
