import 'user_role.dart';

/// Пользовательская сессия — доменная сущность без Flutter.
class UserEntity {
  const UserEntity({
    required this.email,
    this.id,
    this.firstName = '',
    this.lastName = '',
    this.phone = '',
    this.role,
    this.token,
    this.deliveryPoint = '',
    this.profileImage = '',
  });

  final String? id;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final UserRole? role;
  final String? token;
  final String deliveryPoint;
  final String profileImage;

  String get fullName => '$firstName $lastName'.trim();

  bool get isAuthenticated => token != null && token!.isNotEmpty;

  UserEntity copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    UserRole? role,
    String? token,
    String? deliveryPoint,
    String? profileImage,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      token: token ?? this.token,
      deliveryPoint: deliveryPoint ?? this.deliveryPoint,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}
