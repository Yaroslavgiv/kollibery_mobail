/// Роли пользователей Kollibry.
/// Значения совпадают с тем, что приходит в JWT и уходит на API.
enum UserRole {
  buyer,
  seller,
  technician;

  /// Разбор роли из токена/хранилища.
  static UserRole? fromString(String? value) {
    switch (value) {
      case 'buyer':
        return UserRole.buyer;
      case 'seller':
        return UserRole.seller;
      case 'technician':
        return UserRole.technician;
      default:
        return null;
    }
  }

  /// Строка для API и GetStorage.
  String get apiValue {
    switch (this) {
      case UserRole.buyer:
        return 'buyer';
      case UserRole.seller:
        return 'seller';
      case UserRole.technician:
        return 'technician';
    }
  }

  /// Стартовый маршрут роли задаётся в presentation, здесь только признак.
  bool get canManageCatalog =>
      this == UserRole.seller || this == UserRole.technician;

  bool get canControlDroneHardware => this == UserRole.technician;
}
