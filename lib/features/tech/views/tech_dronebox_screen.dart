import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/widgets/swipe_confirm_dialog.dart';
import '../../../data/sources/api/flight_api.dart';
import '../controllers/dronebox_status_controller.dart';

class TechDroneboxScreen extends StatefulWidget {
  @override
  _TechDroneboxScreenState createState() => _TechDroneboxScreenState();
}

class _TechDroneboxScreenState extends State<TechDroneboxScreen> {
  late DroneboxStatusController _statusController;
  
  // Состояния дронбокса
  bool isRoofOpen = false;
  bool isPositionCenter = true;
  bool isTableUp = false;
  bool isHatchOpen = false;
  bool isDroneBatteryInstalled = false;
  List<String> batteryStates = ['НЕТ', 'НЕТ', 'УСТАНОВЛЕН', 'ЗАРЯД']; // 0-дрон, 1-3 батареи
  
  // Флаги загрузки
  bool isControllingRoof = false;
  bool isControllingPosition = false;
  bool isControllingTable = false;
  bool isControllingHatch = false;
  bool isControllingDroneBattery = false;
  List<bool> isControllingBatteries = [false, false, false];
  bool isStopping = false;

  @override
  void initState() {
    super.initState();
    _statusController = Get.put(DroneboxStatusController());
  }

  @override
  void dispose() {
    // Не удаляем контроллер здесь, так как он может использоваться в других местах
    // Get.delete<DroneboxStatusController>();
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
        title: Text('Дронбокс'),
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
                  color: isConnected ? Colors.yellow.shade100 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                    color: isConnected ? Colors.yellow.shade300 : Colors.red.shade300,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Аппарат: $deviceName',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isConnected ? Colors.green : Colors.red,
                          ),
                              ),
                              SizedBox(width: 8),
                              Text(
                          'Статус: $statusText',
                                style: TextStyle(
                            fontSize: 14,
                            color: isConnected ? Colors.green.shade700 : Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              );
            }),
            
            SizedBox(height: 16),

            // Блок управления крышей
            _buildControlBlock(
              title: 'Крыша',
              status: isRoofOpen ? 'ОТКРЫТА' : 'ЗАКРЫТА',
              actionButtons: Row(
                children: [
                  _buildActionButton(
                    text: 'ОТКРЫТЬ',
                    isActive: !isRoofOpen && !isControllingRoof,
                    activeColor: Colors.green,
                    onPressed: () async {
                                    SwipeConfirmDialog.show(
                                      context: context,
                        title: 'Открыть крышу',
                        message: 'Вы уверены, что хотите открыть крышу?',
                        confirmText: 'Открыть',
                        confirmColor: Colors.green,
                        icon: Icons.roofing,
                                      onConfirm: () async {
                          setState(() => isControllingRoof = true);
                          try {
                            final response = await FlightApi.controlRoof(true);
                            if (response.statusCode >= 200 && response.statusCode < 300) {
                              setState(() => isRoofOpen = true);
                            }
                          } catch (e) {
                            Get.snackbar('Ошибка', 'Не удалось открыть крышу',
                                backgroundColor: Colors.red, colorText: Colors.white);
                                        } finally {
                            if (mounted) setState(() => isControllingRoof = false);
                          }
                        },
                      );
                    },
                  ),
                  SizedBox(width: 8),
                  _buildActionButton(
                    text: 'ЗАКРЫТЬ',
                    isActive: isRoofOpen && !isControllingRoof,
                    activeColor: Colors.orange,
                    onPressed: () async {
                      SwipeConfirmDialog.show(
                        context: context,
                        title: 'Закрыть крышу',
                        message: 'Вы уверены, что хотите закрыть крышу?',
                        confirmText: 'Закрыть',
                        confirmColor: Colors.orange,
                        icon: Icons.roofing_outlined,
                        onConfirm: () async {
                          setState(() => isControllingRoof = true);
                          try {
                            final response = await FlightApi.controlRoof(false);
                            if (response.statusCode >= 200 && response.statusCode < 300) {
                              setState(() => isRoofOpen = false);
                            }
                          } catch (e) {
                            Get.snackbar('Ошибка', 'Не удалось закрыть крышу',
                                backgroundColor: Colors.red, colorText: Colors.white);
                          } finally {
                            if (mounted) setState(() => isControllingRoof = false);
                                        }
                                      },
                                    );
                                  },
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Блок управления позицией
            _buildControlBlock(
              title: 'Позиция',
              status: isPositionCenter ? 'В ЦЕНТРЕ' : 'У КРАЯ',
              actionButtons: Row(
                children: [
                  _buildActionButton(
                    text: 'ЦЕНТР',
                    isActive: !isPositionCenter && !isControllingPosition,
                    activeColor: Colors.green,
                    onPressed: () async {
                      SwipeConfirmDialog.show(
                        context: context,
                        title: 'Переместить в центр',
                        message: 'Переместить платформу в центр?',
                        confirmText: 'Центр',
                        confirmColor: Colors.green,
                        icon: Icons.center_focus_strong,
                        onConfirm: () async {
                          setState(() => isControllingPosition = true);
                          try {
                            final response = await FlightApi.controlPosition(true);
                            if (response.statusCode >= 200 && response.statusCode < 300) {
                              setState(() => isPositionCenter = true);
                            }
                          } catch (e) {
                            Get.snackbar('Ошибка', 'Не удалось переместить в центр',
                                backgroundColor: Colors.red, colorText: Colors.white);
                          } finally {
                            if (mounted) setState(() => isControllingPosition = false);
                          }
                        },
                      );
                    },
                  ),
                  SizedBox(width: 8),
                  _buildActionButton(
                    text: 'КРАЙ',
                    isActive: isPositionCenter && !isControllingPosition,
                    activeColor: Colors.orange,
                    onPressed: () async {
                      SwipeConfirmDialog.show(
                        context: context,
                        title: 'Переместить к краю',
                        message: 'Переместить платформу к краю?',
                        confirmText: 'Край',
                        confirmColor: Colors.orange,
                        icon: Icons.open_in_full,
                        onConfirm: () async {
                          setState(() => isControllingPosition = true);
                          try {
                            final response = await FlightApi.controlPosition(false);
                            if (response.statusCode >= 200 && response.statusCode < 300) {
                              setState(() => isPositionCenter = false);
                            }
                          } catch (e) {
                            Get.snackbar('Ошибка', 'Не удалось переместить к краю',
                                backgroundColor: Colors.red, colorText: Colors.white);
                          } finally {
                            if (mounted) setState(() => isControllingPosition = false);
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Блок управления столом
            _buildControlBlock(
              title: 'Стол',
              status: isTableUp ? 'ВВЕРХУ' : 'В НИЗУ',
              actionButtons: Row(
                children: [
                  _buildActionButton(
                    text: 'ВВЕРХ',
                    isActive: !isTableUp && !isControllingTable,
                    activeColor: Colors.green,
                    onPressed: () async {
                      SwipeConfirmDialog.show(
                        context: context,
                        title: 'Поднять стол',
                        message: 'Поднять стол вверх?',
                        confirmText: 'Вверх',
                        confirmColor: Colors.green,
                        icon: Icons.arrow_upward,
                        onConfirm: () async {
                          setState(() => isControllingTable = true);
                          try {
                            final response = await FlightApi.controlTable(true);
                            if (response.statusCode >= 200 && response.statusCode < 300) {
                              setState(() => isTableUp = true);
                            }
                          } catch (e) {
                            Get.snackbar('Ошибка', 'Не удалось поднять стол',
                                backgroundColor: Colors.red, colorText: Colors.white);
                          } finally {
                            if (mounted) setState(() => isControllingTable = false);
                          }
                        },
                      );
                    },
                  ),
                  SizedBox(width: 8),
                  _buildActionButton(
                    text: 'ВНИЗ',
                    isActive: isTableUp && !isControllingTable,
                    activeColor: Colors.orange,
                    onPressed: () async {
                      SwipeConfirmDialog.show(
                        context: context,
                        title: 'Опустить стол',
                        message: 'Опустить стол вниз?',
                        confirmText: 'Вниз',
                        confirmColor: Colors.orange,
                        icon: Icons.arrow_downward,
                        onConfirm: () async {
                          setState(() => isControllingTable = true);
                          try {
                            final response = await FlightApi.controlTable(false);
                            if (response.statusCode >= 200 && response.statusCode < 300) {
                              setState(() => isTableUp = false);
                            }
                          } catch (e) {
                            Get.snackbar('Ошибка', 'Не удалось опустить стол',
                                backgroundColor: Colors.red, colorText: Colors.white);
                          } finally {
                            if (mounted) setState(() => isControllingTable = false);
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Блок управления люком
            _buildControlBlock(
              title: 'Люк',
              status: isHatchOpen ? 'ОТКРЫТ' : 'ЗАКРЫТ',
              actionButtons: Row(
                children: [
                  _buildActionButton(
                    text: 'ОТКРЫТЬ',
                    isActive: !isHatchOpen && !isControllingHatch,
                    activeColor: Colors.green,
                    onPressed: () async {
                      SwipeConfirmDialog.show(
                        context: context,
                        title: 'Открыть люк',
                        message: 'Вы уверены, что хотите открыть люк?',
                        confirmText: 'Открыть',
                        confirmColor: Colors.green,
                        icon: Icons.open_in_browser,
                        onConfirm: () async {
                          setState(() => isControllingHatch = true);
                          try {
                            final response = await FlightApi.controlHatch(true);
                            if (response.statusCode >= 200 && response.statusCode < 300) {
                              setState(() => isHatchOpen = true);
                            }
                          } catch (e) {
                            Get.snackbar('Ошибка', 'Не удалось открыть люк',
                                backgroundColor: Colors.red, colorText: Colors.white);
                          } finally {
                            if (mounted) setState(() => isControllingHatch = false);
                          }
                        },
                      );
                    },
                  ),
                  SizedBox(width: 8),
                  _buildActionButton(
                    text: 'ЗАКРЫТЬ',
                    isActive: isHatchOpen && !isControllingHatch,
                    activeColor: Colors.orange,
                    onPressed: () async {
                      SwipeConfirmDialog.show(
                        context: context,
                        title: 'Закрыть люк',
                        message: 'Вы уверены, что хотите закрыть люк?',
                        confirmText: 'Закрыть',
                        confirmColor: Colors.orange,
                        icon: Icons.close,
                        onConfirm: () async {
                          setState(() => isControllingHatch = true);
                          try {
                            final response = await FlightApi.controlHatch(false);
                            if (response.statusCode >= 200 && response.statusCode < 300) {
                              setState(() => isHatchOpen = false);
                            }
                          } catch (e) {
                            Get.snackbar('Ошибка', 'Не удалось закрыть люк',
                                backgroundColor: Colors.red, colorText: Colors.white);
                          } finally {
                            if (mounted) setState(() => isControllingHatch = false);
                          }
                        },
                      );
                    },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

            // Блок управления батареей дрона
            _buildControlBlock(
              title: 'Аккум Дрон',
              status: batteryStates[0],
              actionButtons: Row(
                children: [
                  _buildActionButton(
                    text: 'УСТАНОВИТЬ',
                    isActive: batteryStates[0] == 'НЕТ' && !isControllingDroneBattery,
                    activeColor: Colors.green,
                    onPressed: () async {
                      SwipeConfirmDialog.show(
                        context: context,
                        title: 'Установить батарею',
                        message: 'Установить батарею дрона?',
                        confirmText: 'Установить',
                        confirmColor: Colors.green,
                        icon: Icons.battery_charging_full,
                        onConfirm: () async {
                          setState(() => isControllingDroneBattery = true);
                          try {
                            final response = await FlightApi.controlDroneBattery(true);
                            if (response.statusCode >= 200 && response.statusCode < 300) {
                              setState(() => batteryStates[0] = 'УСТАНОВЛЕН');
                            }
                          } catch (e) {
                            Get.snackbar('Ошибка', 'Не удалось установить батарею',
                                backgroundColor: Colors.red, colorText: Colors.white);
                          } finally {
                            if (mounted) setState(() => isControllingDroneBattery = false);
                          }
                        },
                      );
                    },
                  ),
                  SizedBox(width: 8),
                  _buildActionButton(
                    text: 'Снять',
                    isActive: batteryStates[0] == 'УСТАНОВЛЕН' && !isControllingDroneBattery,
                    activeColor: Colors.orange,
                    onPressed: () async {
                      SwipeConfirmDialog.show(
                        context: context,
                        title: 'Снять батарею',
                        message: 'Снять батарею дрона?',
                        confirmText: 'Снять',
                        confirmColor: Colors.orange,
                        icon: Icons.battery_std,
                        onConfirm: () async {
                          setState(() => isControllingDroneBattery = true);
                          try {
                            final response = await FlightApi.controlDroneBattery(false);
                            if (response.statusCode >= 200 && response.statusCode < 300) {
                              setState(() => batteryStates[0] = 'НЕТ');
                            }
                          } catch (e) {
                            Get.snackbar('Ошибка', 'Не удалось снять батарею',
                                backgroundColor: Colors.red, colorText: Colors.white);
                          } finally {
                            if (mounted) setState(() => isControllingDroneBattery = false);
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Блоки управления батареями 1-3
            ...List.generate(3, (index) {
              final batteryNum = index + 1;
              final batteryState = batteryStates[batteryNum];
              final isInstalled = batteryState == 'УСТАНОВЛЕН' || batteryState == 'ЗАРЯД';
              final isCharging = batteryState == 'ЗАРЯД';
              
              return Column(
                children: [
                  _buildControlBlock(
                    title: 'Аккум $batteryNum',
                    status: batteryState,
                    actionButtons: Column(
                      children: [
                        Row(
                          children: [
                            _buildActionButton(
                              text: 'УСТАНОВИТЬ',
                              isActive: batteryState == 'НЕТ' && !isControllingBatteries[index],
                              activeColor: Colors.green,
                              onPressed: () async {
                                SwipeConfirmDialog.show(
                                  context: context,
                                  title: 'Установить батарею $batteryNum',
                                  message: 'Установить батарею $batteryNum?',
                                  confirmText: 'Установить',
                                  confirmColor: Colors.green,
                                  icon: Icons.battery_charging_full,
                                  onConfirm: () async {
                                    setState(() => isControllingBatteries[index] = true);
                                    try {
                                      final response = await FlightApi.controlBoxBattery(
                                        batteryNumber: batteryNum,
                                        action: 'install',
                                      );
                                      if (response.statusCode >= 200 && response.statusCode < 300) {
                                        setState(() => batteryStates[batteryNum] = 'УСТАНОВЛЕН');
                                      }
                                    } catch (e) {
                                      Get.snackbar('Ошибка', 'Не удалось установить батарею',
                                          backgroundColor: Colors.red, colorText: Colors.white);
                                    } finally {
                                      if (mounted) setState(() => isControllingBatteries[index] = false);
                                    }
                                  },
                                );
                              },
                            ),
                            SizedBox(width: 8),
                            _buildActionButton(
                              text: 'Снять',
                              isActive: isInstalled && !isControllingBatteries[index],
                              activeColor: Colors.orange,
                              onPressed: () async {
                                SwipeConfirmDialog.show(
                                  context: context,
                                  title: 'Снять батарею $batteryNum',
                                  message: 'Снять батарею $batteryNum?',
                                  confirmText: 'Снять',
                                  confirmColor: Colors.orange,
                                  icon: Icons.battery_std,
                                  onConfirm: () async {
                                    setState(() => isControllingBatteries[index] = true);
                                    try {
                                      final response = await FlightApi.controlBoxBattery(
                                        batteryNumber: batteryNum,
                                        action: 'remove',
                                      );
                                      if (response.statusCode >= 200 && response.statusCode < 300) {
                                        setState(() => batteryStates[batteryNum] = 'НЕТ');
                                      }
                                    } catch (e) {
                                      Get.snackbar('Ошибка', 'Не удалось снять батарею',
                                          backgroundColor: Colors.red, colorText: Colors.white);
                                    } finally {
                                      if (mounted) setState(() => isControllingBatteries[index] = false);
                                    }
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                        if (isInstalled) ...[
                          SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isControllingBatteries[index]
                                  ? null
                                  : () async {
                                      if (isCharging) {
                                        // Отключить заряд
                                        SwipeConfirmDialog.show(
                                          context: context,
                                          title: 'Отключить заряд батареи $batteryNum',
                                          message: 'Отключить зарядку батареи $batteryNum?',
                                          confirmText: 'Отключить',
                                          confirmColor: Colors.orange,
                                          icon: Icons.battery_charging_full,
                                          onConfirm: () async {
                                            setState(() => isControllingBatteries[index] = true);
                                            try {
                                              final response = await FlightApi.controlBoxBattery(
                                                batteryNumber: batteryNum,
                                                action: 'discharge',
                                              );
                                              if (response.statusCode >= 200 && response.statusCode < 300) {
                                                setState(() => batteryStates[batteryNum] = 'УСТАНОВЛЕН');
                                              }
                                            } catch (e) {
                                              Get.snackbar('Ошибка', 'Не удалось отключить заряд',
                                                  backgroundColor: Colors.red, colorText: Colors.white);
                                            } finally {
                                              if (mounted) setState(() => isControllingBatteries[index] = false);
                                            }
                                          },
                                        );
                                      } else {
                                        // Начать заряд
                                        SwipeConfirmDialog.show(
                                          context: context,
                                          title: 'Зарядить батарею $batteryNum',
                                          message: 'Начать зарядку батареи $batteryNum?',
                                          confirmText: 'Зарядить',
                                          confirmColor: Colors.green,
                                          icon: Icons.battery_charging_full,
                                          onConfirm: () async {
                                            setState(() => isControllingBatteries[index] = true);
                                            try {
                                              final response = await FlightApi.controlBoxBattery(
                                                batteryNumber: batteryNum,
                                                action: 'charge',
                                              );
                                              if (response.statusCode >= 200 && response.statusCode < 300) {
                                                setState(() => batteryStates[batteryNum] = 'ЗАРЯД');
                                              }
                                            } catch (e) {
                                              Get.snackbar('Ошибка', 'Не удалось начать зарядку',
                                                  backgroundColor: Colors.red, colorText: Colors.white);
                                            } finally {
                                              if (mounted) setState(() => isControllingBatteries[index] = false);
                                            }
                                          },
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isCharging ? Colors.orange : Colors.green,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 2,
                              ),
                              child: Text(
                                isCharging ? 'ОТКЛ. ЗАРЯД' : 'ЗАРЯД',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              );
            }),

            // Кнопка стоп
            ElevatedButton.icon(
              onPressed: isStopping
                                ? null
                                : () {
                                    SwipeConfirmDialog.show(
                                      context: context,
                        title: 'Стоп дронбокса',
                        message: 'Вы уверены, что хотите остановить все операции дронбокса?',
                        confirmText: 'Остановить',
                        confirmColor: Colors.red,
                        icon: Icons.stop,
                                      onConfirm: () async {
                          setState(() => isStopping = true);
                          try {
                            await FlightApi.droneboxStop();
                          } catch (e) {
                            Get.snackbar('Ошибка', 'Не удалось остановить дронбокс',
                                backgroundColor: Colors.red, colorText: Colors.white);
                                        } finally {
                            if (mounted) setState(() => isStopping = false);
                                        }
                                      },
                                    );
                                  },
              icon: isStopping
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(Icons.stop, size: 28),
              label: Text(isStopping ? 'Остановка...' : 'СТОП'),
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
