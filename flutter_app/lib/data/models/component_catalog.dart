import 'model_utils.dart';

class ComponentCatalog {
  const ComponentCatalog({
    this.componentId,
    required this.code,
    required this.controlType,
    this.description,
    this.active = true,
  });

  final int? componentId;
  final String code;
  final String controlType;
  final String? description;
  final bool active;

  Map<String, Object?> toMap() => {
        'componente_id': componentId,
        'codigo': code,
        'tipo_control': controlType,
        'descripcion': description,
        'activo': ModelUtils.boolToInt(active),
      };

  factory ComponentCatalog.fromMap(Map<String, Object?> map) => ComponentCatalog(
        componentId: map['componente_id'] as int?,
        code: map['codigo'] as String,
        controlType: map['tipo_control'] as String,
        description: map['descripcion'] as String?,
        active: ModelUtils.intToBool(map['activo'] as int),
      );
}
