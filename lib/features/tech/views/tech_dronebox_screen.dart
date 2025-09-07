import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
// Добавляем импорт API
import '../../../data/sources/api/flight_api.dart';

class TechDroneboxScreen extends StatefulWidget {
  @override
  _TechDroneboxScreenState createState() => _TechDroneboxScreenState();
}

class _TechDroneboxScreenState extends State<TechDroneboxScreen> {
  bool isDroneOpen = false;
  bool isPlatformExtended = false;
  bool isBatteryWindowOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Управление Дронбоксом'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Изображение дронбокса
            Container(
              height: 112,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  Icons.flight,
                  size: 80,
                  color: Colors.blue,
                ),
              ),
            ),
            SizedBox(height: 24),

            // Кнопка управления дроном
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  // Вызываем API для открытия/закрытия дрона
                  final response = await FlightApi.openDroneBox(!isDroneOpen);

                  if (response.statusCode == 200) {
                    setState(() {
                      isDroneOpen = !isDroneOpen;
                    });
                    Get.snackbar(
                      'Дрон',
                      isDroneOpen ? 'Дрон открыт' : 'Дрон закрыт',
                      duration: Duration(seconds: 2),
                      backgroundColor: isDroneOpen ? Colors.green : Colors.red,
                      colorText: Colors.white,
                    );
                  } else {
                    Get.snackbar(
                      'Ошибка',
                      'Не удалось ${isDroneOpen ? 'закрыть' : 'открыть'} дрон',
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                } catch (e) {
                  Get.snackbar(
                    'Ошибка',
                    'Ошибка сети: $e',
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
              icon: Icon(isDroneOpen ? Icons.lock : Icons.lock_open, size: 31),
              label: Text(isDroneOpen ? 'Закрыть дрон' : 'Открыть дрон'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: isDroneOpen ? Colors.red : Colors.green,
              ),
            ),
            SizedBox(height: 16),

            // Кнопка управления платформой
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  isPlatformExtended = !isPlatformExtended;
                });
                Get.snackbar(
                  'Платформа',
                  isPlatformExtended
                      ? 'Платформа выдвинута'
                      : 'Платформа убрана',
                  duration: Duration(seconds: 2),
                );
              },
              icon: Icon(
                  isPlatformExtended
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_up,
                  size: 31),
              label: Text(isPlatformExtended
                  ? 'Убрать платформу'
                  : 'Выдвинуть платформу'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor:
                    isPlatformExtended ? Colors.orange : Colors.blue,
              ),
            ),
            SizedBox(height: 16),

            // Кнопка окна замены акумулятора
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  isBatteryWindowOpen = !isBatteryWindowOpen;
                });
                Get.snackbar(
                  'Окно акумулятора',
                  isBatteryWindowOpen ? 'Окно открыто' : 'Окно закрыто',
                  duration: Duration(seconds: 2),
                );
              },
              icon: Icon(
                  isBatteryWindowOpen
                      ? Icons.battery_charging_full
                      : Icons.battery_full,
                  size: 31),
              label: Text(isBatteryWindowOpen
                  ? 'Закрыть окно акумулятора'
                  : 'Открыть окно акумулятора'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor:
                    isBatteryWindowOpen ? Colors.purple : Colors.amber,
              ),
            ),
            SizedBox(height: 16),

            // Кнопка взлёта на 10 метров
            ElevatedButton.icon(
              onPressed: () {
                Get.snackbar(
                  'Дрон',
                  'Взлёт на 10 метров инициирован',
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.blue.shade100,
                  colorText: Colors.black,
                );
                // TODO: здесь можно вызвать реальный API/SDK команды взлёта
              },
              icon: Icon(Symbols.drone, size: 31),
              label: Text('Взлет 10 метров'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
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
                  Text('Дрон: ${isDroneOpen ? "Открыт" : "Закрыт"}',
                      style: TextStyle(color: Colors.black)),
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
    );
  }
}
