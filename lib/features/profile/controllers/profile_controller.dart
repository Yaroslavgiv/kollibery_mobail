import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../../domain/services/auth_service.dart';

class ProfileController extends GetxController {
  // Объекты данных профиля
  final RxString profileImage = ''.obs; // Путь к изображению профиля
  final RxString firstName = ''.obs; // Имя пользователя
  final RxString lastName = ''.obs; // Фамилия пользователя
  final RxString email = ''.obs; // Электронная почта
  final RxString phone = ''.obs; // Телефон
  final RxString deliveryPoint = ''.obs; // Точка доставки

  final GetStorage storage = GetStorage(); // Локальное хранилище
  final AuthService _authService =
      Get.find<AuthService>(); // Сервис авторизации/профиля
  final RxBool isLoading = false.obs; // Флаг загрузки

  @override
  void onInit() {
    super.onInit();
    fetchProfileData(); // Загружаем данные при инициализации
  }

  /// Загрузка данных профиля из локального хранилища или API
  Future<void> fetchProfileData() async {
    try {
      // Получаем текущую роль для отладки
      final currentRole = storage.read<String>('role') ?? 'unknown';
      final currentEmail = storage.read<String>('email') ?? 'unknown';

      print('📥 Загрузка данных профиля:');
      print('   - Текущая роль: $currentRole');
      print('   - Текущий email: $currentEmail');

      // Сначала загружаем данные из локального хранилища для быстрого отображения
      // Используем ключ с учетом роли
      final storageKey = _getProfileStorageKey();
      final storedData = storage.read<Map<String, dynamic>>(storageKey);
      
      // Для обратной совместимости: если данных нет для текущей роли, 
      // пробуем загрузить из старого ключа 'userProfile'
      Map<String, dynamic>? profileData = storedData;
      if (profileData == null || profileData.isEmpty) {
        final oldData = storage.read<Map<String, dynamic>>('userProfile');
        if (oldData != null && oldData.isNotEmpty) {
          print('⚠️ Найдены данные в старом формате, мигрируем в новый формат');
          profileData = oldData;
        }
      }
      
      if (profileData != null && profileData.isNotEmpty) {
        firstName.value = profileData['firstName']?.toString().trim() ?? '';
        lastName.value = profileData['lastName']?.toString().trim() ?? '';
        email.value = profileData['email']?.toString().trim() ?? '';
        phone.value = profileData['phone']?.toString().trim() ?? '';
        deliveryPoint.value =
            profileData['deliveryPoint']?.toString().trim() ?? '';
        profileImage.value =
            profileData['profileImage']?.toString().trim() ?? '';

        // Отладочная информация
        print('✅ Данные профиля загружены из локального хранилища (ключ: $storageKey):');
        print('   - firstName: ${firstName.value}');
        print('   - lastName: ${lastName.value}');
        print('   - email: ${email.value}');
        print('   - phone: ${phone.value}');

        // Если данные были загружены из старого формата, сохраняем в новый формат
        if (storedData == null || storedData.isEmpty) {
          saveProfileData();
        }

        // Проверяем, что email совпадает с текущим пользователем
        if (email.value.isNotEmpty &&
            currentEmail != 'unknown' &&
            email.value != currentEmail) {
          print(
              '⚠️ ВНИМАНИЕ: Email профиля не совпадает с текущим пользователем!');
          print('   - Email профиля: ${email.value}');
          print('   - Email текущего пользователя: $currentEmail');
        }
      } else {
        // Если данных нет, пробуем получить email из хранилища авторизации
        final authEmail = storage.read<String>('email');
        if (authEmail != null && authEmail.isNotEmpty) {
          email.value = authEmail;
        }

        print('⚠️ Данные профиля не найдены в локальном хранилище для роли: $currentRole');
      }

      // Пытаемся загрузить актуальные данные с сервера
      isLoading.value = true;
      try {
        final apiResponse = await _authService.getProfile();
        if (apiResponse.isNotEmpty) {
          updateProfileFromApi(apiResponse);
        }
      } catch (e) {
        print('Не удалось загрузить профиль с сервера: $e');
      }

      try {
        final userId = storage.read<String>('userId');
        if (userId == null || userId.isEmpty) {
          print('⚠️ userId отсутствует, /account/user не вызван');
          final email = storage.read<String>('email');
          if (email != null && email.isNotEmpty) {
            final userResponse =
                await _authService.getAccountUserByUsername(email);
            if (userResponse.isNotEmpty) {
              updateNameFromAccountUser(userResponse);
              _saveUserIdFromData(userResponse);
            }
          }
        } else if (!_isGuid(userId)) {
          print('⚠️ userId не GUID ($userId), /account/user не вызван');
          final email = storage.read<String>('email');
          if (email != null && email.isNotEmpty) {
            final userResponse =
                await _authService.getAccountUserByUsername(email);
            if (userResponse.isNotEmpty) {
              updateNameFromAccountUser(userResponse);
              _saveUserIdFromData(userResponse);
            }
          }
        } else {
          final userResponse = await _authService.getAccountUser(userId);
          if (userResponse.isNotEmpty) {
            updateNameFromAccountUser(userResponse);
            _saveUserIdFromData(userResponse);
          }
        }
      } catch (e) {
        print('Не удалось загрузить пользователя с сервера: $e');
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
    // Обновляем только те поля, которые пришли с сервера
    // Сохраняем существующие данные, если сервер их не вернул
    firstName.value = data['firstName']?.toString().trim() ?? firstName.value;
    lastName.value = data['lastName']?.toString().trim() ?? lastName.value;
    email.value = data['email']?.toString().trim() ?? email.value;
    phone.value = data['phone']?.toString().trim() ?? phone.value;
    deliveryPoint.value =
        data['deliveryPoint']?.toString().trim() ?? deliveryPoint.value;
    profileImage.value =
        data['profileImage']?.toString().trim() ?? profileImage.value;
    saveProfileData(); // Сохраняем данные локально

    print('✅ Данные профиля обновлены из API:');
    print('   - firstName: ${firstName.value}');
    print('   - lastName: ${lastName.value}');
    print('   - email: ${email.value}');
  }

  /// Обновление имени из /account/user
  void updateNameFromAccountUser(Map<String, dynamic> data) {
    print('🔎 /account/user keys: ${data.keys.toList()}');
    print('🔎 /account/user payload: $data');
    final rawName = _extractFullName(data);
    final rawFirstName = _extractString(data, ['firstName', 'givenName']);
    final rawLastName =
        _extractString(data, ['lastName', 'surname', 'surName', 'familyName']);

    if ((rawName == null || rawName.isEmpty) &&
        (rawFirstName == null || rawFirstName.isEmpty) &&
        (rawLastName == null || rawLastName.isEmpty)) {
      print('⚠️ /account/user не содержит имени. Обновление пропущено.');
      return;
    }

    if ((rawFirstName != null && rawFirstName.isNotEmpty) ||
        (rawLastName != null && rawLastName.isNotEmpty)) {
      if (rawFirstName != null && rawFirstName.isNotEmpty) {
        firstName.value = rawFirstName;
      }
      if (rawLastName != null && rawLastName.isNotEmpty) {
        lastName.value = rawLastName;
      }
    } else if (rawName != null && rawName.isNotEmpty) {
      final parts = rawName.split(RegExp(r'\s+'));
      if (parts.isNotEmpty) {
        firstName.value = parts.first;
        lastName.value = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      }
    }

    // Телефон из /account/user (не затираем локальный, если сервер вернул null)
    final serverPhone = data['phoneNumber']?.toString().trim();
    if (serverPhone != null && serverPhone.isNotEmpty) {
      phone.value = serverPhone;
    }

    saveProfileData();

    print('✅ Имя обновлено из /account/user:');
    print('   - firstName: ${firstName.value}');
    print('   - lastName: ${lastName.value}');
    print('   - phone: ${phone.value}');
  }

  String? _extractFullName(Map<String, dynamic> data) {
    return _extractString(
        data, ['fullName', 'name', 'fio', 'displayName', 'userName']);
  }

  String? _extractString(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value != null) {
        final text = value.toString().trim();
        if (text.isNotEmpty) {
          return text;
        }
      }
    }
    return null;
  }

  bool _isGuid(String value) {
    final guidRegex = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    return guidRegex.hasMatch(value);
  }

  void _saveUserIdFromData(Map<String, dynamic> data) {
    final rawId = data['userId']?.toString() ?? data['id']?.toString() ?? '';
    if (rawId.isEmpty) {
      return;
    }
    if (_isGuid(rawId)) {
      storage.write('userId', rawId);
    } else {
      print('⚠️ userId из ответа не GUID ($rawId), не сохраняем');
    }
  }

  /// Получение ключа хранилища для профиля с учетом роли
  String _getProfileStorageKey() {
    final role = storage.read<String>('role') ?? 'buyer';
    // Нормализуем роль техника: 'tech' и 'technician' используют один ключ
    final normalizedRole = (role == 'tech' || role == 'technician') ? 'technician' : role;
    return 'userProfile_$normalizedRole';
  }

  /// Сохранение данных профиля в локальное хранилище с учетом роли
  void saveProfileData() {
    final storageKey = _getProfileStorageKey();
    storage.write(storageKey, {
      'firstName': firstName.value,
      'lastName': lastName.value,
      'email': email.value,
      'phone': phone.value,
      'deliveryPoint': deliveryPoint.value,
      'profileImage': profileImage.value,
    });
    print('💾 Данные профиля сохранены под ключом: $storageKey');
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
    // СРАЗУ обновляем локальные данные для мгновенного отображения в UI
    this.firstName.value = firstName;
    this.lastName.value = lastName;
    this.email.value = email;
    this.phone.value = phone;

    // Получаем текущую роль для логирования
    final currentRole = storage.read<String>('role') ?? 'buyer';
    
    // СРАЗУ сохраняем в локальное хранилище
    saveProfileData();

    // Обновляем email в хранилище авторизации, если он изменился
    final currentAuthEmail = storage.read<String>('email');
    if (currentAuthEmail != null && currentAuthEmail != email) {
      storage.write('email', email);
      print('✅ Email в хранилище авторизации обновлен: $email');
    }

    print('✅ Данные профиля обновлены локально и отображаются в UI');
    print('   - Роль: $currentRole');
    print('   - Ключ хранилища: ${_getProfileStorageKey()}');
    print('   - firstName: $firstName');
    print('   - lastName: $lastName');
    print('   - email: $email');
    print('   - phone: $phone');

    try {
      isLoading.value = true;

      // Получаем текущую роль и токен для отладки
      final currentRole = storage.read<String>('role') ?? 'unknown';
      final token = storage.read<String>('token');

      print('📤 Отправка данных на сервер:');
      print('   - Роль: $currentRole');
      print('   - Токен: ${token != null ? "есть" : "отсутствует"}');

      // Проверяем наличие токена
      if (token == null || token.isEmpty) {
        print('⚠️ Токен отсутствует! Данные сохранены только локально.');
        return; // Данные уже сохранены локально выше
      }

      // Отправляем данные на сервер (в фоновом режиме)
      final response = await _authService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone.isNotEmpty ? phone : null,
      );

      print('✅ Ответ сервера при обновлении профиля:');
      print('   - Ключи в ответе: ${response.keys.toList()}');
      print('   - response: $response');

      // Обновляем данные из ответа сервера, если они есть (может быть другая нормализация)
      if (response.isNotEmpty) {
        if (response['firstName'] != null) {
          this.firstName.value = response['firstName'].toString().trim();
        }
        if (response['lastName'] != null) {
          this.lastName.value = response['lastName'].toString().trim();
        }
        if (response['email'] != null) {
          this.email.value = response['email'].toString().trim();
        }
        if (response['phone'] != null) {
          this.phone.value = response['phone'].toString().trim();
        }

        // Сохраняем обновленные данные из сервера
        saveProfileData();

        print('✅ Данные синхронизированы с сервером');
      }
    } catch (e) {
      print('❌ Ошибка при отправке на сервер: $e');
      print('✅ Данные остаются сохраненными локально и отображаются в UI');

      // НЕ пробрасываем ошибку, так как данные уже сохранены локально
      // Пользователь видит обновленные данные, даже если сервер недоступен
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
