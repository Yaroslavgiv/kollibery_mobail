import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:http/http.dart' as http;
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

  /// Показывает диалог выбора высоты
  void _showHeightSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Выберите высоту',
            style: TextStyle(color: Colors.black),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              final height = index + 1;
              return ListTile(
                title: Text(
                  '$height м',
                  style: TextStyle(color: Colors.black),
                ),
                selected: selectedDistance == height,
                onTap: () {
                  setState(() {
                    selectedDistance = height;
                  });
                  Navigator.of(context).pop();
                },
              );
            }),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Отмена',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        );
      },
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
                            // POST /flight/openbox с boolean в body (true - открыть)
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
                            // POST /flight/openbox с boolean в body (false - закрыть)
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
                    isActive: true, // Кнопки света не блокируются
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
                    isActive: true, // Кнопки света не блокируются
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
                            _showHeightSelectionDialog();
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
                          if (isSendingTest) return; // Предотвращаем дублирование
                          SwipeConfirmDialog.show(
                            context: context,
                            title: 'Взлет',
                            message: 'Выполнить взлет на $selectedDistance м?',
                            confirmText: 'Взлететь',
                            confirmColor: Colors.green,
                            icon: Symbols.drone,
                            onConfirm: () async {
                              if (isSendingTest) return; // Предотвращаем дублирование
                              setState(() => isSendingTest = true);
                              try {
                                // Повторяем запрос до 3 раз при ошибке
                                int maxRetries = 3;
                                http.Response? response;
                                Exception? lastError;
                                
                                for (int attempt = 1; attempt <= maxRetries; attempt++) {
                                  try {
                                    response = await FlightApi.testSystemCheck(
                                      isActive: true,
                                      distance: selectedDistance,
                                    );
                                    
                                    // Проверяем успешность ответа
                                    if (response.statusCode >= 200 && response.statusCode < 300) {
                                      print('✅ Запрос на взлет успешен с попытки $attempt');
                                      break; // Успешно, выходим из цикла
                                    } else {
                                      print('⚠️ Попытка $attempt: статус ${response.statusCode}');
                                      if (attempt < maxRetries) {
                                        await Future.delayed(Duration(milliseconds: 500));
                                      }
                                    }
                                  } catch (e) {
                                    lastError = e is Exception ? e : Exception(e.toString());
                                    print('❌ Попытка $attempt: ошибка $e');
                                    if (attempt < maxRetries) {
                                      await Future.delayed(Duration(milliseconds: 500));
                                    }
                                  }
                                }
                                
                                // Если все попытки неудачны, показываем ошибку
                                if (response == null || (response.statusCode < 200 || response.statusCode >= 300)) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Ошибка взлета после $maxRetries попыток'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                  if (lastError != null) {
                                    throw lastError;
                                  }
                                }
                              } catch (e) {
                                print('❌ Ошибка при взлете: $e');
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
                          if (isSendingTest) return; // Предотвращаем дублирование
                          SwipeConfirmDialog.show(
                            context: context,
                            title: 'Снижение',
                            message:
                                'Выполнить снижение с $selectedDistance м?',
                            confirmText: 'Снизить',
                            confirmColor: Colors.orange,
                            icon: Symbols.drone,
                            onConfirm: () async {
                              if (isSendingTest) return; // Предотвращаем дублирование
                              setState(() => isSendingTest = true);
                              try {
                                // Повторяем запрос до 3 раз при ошибке
                                int maxRetries = 3;
                                http.Response? response;
                                Exception? lastError;
                                
                                for (int attempt = 1; attempt <= maxRetries; attempt++) {
                                  try {
                                    response = await FlightApi.testSystemCheck(
                                      isActive: false,
                                      distance: selectedDistance,
                                    );
                                    
                                    // Проверяем успешность ответа
                                    if (response.statusCode >= 200 && response.statusCode < 300) {
                                      print('✅ Запрос на посадку успешен с попытки $attempt');
                                      break; // Успешно, выходим из цикла
                                    } else {
                                      print('⚠️ Попытка $attempt: статус ${response.statusCode}');
                                      if (attempt < maxRetries) {
                                        await Future.delayed(Duration(milliseconds: 500));
                                      }
                                    }
                                  } catch (e) {
                                    lastError = e is Exception ? e : Exception(e.toString());
                                    print('❌ Попытка $attempt: ошибка $e');
                                    if (attempt < maxRetries) {
                                      await Future.delayed(Duration(milliseconds: 500));
                                    }
                                  }
                                }
                                
                                // Если все попытки неудачны, показываем ошибку
                                if (response == null || (response.statusCode < 200 || response.statusCode >= 300)) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Ошибка посадки после $maxRetries попыток'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                  if (lastError != null) {
                                    throw lastError;
                                  }
                                }
                              } catch (e) {
                                print('❌ Ошибка при посадке: $e');
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
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                  'Старт полета',
                                  style: TextStyle(color: Colors.black),
                                ),
                                content: Text(
                                  'Начать полет по маршруту?',
                                  style: TextStyle(color: Colors.black),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: Text(
                                      'Отмена',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      setState(() => isFlightStarted = true);
                                      try {
                                        await FlightApi.droneStartFlight();
                                      } catch (e) {
                                        setState(() => isFlightStarted = false);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: Text('Старт'),
                                  ),
                                ],
                              );
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
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                  'Отмена полета',
                                  style: TextStyle(color: Colors.black),
                                ),
                                content: Text(
                                  'Отменить полет дрона?',
                                  style: TextStyle(color: Colors.black),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: Text(
                                      'Отмена',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      try {
                                        await FlightApi.droneCancelFlight();
                                        setState(() => isFlightStarted = false);
                                      } catch (e) {
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: Text('Отменить'),
                                  ),
                                ],
                              );
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
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                              'Посадка',
                              style: TextStyle(color: Colors.black),
                            ),
                            content: Text(
                              'Выполнить посадку дрона?',
                              style: TextStyle(color: Colors.black),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(
                                  'Отмена',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  setState(() => isLanding = true);
                                  try {
                                    await FlightApi.droneLand();
                                  } catch (e) {
                                  } finally {
                                    if (mounted) setState(() => isLanding = false);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                                child: Text('Посадить'),
                              ),
                            ],
                          );
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
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                              'Возвращение домой',
                              style: TextStyle(color: Colors.black),
                            ),
                            content: Text(
                              'Отправить дрон на базу?',
                              style: TextStyle(color: Colors.black),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(
                                  'Отмена',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  setState(() => isReturningHome = true);
                                  try {
                                    await FlightApi.returnToHome();
                                  } catch (e) {
                                  } finally {
                                    if (mounted)
                                      setState(() => isReturningHome = false);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade700,
                                  foregroundColor: Colors.white,
                                ),
                                child: Text('Отправить'),
                              ),
                            ],
                          );
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
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                              'Экстренная остановка',
                              style: TextStyle(color: Colors.black),
                            ),
                            content: Text(
                              'Вы уверены, что хотите выполнить экстренную остановку дрона? Это действие нельзя отменить!',
                              style: TextStyle(color: Colors.black),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(
                                  'Отмена',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  Navigator.of(context).pop();
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
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: Text('Остановить'),
                              ),
                            ],
                          );
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
