import 'model_utils.dart';

class UserComponentState {
  const UserComponentState({
    this.stateId,
    required this.userId,
    required this.componentId,
    this.valueBool,
    this.valueNum,
    this.valueText,
    this.valueJson,
    required this.updatedAt,
  });

  final int? stateId;
  final int userId;
  final int componentId;
  final bool? valueBool;
  final double? valueNum;
  final String? valueText;
  final String? valueJson;
  final DateTime updatedAt;

  Map<String, Object?> toMap() => {
        'estado_id': stateId,
        'usuario_id': userId,
        'componente_id': componentId,
        'valor_bool': valueBool == null ? null : ModelUtils.boolToInt(valueBool!),
        'valor_num': valueNum,
        'valor_texto': valueText,
        'valor_json': valueJson,
        'actualizado_at': ModelUtils.dateToText(updatedAt),
      };

  factory UserComponentState.fromMap(Map<String, Object?> map) =>
      UserComponentState(
        stateId: map['estado_id'] as int?,
        userId: map['usuario_id'] as int,
        componentId: map['componente_id'] as int,
        valueBool: map['valor_bool'] == null
            ? null
            : ModelUtils.intToBool(map['valor_bool'] as int),
        valueNum: (map['valor_num'] as num?)?.toDouble(),
        valueText: map['valor_texto'] as String?,
        valueJson: map['valor_json'] as String?,
        updatedAt: ModelUtils.textToDate(map['actualizado_at'] as String),
      );
}
