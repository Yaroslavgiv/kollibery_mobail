import 'package:get/get.dart';
import 'dart:async';
import '../../../data/models/order_model.dart';

/// Контроллер состояния доставки для управления процессом выполнения заказа.
/// Использует GetX для управления состоянием и навигации.
class DeliveryStatusController extends GetxController {
  /// Текущее состояние доставки, представлено как индекс статуса в списке.
  var currentStep = 0.obs;

  /// Список статусов доставки согласно таблице для покупателя
  final List<String> statuses = [
    'Заказ сформирован', // 0
    'Заказ принят продавцом', // 1
    'Дрон вылетел за заказом', // 2
    'Дрон на загрузке', // 3
    'Дрон вылетел к вам', // 4
    'Дрон на месте, заберите товар', // 5
    'Заказ выполнен', // 6
  ];

  Timer? _statusPollingTimer;

  /// Данные о заказе (если переданы)
  var orderData = Rxn<OrderModel>();

  @override
  void onInit() {
    super.onInit();

    // Получаем данные заказа из аргументов, если они переданы
    final arguments = Get.arguments;
    if (arguments != null && arguments is OrderModel) {
      orderData.value = arguments;
    }

    startDeliveryProcess(); // Запуск процесса отслеживания доставки при инициализации контроллера.
  }

  @override
  void onClose() {
    _statusPollingTimer?.cancel();
    super.onClose();
  }

  /// Метод запускает процесс изменения статусов доставки с интервалом 3 секунды
  void startDeliveryProcess() {
    // Устанавливаем начальный статус "Заказ сформирован"
    currentStep.value = 0;
    
    // Обновляем статусы каждые 3 секунды (захардкожено)
    const interval = Duration(seconds: 3);
    
    // Статус 1: Заказ принят продавцом (через 3 секунды)
    Future.delayed(interval * 1, () {
      currentStep.value = 1;
    });
    
    // Статус 2: Дрон вылетел за заказом (через 6 секунд)
    Future.delayed(interval * 2, () {
      currentStep.value = 2;
    });
    
    // Статус 3: Дрон на загрузке (через 9 секунд)
    Future.delayed(interval * 3, () {
      currentStep.value = 3;
    });
    
    // Статус 4: Дрон вылетел к вам (через 12 секунд)
    Future.delayed(interval * 4, () {
      currentStep.value = 4;
    });
    
    // Статус 5: Дрон на месте, заберите товар (через 15 секунд)
    Future.delayed(interval * 5, () {
      currentStep.value = 5;
    });
    
    // Статус 6: Заказ выполнен (через 18 секунд) и переход на финальный экран
    Future.delayed(interval * 6, () {
      currentStep.value = 6;
      // Переход на экран завершения доставки
      Future.delayed(const Duration(seconds: 1), () {
        final orderToPass = orderData.value;
        Get.offNamed('/delivery-completed', arguments: orderToPass);
      });
    });
  }

  /// Ручной переход к следующему шагу (для тестирования)
  void nextStep() {
    if (currentStep.value < statuses.length - 1) {
      currentStep.value++;
    }
  }

  /// Ручной переход к предыдущему шагу (для тестирования)
  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  /// Сброс процесса доставки
  void resetDeliveryProcess() {
    currentStep.value = 0;
    startDeliveryProcess();
  }

  /// Получение текущего статуса
  String get currentStatus {
    if (currentStep.value < statuses.length) {
      return statuses[currentStep.value];
    }
    return 'Доставка завершена';
  }

  /// Проверка, завершена ли доставка
  bool get isDeliveryCompleted {
    return currentStep.value >= statuses.length - 1;
  }
}
