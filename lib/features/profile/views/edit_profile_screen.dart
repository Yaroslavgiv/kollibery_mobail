import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/styles/colors.dart';
import '../../../common/themes/text_theme.dart';
import '../../../common/themes/theme.dart';
import '../../../utils/device/screen_util.dart';
import '../controllers/profile_controller.dart';

class EditProfileScreen extends StatelessWidget {
  final ProfileController profileController = Get.find<ProfileController>();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Заполняем текстовые поля текущими данными пользователя
    firstNameController.text = profileController.firstName.value;
    lastNameController.text = profileController.lastName.value;
    emailController.text = profileController.email.value;
    phoneController.text = profileController.phone.value;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Редактировать профиль',
          style: TAppTheme.lightTheme.appBarTheme
              .titleTextStyle, // Используем стиль заголовка из темы
        ),
        backgroundColor: KColors.primary,
      ),
      body: Padding(
        padding: EdgeInsets.all(ScreenUtil.adaptiveWidth(20)),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Поле "Имя"
              Text(
                'Имя',
                style: KTextTheme.lightTextTheme
                    .headlineSmall, // Используем стиль текста из темы
              ),
              SizedBox(height: ScreenUtil.adaptiveHeight(5)),
              TextField(
                controller: firstNameController,
                style: TAppTheme.lightTheme.textTheme.labelLarge,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: TAppTheme.lightTheme.focusColor,
                ),
              ),
              SizedBox(height: ScreenUtil.adaptiveHeight(20)),

              // Поле "Фамилия"
              Text(
                'Фамилия',
                style: KTextTheme.lightTextTheme.headlineSmall,
              ),
              SizedBox(height: ScreenUtil.adaptiveHeight(5)),
              TextField(
                controller: lastNameController,
                style: TAppTheme.lightTheme.textTheme.labelLarge,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: TAppTheme.lightTheme.focusColor,
                ),
              ),
              SizedBox(height: ScreenUtil.adaptiveHeight(20)),

              // Поле "Почта"
              Text(
                'Почта',
                style: KTextTheme.lightTextTheme.headlineSmall,
              ),
              SizedBox(height: ScreenUtil.adaptiveHeight(5)),
              TextField(
                controller: emailController,
                style: TAppTheme.lightTheme.textTheme.labelLarge,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: TAppTheme.lightTheme.focusColor,
                ),
              ),
              SizedBox(height: ScreenUtil.adaptiveHeight(20)),

              // Поле "Телефон"
              Text(
                'Телефон',
                style: KTextTheme.lightTextTheme.headlineSmall,
              ),
              SizedBox(height: ScreenUtil.adaptiveHeight(5)),
              TextField(
                controller: phoneController,
                style: TAppTheme.lightTheme.textTheme.labelLarge,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: TAppTheme.lightTheme.focusColor,
                ),
              ),
              SizedBox(height: ScreenUtil.adaptiveHeight(30)),

              // Кнопка сохранения
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Обновляем данные профиля
                    profileController.updateProfile(
                      firstName: firstNameController.text,
                      lastName: lastNameController.text,
                      email: emailController.text,
                      phone: phoneController.text,
                    );

                    // Возвращаемся на предыдущий экран
                    Get.back();

                    // Показываем уведомление
                    Get.snackbar(
                      'Успешно',
                      'Данные профиля обновлены',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KColors.primary,
                    padding: EdgeInsets.symmetric(
                      vertical: ScreenUtil.adaptiveHeight(15),
                      horizontal: ScreenUtil.adaptiveWidth(40),
                    ),
                  ),
                  child: Text(
                    'Сохранить',
                    style: KTextTheme.lightTextTheme.bodyLarge, // Стиль кнопки
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
