import 'model_utils.dart';

class UserTermAcceptance {
  const UserTermAcceptance({
    this.acceptanceId,
    required this.userId,
    required this.termId,
    this.accepted = true,
    required this.acceptedAt,
    this.ipOrigin,
    this.userAgent,
  });

  final int? acceptanceId;
  final int userId;
  final int termId;
  final bool accepted;
  final DateTime acceptedAt;
  final String? ipOrigin;
  final String? userAgent;

  Map<String, Object?> toMap() => {
        'aceptacion_id': acceptanceId,
        'usuario_id': userId,
        'termino_id': termId,
        'aceptado': ModelUtils.boolToInt(accepted),
        'aceptado_at': ModelUtils.dateToText(acceptedAt),
        'ip_origen': ipOrigin,
        'user_agent': userAgent,
      };

  factory UserTermAcceptance.fromMap(Map<String, Object?> map) =>
      UserTermAcceptance(
        acceptanceId: map['aceptacion_id'] as int?,
        userId: map['usuario_id'] as int,
        termId: map['termino_id'] as int,
        accepted: ModelUtils.intToBool(map['aceptado'] as int),
        acceptedAt: ModelUtils.textToDate(map['aceptado_at'] as String),
        ipOrigin: map['ip_origen'] as String?,
        userAgent: map['user_agent'] as String?,
      );
}
