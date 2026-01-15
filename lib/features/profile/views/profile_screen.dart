import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kollibry/routes/app_routes.dart';
import '../../../common/styles/colors.dart';
import '../../../common/themes/text_theme.dart';
import '../../../common/themes/theme.dart';
import '../../../utils/device/screen_util.dart';
import '../controllers/profile_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Используем Get.find() чтобы получить существующий экземпляр, или создаем новый
  late final ProfileController profileController;
  final GetStorage box = GetStorage();
  
  // Получаем текущую роль пользователя
  String get _currentRole {
    return box.read('role') ?? 'buyer';
  }
  
  // Получаем название роли для отображения
  String get _roleDisplayName {
    switch (_currentRole) {
      case 'buyer':
        return 'Покупатель';
      case 'seller':
        return 'Продавец';
      case 'technician':
      case 'tech':
        return 'Техник';
      default:
        return 'Пользователь';
    }
  }

  @override
  void initState() {
    super.initState();
    // Пытаемся найти существующий контроллер, если нет - создаем новый
    try {
      profileController = Get.find<ProfileController>();
    } catch (e) {
      profileController = Get.put(ProfileController());
    }
    
    // Обновляем данные профиля при открытии экрана
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Всегда обновляем данные при открытии профиля, чтобы показать актуальную информацию
      profileController.fetchProfileData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Обновляем данные при возврате с экрана редактирования
    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileController.fetchProfileData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Профиль - $_roleDisplayName',
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
                    (profileController.firstName.value.isNotEmpty || 
                     profileController.lastName.value.isNotEmpty)
                        ? '${profileController.firstName.value} ${profileController.lastName.value}'.trim()
                        : 'Имя не указано',
                    style: KTextTheme
                        .lightTextTheme.headlineLarge, // Имя пользователя
                  ),
                ],
              ),
              SizedBox(height: ScreenUtil.adaptiveHeight(10)),

              // Почта
              if (profileController.email.value.isNotEmpty)
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
                  profileController.phone.value.isNotEmpty
                      ? profileController.phone.value
                      : 'Телефон не указан',
                  style: KTextTheme.lightTextTheme.headlineSmall, // Телефон
                ),
              ),

              // Точка доставки/отправки (в зависимости от роли)
              ListTile(
                leading: Icon(Icons.location_on, color: KColors.primary),
                title: Text(
                  profileController.deliveryPoint.value.isEmpty
                      ? (_currentRole == 'seller' 
                          ? 'Точка отправки не установлена'
                          : 'Точка доставки не установлена')
                      : profileController.deliveryPoint.value,
                  style:
                      KTextTheme.lightTextTheme.headlineSmall, // Адрес доставки/отправки
                ),
                trailing: IconButton(
                  icon: Icon(Icons.edit, color: KColors.primary),
                  onPressed: () => Get.toNamed(
                    '/delivery-point',
                    arguments: {'role': _currentRole},
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
