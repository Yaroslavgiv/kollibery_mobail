import "package:flutter/material.dart";
import "package:get/get.dart";

import "../../../common/themes/text_theme.dart";
import "../controllers/seller_order_processing_controller.dart";

class SellerOrderStatusScreen extends StatefulWidget {
  @override
  State<SellerOrderStatusScreen> createState() => _SellerOrderStatusScreenState();
}

class _SellerOrderStatusScreenState extends State<SellerOrderStatusScreen> {
  late SellerOrderProcessingController controller;

  @override
  void initState() {
    super.initState();
    // Инициализируем контроллер, если его еще нет
    controller = Get.put(SellerOrderProcessingController());
  }

  @override
  void dispose() {
    // Удаляем контроллер при выходе с экрана, чтобы избежать утечек памяти
    Get.delete<SellerOrderProcessingController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SellerOrderProcessingController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Статус вылета дрона"),
            backgroundColor: Colors.orange,
          ),
          body: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Отправка заказа",
                  style: KTextTheme.lightTextTheme.headlineSmall,
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.statuses.length,
                    itemBuilder: (context, index) {
                      return Obx(() => Card(
                            margin: EdgeInsets.only(bottom: 12),
                            child: CheckboxListTile(
                              title: Text(
                                controller.statuses[index],
                                style: KTextTheme.lightTextTheme.titleMedium,
                              ),
                              value: index <= controller.currentStep.value,
                              onChanged: null,
                              secondary: Icon(
                                index <= controller.currentStep.value
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: index <= controller.currentStep.value
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                            ),
                          ));
                    },
                  ),
                ),
                // Убираем кнопки "Назад" и "Далее" как у техника
              ],
            ),
          ),
        );
      },
    );
  }
}
