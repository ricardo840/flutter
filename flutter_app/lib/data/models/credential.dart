import 'model_utils.dart';

class Credential {
  const Credential({
    required this.userId,
    required this.passwordHash,
    required this.hashAlgo,
    required this.passwordUpdatedAt,
    this.failedAttempts = 0,
    this.blockedUntil,
  });

  final int userId;
  final String passwordHash;
  final String hashAlgo;
  final DateTime passwordUpdatedAt;
  final int failedAttempts;
  final DateTime? blockedUntil;

  Map<String, Object?> toMap() => {
        'usuario_id': userId,
        'password_hash': passwordHash,
        'hash_algo': hashAlgo,
        'password_updated_at': ModelUtils.dateToText(passwordUpdatedAt),
        'failed_attempts': failedAttempts,
        'blocked_until':
            blockedUntil == null ? null : ModelUtils.dateToText(blockedUntil!),
      };

  factory Credential.fromMap(Map<String, Object?> map) => Credential(
        userId: map['usuario_id'] as int,
        passwordHash: map['password_hash'] as String,
        hashAlgo: map['hash_algo'] as String,
        passwordUpdatedAt:
            ModelUtils.textToDate(map['password_updated_at'] as String),
        failedAttempts: map['failed_attempts'] as int,
        blockedUntil: map['blocked_until'] == null
            ? null
            : ModelUtils.textToDate(map['blocked_until'] as String),
      );
}
