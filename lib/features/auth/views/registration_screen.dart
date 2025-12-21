import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/styles/colors.dart';
import '../../../common/styles/image_strings.dart';
import '../../../common/themes/theme.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/device/screen_util.dart';
import '../controllers/auth_controller.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class RegistrationScreen extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());

  RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Верхняя "синяя" часть экрана
          Positioned.fill(
            child: Container(
              color: KColors.primary,
              padding: EdgeInsets.only(
                bottom: ScreenUtil.adaptiveWidth(400),
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Image.asset(
                  KImages.logoWhite,
                  height: ScreenUtil.percentHeight(60.0),
                  width: ScreenUtil.percentWidth(80.0),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Белое "окно" со всеми полями
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
                color: KColors.backgroundLight,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Регистрация',
                      style: TAppTheme.lightTheme.textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: ScreenUtil.adaptiveHeight(20)),

                    // Имя
                    CustomTextField(
                      hintText: 'Имя',
                      controller: authController.firstNameController,
                      prefixIcon: Icons.person,
                    ),
                    SizedBox(height: ScreenUtil.adaptiveHeight(16)),

                    // Фамилия
                    CustomTextField(
                      hintText: 'Фамилия',
                      controller: authController.lastNameController,
                      prefixIcon: Icons.person_outline,
                    ),
                    SizedBox(height: ScreenUtil.adaptiveHeight(16)),

                    // Email
                    CustomTextField(
                      hintText: 'Email',
                      controller: authController.emailController,
                      prefixIcon: Icons.email,
                    ),
                    SizedBox(height: ScreenUtil.adaptiveHeight(16)),

                    // Пароль
                    CustomTextField(
                      hintText: 'Пароль',
                      controller: authController.passwordController,
                      obscureText: true,
                      prefixIcon: Icons.lock,
                    ),
                    SizedBox(height: ScreenUtil.adaptiveHeight(16)),

                    // Повтор пароля
                    CustomTextField(
                      hintText: 'Подтвердите пароль',
                      controller: authController.confirmPasswordController,
                      obscureText: true,
                      prefixIcon: Icons.lock_outline,
                    ),
                    SizedBox(height: ScreenUtil.adaptiveHeight(20)),

                    // Две кнопки для выбора роли
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Покупатель',
                            onPressed: () {
                              authController.roleController.text = 'buyer';
                              authController.register();
                            },
                          ),
                        ),
                        SizedBox(width: ScreenUtil.adaptiveWidth(16)),
                        Expanded(
                          child: CustomButton(
                            text: 'Продавец',
                            onPressed: () {
                              authController.roleController.text = 'seller';
                              authController.register();
                            },
                          ),
                        ),
                        SizedBox(width: ScreenUtil.adaptiveWidth(16)),
                        Expanded(
                          child: CustomButton(
                            text: 'Техник',
                            onPressed: () {
                              authController.roleController.text = 'technician';
                              authController.register();
                            },
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: ScreenUtil.adaptiveHeight(16)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Уже есть аккаунт?',
                          style: TAppTheme.lightTheme.textTheme.titleSmall,
                        ),
                        TextButton(
                          onPressed: () => Get.toNamed(AppRoutes.login),
                          child: Text(
                            'Войти',
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
