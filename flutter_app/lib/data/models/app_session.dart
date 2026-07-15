import 'model_utils.dart';

class AppSession {
  const AppSession({
    this.sessionId,
    required this.userId,
    required this.publicToken,
    required this.startedAt,
    this.closedAt,
    required this.status,
    this.closeReason,
    this.device,
    this.appVersion,
  });

  final int? sessionId;
  final int userId;
  final String publicToken;
  final DateTime startedAt;
  final DateTime? closedAt;
  final String status;
  final String? closeReason;
  final String? device;
  final String? appVersion;

  Map<String, Object?> toMap() => {
        'sesion_id': sessionId,
        'usuario_id': userId,
        'token_publico': publicToken,
        'iniciado_at': ModelUtils.dateToText(startedAt),
        'cerrado_at': closedAt == null ? null : ModelUtils.dateToText(closedAt!),
        'estado': status,
        'motivo_cierre': closeReason,
        'dispositivo': device,
        'app_version': appVersion,
      };

  factory AppSession.fromMap(Map<String, Object?> map) => AppSession(
        sessionId: map['sesion_id'] as int?,
        userId: map['usuario_id'] as int,
        publicToken: map['token_publico'] as String,
        startedAt: ModelUtils.textToDate(map['iniciado_at'] as String),
        closedAt: map['cerrado_at'] == null
            ? null
            : ModelUtils.textToDate(map['cerrado_at'] as String),
        status: map['estado'] as String,
        closeReason: map['motivo_cierre'] as String?,
        device: map['dispositivo'] as String?,
        appVersion: map['app_version'] as String?,
      );
}
