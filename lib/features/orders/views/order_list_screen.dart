import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Подключение вашей темы:
// import '../../../common/themes/text_theme.dart';
// (раскомментируйте и поправьте путь, если необходимо)

// Добавляем импорт API
import '../../../data/sources/api/flight_api.dart';

class DeliveryCompletedScreen extends StatelessWidget {
  const DeliveryCompletedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Узнаём высоту экрана, чтобы задать адаптивную высоту под GIF.
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Заказ прибыл'),
      ),
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 44),
          child: Column(
            children: [
              // Верхний блок с изображением (GIF)
              SizedBox(
                height: screenHeight * 0.3, // 30% высоты экрана
                width: double.infinity,
                child: Image.asset(
                  'assets/images/drone/delivery.gif',
                  // Или NetworkImage(...) если у вас ссылка на картинку
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              // Основной заголовок или текст
              Text(
                'Ваш заказ успешно доставлен!',
                // style: KTextTheme.lightTextTheme.titleMedium, // если у вас есть своя тема
                style:
                    Theme.of(context).textTheme.titleMedium, // базовый вариант
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              // Кнопка "Открыть бокс"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        // Вызываем API для открытия бокса
                        final response = await FlightApi.openDroneBox(true);

                        if (response.statusCode == 200) {
                          Get.snackbar(
                            'Бокс',
                            'Бокс открыт',
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                        } else {
                          Get.snackbar(
                            'Ошибка',
                            'Не удалось открыть бокс',
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
                    child: const Text('Открыть бокс'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Кнопка "Закрыть бокс"
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        // Вызываем API для закрытия бокса
                        final response = await FlightApi.openDroneBox(false);

                        if (response.statusCode == 200) {
                          Get.snackbar(
                            'Бокс',
                            'Бокс закрыт',
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.orange,
                            colorText: Colors.white,
                          );
                        } else {
                          Get.snackbar(
                            'Ошибка',
                            'Не удалось закрыть бокс',
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
                    child: const Text('Закрыть бокс'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
