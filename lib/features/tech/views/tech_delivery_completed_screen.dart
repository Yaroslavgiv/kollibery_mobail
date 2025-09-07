import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/sources/api/flight_api.dart';

class TechDeliveryCompletedScreen extends StatelessWidget {
  const TechDeliveryCompletedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Отправка товара'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 44),
          child: Column(
            children: [
              SizedBox(
                height: screenHeight * 0.3,
                width: double.infinity,
                child: Image.asset(
                  'assets/images/drone/delivery.gif',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Дрон готов доставить товар!',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              // Кнопки управления
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _openCargoBay();
                    },
                    child: Text('Открыть грузовой отсек'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _closeCargoBay();
                    },
                    child: Text('Закрыть грузовой отсек'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _sendDroneBack();
                    },
                    child: Text('Отправить дрон'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
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

  void _openCargoBay() async {
    try {
      final response = await FlightApi.openDroneBox(true);
      if (response.statusCode == 200) {
        Get.snackbar(
          "Грузовой отсек",
          "Грузовой отсек открыт",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Ошибка",
          "Не удалось открыть грузовой отсек",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Ошибка",
        "Ошибка сети: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _closeCargoBay() async {
    try {
      final response = await FlightApi.openDroneBox(false);
      if (response.statusCode == 200) {
        Get.snackbar(
          "Грузовой отсек",
          "Грузовой отсек закрыт",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Ошибка",
          "Не удалось закрыть грузовой отсек",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Ошибка",
        "Ошибка сети: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _sendDroneBack() {
    Get.snackbar(
      "Дрон отправлен",
      "Дрон возвращается на базу",
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
    // Возвращаемся к списку заказов
    Get.offAllNamed('/tech-home');
  }
}
