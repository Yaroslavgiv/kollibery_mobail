import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/styles/colors.dart';
import '../../../common/themes/text_theme.dart';
import '../../../common/themes/theme.dart';
import '../../../utils/device/screen_util.dart';
import '../controllers/profile_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Получаем контроллер, создаем если не существует
  late final ProfileController profileController;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Пытаемся найти существующий контроллер, если нет - создаем новый
    try {
      profileController = Get.find<ProfileController>();
    } catch (e) {
      profileController = Get.put(ProfileController());
    }
    
    // Загружаем данные профиля с учетом роли и заполняем текстовые поля
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Сначала загружаем актуальные данные профиля
      await profileController.fetchProfileData();
      // Затем заполняем текстовые поля
      firstNameController.text = profileController.firstName.value;
      lastNameController.text = profileController.lastName.value;
      phoneController.text = profileController.phone.value;
    });
  }

  @override
  Widget build(BuildContext context) {

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
                child: Obx(() => ElevatedButton(
                  onPressed: profileController.isLoading.value
                      ? null
                      : () async {
                          // Валидация полей
                          if (firstNameController.text.trim().isEmpty) {
                            return;
                          }
                          if (lastNameController.text.trim().isEmpty) {
                            return;
                          }
                          // Обновляем данные профиля (данные сразу сохраняются локально)
                          await profileController.updateProfile(
                            firstName: firstNameController.text.trim(),
                            lastName: lastNameController.text.trim(),
                            email: profileController.email.value,
                            phone: phoneController.text.trim(),
                          );

                          // Перезагружаем данные профиля, чтобы убедиться, что они загружены с правильным ключом
                          await profileController.fetchProfileData();

                          // Показываем сообщение об успехе
                          // Данные уже обновлены локально и отображаются в UI

                          // Возвращаемся на предыдущий экран с результатом, чтобы обновить данные в drawer
                          Get.back(result: true);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KColors.primary,
                    padding: EdgeInsets.symmetric(
                      vertical: ScreenUtil.adaptiveHeight(15),
                      horizontal: ScreenUtil.adaptiveWidth(40),
                    ),
                  ),
                  child: profileController.isLoading.value
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Сохранить',
                          style: KTextTheme.lightTextTheme.bodyLarge, // Стиль кнопки
                        ),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
