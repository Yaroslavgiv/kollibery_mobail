import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/repositories/auth_repository.dart';

class ProfileController extends GetxController {
  // Объекты данных профиля
  final RxString profileImage = ''.obs; // Путь к изображению профиля
  final RxString firstName = 'Имя'.obs; // Имя пользователя
  final RxString lastName = 'Фамилия'.obs; // Фамилия пользователя
  final RxString email = 'example@mail.com'.obs; // Электронная почта
  final RxString phone = '+7 (123) 456-78-90'.obs; // Телефон
  final RxString deliveryPoint = 'Адрес не указан'.obs; // Точка доставки

  final GetStorage storage = GetStorage(); // Локальное хранилище
  final AuthRepository _authRepository = AuthRepository(); // Репозиторий для работы с API
  final RxBool isLoading = false.obs; // Флаг загрузки

  @override
  void onInit() {
    super.onInit();
    fetchProfileData(); // Загружаем данные при инициализации
  }

  /// Загрузка данных профиля из локального хранилища или API
  Future<void> fetchProfileData() async {
    try {
      // Сначала загружаем данные из локального хранилища для быстрого отображения
      final storedData = storage.read<Map<String, dynamic>>('userProfile');
      if (storedData != null && storedData.isNotEmpty) {
        firstName.value = storedData['firstName']?.toString().trim() ?? '';
        lastName.value = storedData['lastName']?.toString().trim() ?? '';
        email.value = storedData['email']?.toString().trim() ?? '';
        phone.value = storedData['phone']?.toString().trim() ?? '';
        deliveryPoint.value = storedData['deliveryPoint']?.toString().trim() ?? '';
        profileImage.value = storedData['profileImage']?.toString().trim() ?? '';
      } else {
        // Если данных нет, пробуем получить email из хранилища авторизации
        final authEmail = storage.read<String>('email');
        if (authEmail != null && authEmail.isNotEmpty) {
          email.value = authEmail;
        }
      }

      // Пытаемся загрузить актуальные данные с сервера
      try {
        isLoading.value = true;
        final apiResponse = await _authRepository.getProfile();
        if (apiResponse.isNotEmpty) {
          updateProfileFromApi(apiResponse);
        }
      } catch (e) {
        // Если не удалось загрузить с сервера, используем локальные данные
        print('Не удалось загрузить профиль с сервера: $e');
      } finally {
        isLoading.value = false;
      }
    } catch (e) {
      // Не показываем ошибку, если просто нет данных
      print('Ошибка загрузки данных профиля: $e');
      isLoading.value = false;
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
  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) async {
    try {
      isLoading.value = true;

      // Отправляем данные на сервер
      final response = await _authRepository.updateProfile(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone.isNotEmpty ? phone : null,
      );

      // Обновляем локальные данные
      this.firstName.value = firstName;
      this.lastName.value = lastName;
      this.email.value = email;
      this.phone.value = phone;

      // Обновляем данные из ответа сервера, если они есть
      if (response.isNotEmpty) {
        if (response['firstName'] != null) {
          this.firstName.value = response['firstName'].toString();
        }
        if (response['lastName'] != null) {
          this.lastName.value = response['lastName'].toString();
        }
        if (response['email'] != null) {
          this.email.value = response['email'].toString();
        }
        if (response['phone'] != null) {
          this.phone.value = response['phone'].toString();
        }
      }

      // Сохраняем в локальное хранилище
      saveProfileData();
    } catch (e) {
      // Если не удалось отправить на сервер, все равно сохраняем локально
      this.firstName.value = firstName;
      this.lastName.value = lastName;
      this.email.value = email;
      this.phone.value = phone;
      saveProfileData();
      
      // Пробрасываем ошибку дальше для обработки в UI
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Обновление точки доставки
  void updateDeliveryPoint(String point) {
    deliveryPoint.value = point;
    saveProfileData();
  }
}
