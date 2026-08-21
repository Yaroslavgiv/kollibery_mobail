import 'package:get/get.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/storage/local_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/services/auth_service.dart';
import '../../routes/app_routes.dart';

/// Provider сессии. Хранит состояние авторизации.
/// Инжектируется только в менеджеры, не во View.
class SessionProvider extends GetxService {
  SessionProvider({
    LocalStorage? storage,
    AuthService? authService,
  })  : _storage = storage ?? Get.find<LocalStorage>(),
        _authService = authService ?? Get.find<AuthService>();

  final LocalStorage _storage;
  final AuthService _authService;

  final isLoggedIn = false.obs;
  final role = Rxn<UserRole>();
  final token = RxnString();
  final userId = RxnString();
  final email = RxnString();

  SessionProvider initFromStorage() {
    isLoggedIn.value = _storage.read<bool>(StorageKeys.loggedIn) ?? false;
    token.value = _storage.read<String>(StorageKeys.token);
    userId.value = _storage.read<String>(StorageKeys.userId);
    email.value = _storage.read<String>(StorageKeys.email);
    role.value = UserRole.fromString(_storage.read<String>(StorageKeys.role));
    return this;
  }

  String get initialRoute {
    if (!isLoggedIn.value) return AppRoutes.login;
    switch (role.value) {
      case UserRole.seller:
        return AppRoutes.sellerHome;
      case UserRole.technician:
        return AppRoutes.techHome;
      case UserRole.buyer:
        return AppRoutes.home;
      default:
        return AppRoutes.login;
    }
  }

  Map<String, dynamic> readProfile() {
    return _storage.read<Map<String, dynamic>>(StorageKeys.userProfile) ?? {};
  }

  Future<void> writeProfile(Map<String, dynamic> profile) {
    return _storage.write(StorageKeys.userProfile, profile);
  }

  Future<void> persistLogin({
    required String email,
    required Map<String, dynamic> userData,
    Map<String, dynamic>? existingProfile,
  }) async {
    await _storage.write(StorageKeys.loggedIn, true);
    await _storage.write(StorageKeys.email, email);
    this.email.value = email;
    isLoggedIn.value = true;

    final rawToken = userData['token']?.toString();
    if (rawToken != null && rawToken.isNotEmpty) {
      await _storage.write(StorageKeys.token, rawToken);
      token.value = rawToken;
      final roleFromToken = _authService.extractRoleFromToken(rawToken);
      if (roleFromToken != null) {
        await _storage.write(StorageKeys.role, roleFromToken.apiValue);
        role.value = roleFromToken;
      } else {
        await _storage.remove(StorageKeys.role);
        role.value = null;
      }
      final idFromToken = _authService.guidOrNull(
        _authService.extractUserIdFromToken(rawToken),
      );
      if (idFromToken != null) {
        await _saveUserId(idFromToken);
      }
    }

    final idFromResponse = _authService.guidOrNull(
      userData['userId'] ?? userData['id'],
    );
    if (idFromResponse != null) {
      await _saveUserId(idFromResponse);
    }

    final current = existingProfile ?? readProfile();
    await writeProfile({
      'firstName': userData['firstName']?.toString().trim() ??
          current['firstName']?.toString().trim() ??
          '',
      'lastName': userData['lastName']?.toString().trim() ??
          current['lastName']?.toString().trim() ??
          '',
      'email': userData['email']?.toString().trim() ?? email,
      'phone': userData['phone']?.toString().trim() ??
          current['phone']?.toString().trim() ??
          '',
      'deliveryPoint': userData['deliveryPoint']?.toString().trim() ??
          current['deliveryPoint']?.toString().trim() ??
          '',
      'profileImage': userData['profileImage']?.toString().trim() ??
          current['profileImage']?.toString().trim() ??
          '',
    });
  }

  Future<void> mergeAccountUser(
    Map<String, dynamic> data,
    String fallbackEmail,
  ) async {
    final current = UserEntity(
      email: fallbackEmail,
      firstName: readProfile()['firstName']?.toString() ?? '',
      lastName: readProfile()['lastName']?.toString() ?? '',
      phone: readProfile()['phone']?.toString() ?? '',
    );
    final merged = _authService.mergeProfile(current: current, data: data);
    await writeProfile({
      ...readProfile(),
      'firstName': merged.firstName,
      'lastName': merged.lastName,
      'email': merged.email,
      'phone': merged.phone,
    });
    final id = _authService.guidOrNull(data['userId'] ?? data['id']);
    if (id != null) {
      await _saveUserId(id);
    }
  }

  Future<void> _saveUserId(String id) async {
    await _storage.write(StorageKeys.userId, id);
    userId.value = id;
  }

  Future<void> clear() async {
    await _storage.remove(StorageKeys.loggedIn);
    await _storage.remove(StorageKeys.token);
    await _storage.remove(StorageKeys.role);
    await _storage.remove(StorageKeys.email);
    await _storage.remove(StorageKeys.userId);
    await _storage.remove(StorageKeys.userProfile);
    isLoggedIn.value = false;
    token.value = null;
    role.value = null;
    email.value = null;
    userId.value = null;
  }

  String? getToken() => token.value ?? _storage.read<String>(StorageKeys.token);
}
