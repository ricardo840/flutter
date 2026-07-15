import 'model_utils.dart';

class AppUser {
  const AppUser({
    this.userId,
    required this.username,
    this.displayName,
    this.email,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
  });

  final int? userId;
  final String username;
  final String? displayName;
  final String? email;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;

  Map<String, Object?> toMap() => {
        'usuario_id': userId,
        'username': username,
        'display_name': displayName,
        'email': email,
        'estado': status,
        'created_at': ModelUtils.dateToText(createdAt),
        'updated_at': ModelUtils.dateToText(updatedAt),
        'last_login_at':
            lastLoginAt == null ? null : ModelUtils.dateToText(lastLoginAt!),
      };

  factory AppUser.fromMap(Map<String, Object?> map) => AppUser(
        userId: map['usuario_id'] as int?,
        username: map['username'] as String,
        displayName: map['display_name'] as String?,
        email: map['email'] as String?,
        status: map['estado'] as String,
        createdAt: ModelUtils.textToDate(map['created_at'] as String),
        updatedAt: ModelUtils.textToDate(map['updated_at'] as String),
        lastLoginAt: map['last_login_at'] == null
            ? null
            : ModelUtils.textToDate(map['last_login_at'] as String),
      );
}
