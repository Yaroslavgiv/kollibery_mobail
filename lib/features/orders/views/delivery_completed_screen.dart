import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../common/styles/colors.dart';
import '../../../common/widgets/swipe_confirm_dialog.dart';
import '../../../routes/app_routes.dart';

/// Экран завершения доставки для покупателя
class DeliveryCompletedScreen extends StatefulWidget {
  const DeliveryCompletedScreen({Key? key}) : super(key: key);

  @override
  State<DeliveryCompletedScreen> createState() => _DeliveryCompletedScreenState();
}

class _DeliveryCompletedScreenState extends State<DeliveryCompletedScreen> {
  bool isDroneOpen = false;
  bool isOpeningDrone = false;
  bool isReceivingOrder = false;
  final OrderRepository _orderRepository = OrderRepository();
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
        title: Text('Получение заказа'),
        backgroundColor: KColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 44),
          child: Column(
            children: [
              SizedBox(
                height: screenHeight * 0.3,
                width: double.infinity,
                child: Image.asset(
                  'assets/images/drone/delivery.gif',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.local_shipping, size: 100, color: Colors.grey[400]),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Дрон прибыл! Заберите ваш заказ',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (_orderData != null)
                Text(
                  'Заказ #${_orderData!.id}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
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
                  color: isDroneOpen ? Colors.green.shade50 : Colors.grey.shade50,
                ),
                child: Column(
                  children: [
                    // Индикатор состояния
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDroneOpen ? Colors.green : Colors.grey.shade300,
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
                          onPressed: isOpeningDrone
                              ? null
                              : () {
                                  SwipeConfirmDialog.show(
                                    context: context,
                                    title: isDroneOpen ? 'Закрыть грузовой отсек' : 'Открыть грузовой отсек',
                                    message: 'Вы уверены, что хотите ${isDroneOpen ? 'закрыть' : 'открыть'} грузовой отсек дрона?',
                                    confirmText: isDroneOpen ? 'Закрыть' : 'Открыть',
                                    confirmColor: isDroneOpen ? Colors.orange.shade600 : Colors.green.shade600,
                                    icon: isDroneOpen ? Icons.lock : Icons.lock_open,
                                    onConfirm: () async {
                                      _toggleCargoBay();
                                    },
                                  );
                                },
                          icon: isOpeningDrone
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Icon(
                                  isDroneOpen ? Icons.arrow_upward : Icons.arrow_downward,
                                  size: 28,
                                ),
                          label: Text(
                            isOpeningDrone
                                ? (isDroneOpen ? 'Закрываем...' : 'Открываем...')
                                : (isDroneOpen ? 'Закрыть отсек' : 'Открыть отсек'),
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 18),
                            backgroundColor: isDroneOpen ? Colors.orange.shade600 : Colors.green.shade600,
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
              // Кнопка подтверждения получения заказа
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isReceivingOrder || !isDroneOpen
                      ? null
                      : () {
                          SwipeConfirmDialog.show(
                            context: context,
                            title: 'Подтвердить получение',
                            message: 'Вы подтверждаете получение заказа? Заказ будет перемещен в историю.',
                            confirmText: 'Подтвердить',
                            confirmColor: KColors.primary,
                            icon: Icons.check_circle,
                            onConfirm: () {
                              _confirmOrderReceived();
                            },
                          );
                        },
                  icon: isReceivingOrder
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(Icons.check_circle, size: 24),
                  label: Text(
                    isReceivingOrder ? 'Обрабатываем...' : 'Подтвердить получение заказа',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: KColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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
    // Сохраняем предыдущее состояние для возможного отката
    final previousState = isDroneOpen;
    
    // Оптимистичное обновление: сразу меняем состояние и кнопку
    setState(() {
      isDroneOpen = !isDroneOpen;
      isOpeningDrone = false; // Сразу делаем кнопку активной, не ждем ответа сервера
    });
    
    try {
      // Имитация открытия/закрытия отсека
      await Future.delayed(Duration(seconds: 1));
      
      // Состояние уже обновлено оптимистично, ничего не делаем
    } catch (e) {
      print('❌ Ошибка при управлении отсеком: $e');
      // Откатываем состояние при ошибке
      if (mounted) {
        setState(() {
          isDroneOpen = previousState; // Возвращаем предыдущее состояние
          isOpeningDrone = false;
        });
      }
      Get.snackbar(
        'Ошибка',
        'Не удалось управлять грузовым отсеком',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _confirmOrderReceived() async {
    if (_orderData == null) {
      return;
    }

    setState(() {
      isReceivingOrder = true;
    });

    try {
      // Обновляем статус заказа на "delivered" чтобы он попал в историю
      await _orderRepository.updateOrderStatus(
        _orderData!.id.toString(),
        'delivered',
      );

      // Имитация задержки обработки
      await Future.delayed(Duration(milliseconds: 500));
      
      // Проверяем роль пользователя для правильной навигации
      final box = GetStorage();
      final role = box.read('role') ?? 'buyer';
      
      // Возвращаемся на главный экран в зависимости от роли
      if (role == 'technician' || role == 'tech') {
        // Для техника возвращаемся на экран техника
        Get.offAllNamed(AppRoutes.techHome);
      } else {
        // Для покупателя возвращаемся на домашний экран
        Get.offAllNamed(AppRoutes.home);
      }
      
      // Показываем сообщение об успехе
      Get.snackbar(
        'Успешно',
        'Заказ получен и перемещен в историю',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      print('❌ Ошибка при подтверждении получения заказа: $e');
      Get.snackbar(
        'Ошибка',
        'Не удалось подтвердить получение заказа: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    } finally {
      if (mounted) {
        setState(() {
          isReceivingOrder = false;
        });
      }
    }
  }
}

