import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
// Добавляем импорт API
import '../../../data/sources/api/flight_api.dart';
import '../../../routes/app_routes.dart';
import '../../../common/widgets/swipe_confirm_dialog.dart';

class TechDroneboxScreen extends StatefulWidget {
  @override
  _TechDroneboxScreenState createState() => _TechDroneboxScreenState();
}

class _TechDroneboxScreenState extends State<TechDroneboxScreen> {
  bool isDroneOpen = false;
  bool isPlatformExtended = false;
  bool isBatteryWindowOpen = false;
  int selectedDistance = 1;
  bool isTakeoff = true; // true: взлёт, false: посадка
  bool isSendingTest = false;
  int selectedColor = 0; // 0-выкл,1-зелёный,2-красный
  bool isSendingLight = false;
  bool isOpeningDrone =
      false; // Индикатор загрузки для открытия/закрытия отсека
  bool isMovingPlatform = false; // Индикатор загрузки для платформы
  bool isMovingBatteryWindow =
      false; // Индикатор загрузки для окна аккумулятора
  bool isEmergencyStopping =
      false; // Индикатор загрузки для экстренной остановки
  bool isReturningHome = false; // Индикатор загрузки для возвращения на базу

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          automaticallyImplyLeading: false,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(0),
            child: Container(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              child: TabBar(
                tabs: const [
                  Tab(text: 'Дрон'),
                  Tab(text: 'Дронбокс'),
                ],
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            // Вкладка Дрон
            SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 8),
                  // Кнопка управления грузовым отсеком дрона (перенесено во вкладку Дрон)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isDroneOpen ? Colors.green : Colors.grey.shade400,
                        width: 2,
                      ),
                      color: isDroneOpen
                          ? Colors.green.shade50
                          : Colors.grey.shade50,
                    ),
                    child: Column(
                      children: [
                        // Индикатор состояния
                        Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            color: isDroneOpen
                                ? Colors.green
                                : Colors.grey.shade300,
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
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Грузовой отсек: ${isDroneOpen ? "ОТКРЫТ" : "ЗАКРЫТ"}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Кнопка управления
                        SizedBox(
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
                                      confirmColor: isDroneOpen ? Colors.orange.shade600 : Colors.blue.shade700,
                                      icon: isDroneOpen ? Icons.lock : Icons.lock_open,
                                      onConfirm: () async {
                                        setState(() {
                                          isOpeningDrone = true;
                                        });
                                        try {
                                          // Вызываем API для открытия/закрытия дрона
                                          final response =
                                              await FlightApi.openDroneBox(
                                                  !isDroneOpen);

                                          // Выводим ответ сервера в консоль
                                          print(
                                              'Ответ сервера при управлении дроном:');
                                          print(
                                              'Status Code: ${response.statusCode}');
                                          print('Response Body: ${response.body}');
                                          print(
                                              'Response Headers: ${response.headers}');

                                          if (response.statusCode == 200) {
                                            // Проверяем, содержит ли ответ слово "успех"
                                            final responseBody =
                                                response.body.toLowerCase();
                                            if (responseBody.contains('успех') ||
                                                responseBody.contains('success')) {
                                              print(
                                                  '✅ Сервер вернул успешный ответ: ${response.body}');
                                            }

                                            setState(() {
                                              isDroneOpen = !isDroneOpen;
                                            });
                                          } else {
                                            print(
                                                '❌ Ошибка при управлении дроном: ${response.statusCode} - ${response.body}');
                                            Get.snackbar(
                                              'Ошибка',
                                              'Не удалось ${isDroneOpen ? 'закрыть' : 'открыть'} отсек',
                                              duration: Duration(seconds: 2),
                                              backgroundColor: Colors.red,
                                              colorText: Colors.white,
                                            );
                                          }
                                        } catch (e) {
                                          print(
                                              '❌ Исключение при управлении дроном: $e');
                                          Get.snackbar(
                                            'Ошибка',
                                            'Ошибка сети: $e',
                                            duration: Duration(seconds: 2),
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                          );
                                        } finally {
                                          if (mounted) {
                                            setState(() {
                                              isOpeningDrone = false;
                                            });
                                          }
                                        }
                                      },
                                    );
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
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: isDroneOpen
                                  ? Colors.orange.shade600
                                  : Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  // Блок выбора высоты и кнопка тестового взлёта/посадки
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: selectedDistance,
                          decoration: InputDecoration(
                            labelText: 'Высота (м)',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          items: [1, 2, 3, 4, 5]
                              .map((v) => DropdownMenuItem<int>(
                                    value: v,
                                    child: Text('$v м'),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => selectedDistance = v);
                          },
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isSendingTest
                              ? null
                              : () {
                                  SwipeConfirmDialog.show(
                                    context: context,
                                    title: isTakeoff ? 'Тестовый взлёт' : 'Тестовая посадка',
                                    message: 'Выполнить ${isTakeoff ? 'тестовый взлёт на $selectedDistance м' : 'тестовую посадку'}?',
                                    confirmText: 'Выполнить',
                                    confirmColor: Colors.blue,
                                    icon: Symbols.drone,
                                    onConfirm: () async {
                                      setState(() {
                                        isSendingTest = true;
                                      });
                                      try {
                                        final response =
                                            await FlightApi.testSystemCheck(
                                          isActive: isTakeoff,
                                          distance: selectedDistance,
                                        );
                                        final ok = response.statusCode >= 200 &&
                                            response.statusCode < 300;
                                        // Подробный лог
                                        print(
                                            'Ответ тестового взлёта: ${response.statusCode}');
                                        print('Тело: ${response.body}');
                                        if (ok) {
                                          setState(() {
                                            // После успешного взлёта переключаем на посадку, и наоборот
                                            isTakeoff = !isTakeoff;
                                          });
                                        }
                                      } catch (e) {
                                        // Ошибка обработана
                                      } finally {
                                        if (mounted) {
                                          setState(() {
                                            isSendingTest = false;
                                          });
                                        }
                                      }
                                    },
                                  );
                                },
                          icon: isSendingTest
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Icon(Symbols.drone, size: 28),
                          label: Text(isSendingTest
                              ? 'Выполнение...'
                              : 'Тестовый взлёт'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      isTakeoff ? 'Режим: взлёт' : 'Режим: посадка',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                  SizedBox(height: 24),
                  // Кнопка теста автопилота (выбор точки назначения)
                  ElevatedButton.icon(
                    onPressed: () {
                      Get.toNamed(AppRoutes.techAutopilotPick);
                    },
                    icon: Icon(Icons.place),
                    label: Text('Тест автопилота: выбрать точку'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  SizedBox(height: 32),
                  // Блок выбора цвета подсветки и кнопка
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: selectedColor,
                          decoration: InputDecoration(
                            labelText: 'Подсветка',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          items: const [
                            DropdownMenuItem<int>(
                                value: 0, child: Text('Выключен')),
                            DropdownMenuItem<int>(
                                value: 1, child: Text('Зелёный')),
                            DropdownMenuItem<int>(
                                value: 2, child: Text('Красный')),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => selectedColor = v);
                          },
                        ),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isSendingLight
                              ? null
                              : () {
                                  final colorName = selectedColor == 0
                                      ? 'выключен'
                                      : selectedColor == 1
                                          ? 'зелёный'
                                          : 'красный';
                                  SwipeConfirmDialog.show(
                                    context: context,
                                    title: 'Установить подсветку',
                                    message: 'Установить цвет подсветки: $colorName?',
                                    confirmText: 'Установить',
                                    confirmColor: Colors.teal,
                                    icon: Icons.light_mode,
                                    onConfirm: () async {
                                      setState(() {
                                        isSendingLight = true;
                                      });
                                      try {
                                        final response =
                                            await FlightApi.testBacklight(
                                                colorNumber: selectedColor);
                                        final ok = response.statusCode >= 200 &&
                                            response.statusCode < 300;
                                      } catch (e) {
                                        Get.snackbar(
                                          'Ошибка',
                                          'Сеть: $e',
                                          duration: Duration(seconds: 2),
                                          backgroundColor: Colors.red,
                                          colorText: Colors.white,
                                        );
                                      } finally {
                                        if (mounted) {
                                          setState(() {
                                            isSendingLight = false;
                                          });
                                        }
                                      }
                                    },
                                  );
                                },
                          icon: isSendingLight
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Icon(Icons.light_mode, size: 28),
                          label: Text(isSendingLight
                              ? 'Установка...'
                              : 'Установить цвет'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                  // Кнопка экстренной остановки
                  ElevatedButton.icon(
                    onPressed: isEmergencyStopping
                        ? null
                        : () {
                            SwipeConfirmDialog.show(
                              context: context,
                              title: 'Экстренная остановка',
                              message: 'Вы уверены, что хотите выполнить экстренную остановку дрона? Это действие нельзя отменить!',
                              confirmText: 'Остановить',
                              confirmColor: Colors.red,
                              icon: Icons.emergency,
                              onConfirm: () async {
                                setState(() {
                                  isEmergencyStopping = true;
                                });
                                try {
                                  final response = await FlightApi.emergencyStop();
                                  final ok = response.statusCode >= 200 &&
                                      response.statusCode < 300;
                                } catch (e) {
                                  Get.snackbar(
                                    'Ошибка',
                                    'Сеть: $e',
                                    duration: Duration(seconds: 2),
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      isEmergencyStopping = false;
                                    });
                                  }
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
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(Icons.emergency, size: 28),
                    label: Text(isEmergencyStopping
                        ? 'Остановка...'
                        : 'Экстренная остановка'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  // Кнопка возвращения на базу
                  ElevatedButton.icon(
                    onPressed: isReturningHome
                        ? null
                        : () {
                            SwipeConfirmDialog.show(
                              context: context,
                              title: 'Возвращение на базу',
                              message: 'Отправить дрон на базу?',
                              confirmText: 'Отправить',
                              confirmColor: Colors.blue.shade700,
                              icon: Icons.home,
                              onConfirm: () async {
                                setState(() {
                                  isReturningHome = true;
                                });
                                try {
                                  final response = await FlightApi.returnToHome();
                                  final ok = response.statusCode >= 200 &&
                                      response.statusCode < 300;
                                } catch (e) {
                                  Get.snackbar(
                                    'Ошибка',
                                    'Сеть: $e',
                                    duration: Duration(seconds: 2),
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      isReturningHome = false;
                                    });
                                  }
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
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(Icons.home, size: 28),
                    label: Text(isReturningHome
                        ? 'Возвращение...'
                        : 'Возвращение на базу'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Вкладка Дронбокс
            SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 14),
                  // (грузовой отсек перенесён во вкладку Дрон)

                  // Кнопка управления платформой
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isPlatformExtended
                            ? Colors.blue
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                      color: isPlatformExtended
                          ? Colors.blue.shade50
                          : Colors.grey.shade50,
                    ),
                    child: Column(
                      children: [
                        // Индикатор состояния
                        Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            color: isPlatformExtended
                                ? Colors.blue
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isPlatformExtended
                                    ? Icons.open_in_full
                                    : Icons.close_fullscreen,
                                color: Colors.black,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Платформа: ${isPlatformExtended ? "ВЫДВИНУТА" : "УБРАНА"}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Кнопка управления
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isMovingPlatform
                                ? null
                                : () {
                                    SwipeConfirmDialog.show(
                                      context: context,
                                      title: isPlatformExtended ? 'Убрать платформу' : 'Выдвинуть платформу',
                                      message: 'Вы уверены, что хотите ${isPlatformExtended ? 'убрать' : 'выдвинуть'} платформу дронбокса?',
                                      confirmText: isPlatformExtended ? 'Убрать' : 'Выдвинуть',
                                      confirmColor: isPlatformExtended ? Colors.orange.shade600 : Colors.blue.shade700,
                                      icon: isPlatformExtended ? Icons.close_fullscreen : Icons.open_in_full,
                                      onConfirm: () async {
                                        setState(() {
                                          isMovingPlatform = true;
                                        });
                                        try {
                                          // Имитация задержки для демонстрации индикатора
                                          await Future.delayed(
                                              Duration(milliseconds: 500));

                                          setState(() {
                                            isPlatformExtended =
                                                !isPlatformExtended;
                                          });
                                        } finally {
                                          if (mounted) {
                                            setState(() {
                                              isMovingPlatform = false;
                                            });
                                          }
                                        }
                                      },
                                    );
                                  },
                            icon: isMovingPlatform
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
                                    isPlatformExtended
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    size: 28,
                                  ),
                            label: Text(
                              isMovingPlatform
                                  ? (isPlatformExtended
                                      ? 'Убираем...'
                                      : 'Выдвигаем...')
                                  : (isPlatformExtended
                                      ? 'Убрать платформу'
                                      : 'Выдвинуть платформу'),
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: isPlatformExtended
                                  ? Colors.orange.shade600
                                  : Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),

                  // Кнопка окна замены акумулятора
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isBatteryWindowOpen
                            ? Colors.purple
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                      color: isBatteryWindowOpen
                          ? Colors.purple.shade50
                          : Colors.grey.shade50,
                    ),
                    child: Column(
                      children: [
                        // Индикатор состояния
                        Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            color: isBatteryWindowOpen
                                ? Colors.purple
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isBatteryWindowOpen
                                    ? Icons.battery_charging_full
                                    : Icons.battery_full,
                                color: Colors.black,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Окно аккумулятора: ${isBatteryWindowOpen ? "ОТКРЫТО" : "ЗАКРЫТО"}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Кнопка управления
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isMovingBatteryWindow
                                ? null
                                : () {
                                    SwipeConfirmDialog.show(
                                      context: context,
                                      title: isBatteryWindowOpen ? 'Закрыть окно аккумулятора' : 'Открыть окно аккумулятора',
                                      message: 'Вы уверены, что хотите ${isBatteryWindowOpen ? 'закрыть' : 'открыть'} окно аккумулятора?',
                                      confirmText: isBatteryWindowOpen ? 'Закрыть' : 'Открыть',
                                      confirmColor: isBatteryWindowOpen ? Colors.amber.shade700 : Colors.purple.shade600,
                                      icon: isBatteryWindowOpen ? Icons.lock : Icons.lock_open_outlined,
                                      onConfirm: () async {
                                        setState(() {
                                          isMovingBatteryWindow = true;
                                        });
                                        try {
                                          // Имитация задержки для демонстрации индикатора
                                          await Future.delayed(
                                              Duration(milliseconds: 500));

                                          setState(() {
                                            isBatteryWindowOpen =
                                                !isBatteryWindowOpen;
                                          });
                                        } finally {
                                          if (mounted) {
                                            setState(() {
                                              isMovingBatteryWindow = false;
                                            });
                                          }
                                        }
                                      },
                                    );
                                  },
                            icon: isMovingBatteryWindow
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
                                    isBatteryWindowOpen
                                        ? Icons.lock
                                        : Icons.lock_open_outlined,
                                    size: 28,
                                  ),
                            label: Text(
                              isMovingBatteryWindow
                                  ? (isBatteryWindowOpen
                                      ? 'Закрываем...'
                                      : 'Открываем...')
                                  : (isBatteryWindowOpen
                                      ? 'Закрыть окно аккумулятора'
                                      : 'Открыть окно аккумулятора'),
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: isBatteryWindowOpen
                                  ? Colors.amber.shade700
                                  : Colors.purple.shade600,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  // Статус системы
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Статус системы:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black),
                        ),
                        SizedBox(height: 8),
                        // Text('Дрон: ${isDroneOpen ? "Открыт" : "Закрыт"}',
                        //     style: TextStyle(color: Colors.black)),
                        Text(
                            'Платформа: ${isPlatformExtended ? "Выдвинута" : "Убрана"}',
                            style: TextStyle(color: Colors.black)),
                        Text(
                            'Окно акумулятора: ${isBatteryWindowOpen ? "Открыто" : "Закрыто"}',
                            style: TextStyle(color: Colors.black)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
