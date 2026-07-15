import 'model_utils.dart';

class UiEvent {
  const UiEvent({
    this.eventId,
    this.sessionId,
    this.userId,
    this.componentId,
    required this.screen,
    required this.action,
    this.payloadJson,
    required this.createdAt,
  });

  final int? eventId;
  final int? sessionId;
  final int? userId;
  final int? componentId;
  final String screen;
  final String action;
  final String? payloadJson;
  final DateTime createdAt;

  Map<String, Object?> toMap() => {
        'evento_id': eventId,
        'sesion_id': sessionId,
        'usuario_id': userId,
        'componente_id': componentId,
        'pantalla': screen,
        'accion': action,
        'payload_json': payloadJson,
        'creado_at': ModelUtils.dateToText(createdAt),
      };

  factory UiEvent.fromMap(Map<String, Object?> map) => UiEvent(
        eventId: map['evento_id'] as int?,
        sessionId: map['sesion_id'] as int?,
        userId: map['usuario_id'] as int?,
        componentId: map['componente_id'] as int?,
        screen: map['pantalla'] as String,
        action: map['accion'] as String,
        payloadJson: map['payload_json'] as String?,
        createdAt: ModelUtils.textToDate(map['creado_at'] as String),
      );
}
