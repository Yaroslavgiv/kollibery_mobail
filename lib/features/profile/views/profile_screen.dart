import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kollibry/routes/app_routes.dart';
import '../../../common/styles/colors.dart';
import '../../../common/themes/text_theme.dart';
import '../../../common/themes/theme.dart';
import '../../../utils/device/screen_util.dart';
import '../controllers/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  final ProfileController profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Профиль',
            style: TAppTheme
                .lightTheme.appBarTheme.titleTextStyle // Заголовок из темы
            ),
        backgroundColor: KColors.primary,
      ),
      body: Obx(() {
        return Padding(
          padding: EdgeInsets.all(ScreenUtil.adaptiveWidth(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Фото профиля
              Center(
                child: GestureDetector(
                  onTap: profileController.pickProfileImage,
                  child: CircleAvatar(
                    radius: ScreenUtil.adaptiveHeight(50),
                    backgroundColor: KColors.primary.withOpacity(0.2),
                    backgroundImage: profileController
                            .profileImage.value.isEmpty
                        ? null
                        : FileImage(File(profileController.profileImage.value)),
                    child: profileController.profileImage.value.isEmpty
                        ? Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: KColors.primary,
                          )
                        : null,
                  ),
                ),
              ),
              SizedBox(height: ScreenUtil.adaptiveHeight(20)),

              // Имя пользователя
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${profileController.firstName.value} ${profileController.lastName.value}',
                    style: KTextTheme
                        .lightTextTheme.headlineLarge, // Имя пользователя
                  ),
                ],
              ),
              SizedBox(height: ScreenUtil.adaptiveHeight(10)),

              // Почта
              ListTile(
                leading: Icon(Icons.email, color: KColors.primary),
                title: Text(
                  profileController.email.value,
                  style: KTextTheme.lightTextTheme.headlineSmall, // Текст почты
                ),
              ),

              // Телефон
              ListTile(
                leading: Icon(Icons.phone, color: KColors.primary),
                title: Text(
                  profileController.phone.value,
                  style: KTextTheme.lightTextTheme.headlineSmall, // Телефон
                ),
              ),

              // Точка доставки
              ListTile(
                leading: Icon(Icons.location_on, color: KColors.primary),
                title: Text(
                  profileController.deliveryPoint.value.isEmpty
                      ? 'Точка доставки не установлена'
                      : profileController.deliveryPoint.value,
                  style:
                      KTextTheme.lightTextTheme.headlineSmall, // Адрес доставки
                ),
                trailing: IconButton(
                  icon: Icon(Icons.edit, color: KColors.primary),
                  onPressed: () => Get.toNamed(
                    '/delivery-point',
                    arguments: {'role': 'seller'},
                  ),
                ),
              ),

              // Кнопка редактирования профиля
              SizedBox(height: ScreenUtil.adaptiveHeight(20)),
              Center(
                child: ElevatedButton(
                  onPressed: () => Get.toNamed(AppRoutes.profileEdit),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KColors.primary,
                    padding: EdgeInsets.symmetric(
                      vertical: ScreenUtil.adaptiveHeight(15),
                      horizontal: ScreenUtil.adaptiveWidth(40),
                    ),
                  ),
                  child: Text(
                    'Редактировать данные',
                    style: KTextTheme.lightTextTheme.bodyLarge, // Стиль кнопки
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
