import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../data/sources/api/flight_api.dart';
import '../../../routes/app_routes.dart';
import '../../../common/widgets/swipe_confirm_dialog.dart';
import '../controllers/drone_status_controller.dart';

class TechDroneScreen extends StatefulWidget {
  @override
  _TechDroneScreenState createState() => _TechDroneScreenState();
}

class _TechDroneScreenState extends State<TechDroneScreen> {
  late DroneStatusController _statusController;

  // Состояния дрона
  bool isLockOpen = false;
  bool isBoxOpen = false;
  bool isDroneOpen = false; // для обратной совместимости
  int selectedDistance = 1;
  bool isTakeoff = true;
  bool isSendingTest = false;
  int selectedColor = 0; // 0-выкл,1-зелёный,2-красный
  bool isSendingLight = false;
  bool isOpeningDrone = false;
  bool isEmergencyStopping = false;
  bool isReturningHome = false;
  bool isLanding = false;
  bool isFlightStarted = false;
  bool isControllingLock = false;
  bool isControllingBox = false;

  @override
  void initState() {
    super.initState();
    _statusController = Get.put(DroneStatusController());
  }

  @override
  void dispose() {
    // Не удаляем контроллер здесь, так как он может использоваться в других местах
    // Get.delete<DroneStatusController>();
    super.dispose();
  }

  // Создание блока управления с кнопками
  Widget _buildControlBlock({
    required String title,
    required String status,
    required Widget actionButtons,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
        color: Colors.white,
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок с статусом
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$title:',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          // Кнопки управления
          actionButtons,
        ],
      ),
    );
  }

  // Создание кнопки с правильным стилем (активная/неактивная)
  Widget _buildActionButton({
    required String text,
    required bool isActive,
    required VoidCallback? onPressed,
    Color? activeColor,
  }) {
    final defaultActiveColor = activeColor ?? Colors.green;
    return Expanded(
      child: ElevatedButton(
        onPressed: isActive ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? defaultActiveColor : Colors.grey.shade300,
          foregroundColor: isActive ? Colors.white : Colors.grey.shade600,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: isActive ? 2 : 0,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        title: Text('Дрон'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 8),

            // Информация об устройстве
            Obx(() {
              final statusText = _statusController.getStatusText();
              final isConnected = _statusController.isConnected.value;
              final deviceName = _statusController.deviceName.value;

              return Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      isConnected ? Colors.yellow.shade100 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isConnected
                        ? Colors.yellow.shade300
                        : Colors.red.shade300,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isConnected ? Icons.check_circle : Icons.error,
                      color: isConnected ? Colors.green : Colors.red,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Аппарат: $deviceName',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Статус: $statusText',
                            style: TextStyle(
                              fontSize: 14,
                              color: isConnected
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isConnected)
                      IconButton(
                        icon: Icon(Icons.refresh, size: 20),
                        onPressed: () => _statusController.reconnect(),
                        tooltip: 'Переподключиться',
                      ),
                  ],
                ),
              );
            }),

            SizedBox(height: 16),

            // Блок управления замком
            _buildControlBlock(
              title: 'Замок',
              status: isLockOpen ? 'ОТКРЫТ' : 'ЗАКРЫТ',
              actionButtons: Row(
                children: [
                  _buildActionButton(
                    text: 'ОТКРЫТЬ',
                    isActive: true,
                    activeColor: Colors.green,
                    onPressed: () async {
                      SwipeConfirmDialog.show(
                        context: context,
                        title: 'Открыть замок',
                        message: 'Вы уверены, что хотите открыть замок?',
                        confirmText: 'Открыть',
                        confirmColor: Colors.green,
                        icon: Icons.lock_open,
                        onConfirm: () async {
                          setState(() => isControllingLock = true);
                          try {
                            final response =
                                await FlightApi.controlDroneLock(true);
                            if (response.statusCode >= 200 &&
                                response.statusCode < 300) {
                              setState(() => isLockOpen = true);
                            }
                          } catch (e) {
                          } finally {
                            if (mounted)
                              setState(() => isControllingLock = false);
                          }
                        },
                      );
                    },
                  ),
                  SizedBox(width: 8),
                  _buildActionButton(
                    text: 'ЗАКРЫТЬ',
                    isActive: true,
                    activeColor: Colors.orange,
                    onPressed: () async {
                      SwipeConfirmDialog.show(
                        context: context,
                        title: 'Закрыть замок',
                        message: 'Вы уверены, что хотите закрыть замок?',
                        confirmText: 'Закрыть',
                        confirmColor: Colors.orange,
                        icon: Icons.lock,
                        onConfirm: () async {
                          setState(() => isControllingLock = true);
                          try {
                            final response =
                                await FlightApi.controlDroneLock(false);
                            if (response.statusCode >= 200 &&
                                response.statusCode < 300) {
                              setState(() => isLockOpen = false);
                            }
                          } catch (e) {
                          } finally {
                            if (mounted)
                              setState(() => isControllingLock = false);
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Блок управления коробом
            _buildControlBlock(
              title: 'Короб',
              status: isBoxOpen ? 'ОТКРЫТ' : 'ЗАКРЫТ',
              actionButtons: Row(
                children: [
                  _buildActionButton(
                    text: 'ОТКРЫТЬ',
                    isActive: true,
                    activeColor: Colors.green,
                    onPressed: () async {
                      SwipeConfirmDialog.show(
                        context: context,
                        title: 'Открыть короб',
                        message: 'Вы уверены, что хотите открыть короб?',
                        confirmText: 'Открыть',
                        confirmColor: Colors.green,
                        icon: Icons.open_in_browser,
                        onConfirm: () async {
                          setState(() => isControllingBox = true);
                          try {
                            // Используем правильный API метод для грузового бокса дрона
                            // POST /flight/openbox?isActive=true
                            final response = await FlightApi.openDroneBox(true);
                            if (response.statusCode >= 200 &&
                                response.statusCode < 300) {
                              setState(() => isBoxOpen = true);
                            }
                          } catch (e) {
                          } finally {
                            if (mounted)
                              setState(() => isControllingBox = false);
                          }
                        },
                      );
                    },
                  ),
                  SizedBox(width: 8),
                  _buildActionButton(
                    text: 'ЗАКРЫТЬ',
                    isActive: true,
                    activeColor: Colors.orange,
                    onPressed: () async {
                      SwipeConfirmDialog.show(
                        context: context,
                        title: 'Закрыть короб',
                        message: 'Вы уверены, что хотите закрыть короб?',
                        confirmText: 'Закрыть',
                        confirmColor: Colors.orange,
                        icon: Icons.close,
                        onConfirm: () async {
                          setState(() => isControllingBox = true);
                          try {
                            // Используем правильный API метод для грузового бокса дрона
                            // POST /flight/openbox?isActive=false
                            final response =
                                await FlightApi.openDroneBox(false);
                            if (response.statusCode >= 200 &&
                                response.statusCode < 300) {
                              setState(() => isBoxOpen = false);
                            }
                          } catch (e) {
                          } finally {
                            if (mounted)
                              setState(() => isControllingBox = false);
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Блок управления светом
            _buildControlBlock(
              title: 'Свет',
              status: selectedColor == 0
                  ? 'ВЫКЛ'
                  : selectedColor == 1
                      ? 'ЗЕЛЕНЫЙ'
                      : 'КРАСНЫЙ',
              actionButtons: Row(
                children: [
                  _buildActionButton(
                    text: 'ЗЕЛЕНЫЙ',
                    isActive: !isSendingLight,
                    activeColor: Colors.green,
                    onPressed: () async {
                      SwipeConfirmDialog.show(
                        context: context,
                        title: 'Включить зеленый свет',
                        message: 'Включить зеленую подсветку?',
                        confirmText: 'Включить',
                        confirmColor: Colors.green,
                        icon: Icons.light_mode,
                        onConfirm: () async {
                          setState(() {
                            isSendingLight = true;
                            selectedColor = 1;
                          });
                          try {
                            await FlightApi.testBacklight(colorNumber: 1);
                          } catch (e) {
                          } finally {
                            if (mounted) setState(() => isSendingLight = false);
                          }
                        },
                      );
                    },
                  ),
                  SizedBox(width: 8),
                  _buildActionButton(
                    text: 'КРАСНЫЙ',
                    isActive: !isSendingLight,
                    activeColor: Colors.orange,
                    onPressed: () async {
                      SwipeConfirmDialog.show(
                        context: context,
                        title: 'Включить красный свет',
                        message: 'Включить красную подсветку?',
                        confirmText: 'Включить',
                        confirmColor: Colors.red,
                        icon: Icons.light_mode,
                        onConfirm: () async {
                          setState(() {
                            isSendingLight = true;
                            selectedColor = 2;
                          });
                          try {
                            await FlightApi.testBacklight(colorNumber: 2);
                          } catch (e) {
                          } finally {
                            if (mounted) setState(() => isSendingLight = false);
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Блок управления взлетом
            _buildControlBlock(
              title: 'Взлет',
              status: '$selectedDistance М',
              actionButtons: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Без диалогов: циклически меняем высоту 1..5
                            setState(() {
                              selectedDistance =
                                  selectedDistance >= 5 ? 1 : selectedDistance + 1;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            'ВЫСОТА',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      _buildActionButton(
                        text: 'ВВЕРХ',
                        isActive: true,
                        activeColor: Colors.green,
                        onPressed: () async {
                          SwipeConfirmDialog.show(
                            context: context,
                            title: 'Взлет',
                            message: 'Выполнить взлет на $selectedDistance м?',
                            confirmText: 'Взлететь',
                            confirmColor: Colors.green,
                            icon: Symbols.drone,
                            onConfirm: () async {
                              setState(() => isSendingTest = true);
                              try {
                                await FlightApi.testSystemCheck(
                                  isActive: true,
                                  distance: selectedDistance,
                                );
                              } catch (e) {
                              } finally {
                                if (mounted)
                                  setState(() => isSendingTest = false);
                              }
                            },
                          );
                        },
                      ),
                      SizedBox(width: 8),
                      _buildActionButton(
                        text: 'ВНИЗ',
                        isActive: true,
                        activeColor: Colors.orange,
                        onPressed: () async {
                          SwipeConfirmDialog.show(
                            context: context,
                            title: 'Снижение',
                            message:
                                'Выполнить снижение с $selectedDistance м?',
                            confirmText: 'Снизить',
                            confirmColor: Colors.orange,
                            icon: Symbols.drone,
                            onConfirm: () async {
                              setState(() => isSendingTest = true);
                              try {
                                await FlightApi.testSystemCheck(
                                  isActive: false,
                                  distance: selectedDistance,
                                );
                              } catch (e) {
                              } finally {
                                if (mounted)
                                  setState(() => isSendingTest = false);
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Блок управления полетом
            _buildControlBlock(
              title: 'Полет',
              status: isFlightStarted ? 'В ПОЛЕТЕ' : 'ГОТОВ',
              actionButtons: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.toNamed(AppRoutes.techAutopilotPick);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'МАРШРУТ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      _buildActionButton(
                        text: 'СТАРТ',
                        isActive: !isFlightStarted,
                        activeColor: Colors.green,
                        onPressed: () async {
                          SwipeConfirmDialog.show(
                            context: context,
                            title: 'Старт полета',
                            message: 'Начать полет по маршруту?',
                            confirmText: 'Старт',
                            confirmColor: Colors.green,
                            icon: Icons.flight_takeoff,
                            onConfirm: () async {
                              setState(() => isFlightStarted = true);
                              try {
                                await FlightApi.droneStartFlight();
                              } catch (e) {
                                setState(() => isFlightStarted = false);
                              }
                            },
                          );
                        },
                      ),
                      SizedBox(width: 8),
                      _buildActionButton(
                        text: 'ОТМЕНА',
                        isActive: true,
                        activeColor: Colors.orange,
                        onPressed: () async {
                          SwipeConfirmDialog.show(
                            context: context,
                            title: 'Отмена полета',
                            message: 'Отменить полет дрона?',
                            confirmText: 'Отменить',
                            confirmColor: Colors.orange,
                            icon: Icons.cancel,
                            onConfirm: () async {
                              try {
                                await FlightApi.droneCancelFlight();
                                setState(() => isFlightStarted = false);
                              } catch (e) {
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Кнопка посадки
            ElevatedButton.icon(
              onPressed: isLanding
                  ? null
                  : () {
                      SwipeConfirmDialog.show(
                        context: context,
                        title: 'Посадка',
                        message: 'Выполнить посадку дрона?',
                        confirmText: 'Посадить',
                        confirmColor: Colors.green,
                        icon: Icons.flight_land,
                        onConfirm: () async {
                          setState(() => isLanding = true);
                          try {
                            await FlightApi.droneLand();
                          } catch (e) {
                          } finally {
                            if (mounted) setState(() => isLanding = false);
                          }
                        },
                      );
                    },
              icon: isLanding
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(Icons.flight_land, size: 28),
              label: Text(isLanding ? 'Посадка...' : 'ПОСАДКА'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),

            SizedBox(height: 16),

            // Кнопка возврата домой
            ElevatedButton.icon(
              onPressed: isReturningHome
                  ? null
                  : () {
                      SwipeConfirmDialog.show(
                        context: context,
                        title: 'Возвращение домой',
                        message: 'Отправить дрон на базу?',
                        confirmText: 'Отправить',
                        confirmColor: Colors.blue.shade700,
                        icon: Icons.home,
                        onConfirm: () async {
                          setState(() => isReturningHome = true);
                          try {
                            await FlightApi.returnToHome();
                          } catch (e) {
                          } finally {
                            if (mounted)
                              setState(() => isReturningHome = false);
                          }
                        },
                      );
                    },
              icon: isReturningHome
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(Icons.home, size: 28),
              label: Text(isReturningHome ? 'Возвращение...' : 'ВОЗВРАТ ДОМОЙ'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
            ),

            SizedBox(height: 16),

            // Кнопка стоп
            ElevatedButton.icon(
              onPressed: isEmergencyStopping
                  ? null
                  : () {
                      SwipeConfirmDialog.show(
                        context: context,
                        title: 'Экстренная остановка',
                        message:
                            'Вы уверены, что хотите выполнить экстренную остановку дрона? Это действие нельзя отменить!',
                        confirmText: 'Остановить',
                        confirmColor: Colors.red,
                        icon: Icons.emergency,
                        onConfirm: () async {
                          setState(() => isEmergencyStopping = true);
                          try {
                            await FlightApi.emergencyStop();
                            setState(() => isFlightStarted = false);
                          } catch (e) {
                          } finally {
                            if (mounted)
                              setState(() => isEmergencyStopping = false);
                          }
                        },
                      );
                    },
              icon: isEmergencyStopping
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(Icons.emergency, size: 28),
              label: Text(isEmergencyStopping ? 'Остановка...' : 'СТОП'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),

            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
