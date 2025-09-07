import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  // Объекты данных профиля
  final RxString profileImage = ''.obs; // Путь к изображению профиля
  final RxString firstName = 'Имя'.obs; // Имя пользователя
  final RxString lastName = 'Фамилия'.obs; // Фамилия пользователя
  final RxString email = 'example@mail.com'.obs; // Электронная почта
  final RxString phone = '+7 (123) 456-78-90'.obs; // Телефон
  final RxString deliveryPoint = 'Адрес не указан'.obs; // Точка доставки

  final GetStorage storage = GetStorage(); // Локальное хранилище

  @override
  void onInit() {
    super.onInit();
    fetchProfileData(); // Загружаем данные при инициализации
  }

  /// Загрузка данных профиля из локального хранилища или API
  Future<void> fetchProfileData() async {
    try {
      // Проверяем данные в локальном хранилище
      final storedData = storage.read<Map<String, dynamic>>('userProfile');
      if (storedData != null) {
        firstName.value = storedData['firstName'] ?? 'Имя';
        lastName.value = storedData['lastName'] ?? 'Фамилия';
        email.value = storedData['email'] ?? 'example@mail.com';
        phone.value = storedData['phone'] ?? '+7 (123) 456-78-90';
        deliveryPoint.value = storedData['deliveryPoint'] ?? 'Адрес не указан';
        profileImage.value = storedData['profileImage'] ?? '';
      } else {
        // Если данных нет, эмулируем запрос к API
        final apiResponse = await fetchFromApi();
        if (apiResponse != null) {
          updateProfileFromApi(apiResponse);
        }
      }
    } catch (e) {
      Get.snackbar('Ошибка', 'Не удалось загрузить данные профиля');
    }
  }

  /// Эмуляция API-запроса
  Future<Map<String, dynamic>> fetchFromApi() async {
    await Future.delayed(Duration(seconds: 2)); // Имитация задержки запроса
    return {
      'firstName': 'Алексей',
      'lastName': 'Иванов',
      'email': 'alexey.ivanov@mail.com',
      'phone': '+7 (999) 123-45-67',
      'deliveryPoint': 'Москва, ул. Пушкина, д. 10',
      'profileImage': '',
    };
  }

  /// Обновление данных из API
  void updateProfileFromApi(Map<String, dynamic> data) {
    firstName.value = data['firstName'];
    lastName.value = data['lastName'];
    email.value = data['email'];
    phone.value = data['phone'];
    deliveryPoint.value = data['deliveryPoint'];
    profileImage.value = data['profileImage'];
    saveProfileData(); // Сохраняем данные локально
  }

  /// Сохранение данных профиля в локальное хранилище
  void saveProfileData() {
    storage.write('userProfile', {
      'firstName': firstName.value,
      'lastName': lastName.value,
      'email': email.value,
      'phone': phone.value,
      'deliveryPoint': deliveryPoint.value,
      'profileImage': profileImage.value,
    });
  }

  /// Выбор изображения профиля из галереи
  Future<void> pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      profileImage.value = pickedFile.path;
      saveProfileData();
    }
  }

  /// Обновление данных профиля
  void updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) {
    this.firstName.value = firstName;
    this.lastName.value = lastName;
    this.email.value = email;
    this.phone.value = phone;
    saveProfileData();
  }

  /// Обновление точки доставки
  void updateDeliveryPoint(String point) {
    deliveryPoint.value = point;
    saveProfileData();
  }
}
