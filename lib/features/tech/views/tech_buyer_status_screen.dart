import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/themes/text_theme.dart';
import '../controllers/tech_buyer_status_controller.dart';

class TechBuyerStatusScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<TechBuyerStatusController>(
      init: TechBuyerStatusController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Статус заказа'),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          body: ListView.builder(
            itemCount: controller.statuses.length,
            itemBuilder: (context, index) {
              return Obx(() => CheckboxListTile(
                    title: Text(
                      controller.statuses[index],
                      style: KTextTheme.lightTextTheme.titleMedium,
                    ),
                    value: index <= controller.currentStep.value,
                    onChanged: null,
                  ));
            },
          ),
        );
      },
    );
  }
}
