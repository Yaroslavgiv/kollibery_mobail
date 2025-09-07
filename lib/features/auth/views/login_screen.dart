import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kollibry/common/themes/theme.dart';

import '../../../common/styles/colors.dart';
import '../../../common/styles/image_strings.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/constants/strings.dart';
import '../../../utils/device/screen_util.dart';
import '../controllers/auth_controller.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class LoginScreen extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Верхняя синяя часть экрана
          Positioned.fill(
            child: Container(
              padding: EdgeInsets.only(
                bottom: ScreenUtil.adaptiveWidth(400),
              ),
              color: KColors.primary, // Синий фон
              child: Align(
                alignment: Alignment.topCenter,
                child: Image.asset(
                  KImages.logoWhite, // Логотип
                  height: ScreenUtil.percentHeight(60.0),
                  width: ScreenUtil.percentWidth(80.0),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Плавающий белый контейнер
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.only(
                bottom: ScreenUtil.adaptiveWidth(70),
                right: ScreenUtil.adaptiveWidth(20),
                left: ScreenUtil.adaptiveWidth(20),
              ),
              padding: EdgeInsets.symmetric(
                vertical: ScreenUtil.adaptiveHeight(20),
                horizontal: ScreenUtil.adaptiveWidth(20),
              ),
              decoration: BoxDecoration(
                color: KColors.backgroundLight, // Белый фон
                borderRadius: BorderRadius.circular(20), // Закруглённые углы
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1), // Тень
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Заголовок экрана
                    Text(
                      Strings.loginTitle,
                      style: TAppTheme.lightTheme.textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: ScreenUtil.adaptiveHeight(20),
                    ),
                    // Поле ввода email
                    CustomTextField(
                      hintText: Strings.emailHint,
                      controller: authController.emailController,
                      prefixIcon: Icons.email, // Иконка email
                    ),
                    SizedBox(
                      height: ScreenUtil.adaptiveHeight(16),
                    ),
                    // Поле ввода пароля
                    CustomTextField(
                      hintText: Strings.passwordHint,
                      controller: authController.passwordController,
                      obscureText: true,
                      prefixIcon: Icons.lock, // Иконка пароля
                    ),
                    SizedBox(
                      height: ScreenUtil.adaptiveHeight(10),
                    ),
                    // Ссылка на экран восстановления пароля
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
                        child: Text(
                          Strings.forgotPasswordTitle,
                          style: TAppTheme.lightTheme.textTheme.titleSmall,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: ScreenUtil.adaptiveHeight(20),
                    ),
                    // Кнопка "Войти"
                    CustomButton(
                      text: Strings.loginButton,
                      onPressed: () => authController.login(),
                      // authController.login(),
                    ),
                    SizedBox(
                      height: ScreenUtil.adaptiveHeight(16),
                    ),
                    // Ссылка на экран регистрации
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          Strings.newUserText,
                          style: TAppTheme.lightTheme.textTheme.titleSmall,
                        ),
                        TextButton(
                          onPressed: () => Get.toNamed(AppRoutes.register),
                          child: Text(
                            Strings.signUpLink,
                            style: TAppTheme.lightTheme.textTheme.titleSmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
