import 'model_utils.dart';

class TermVersion {
  const TermVersion({
    this.termId,
    required this.version,
    required this.contentChecksum,
    required this.publishedAt,
    this.active = true,
  });

  final int? termId;
  final String version;
  final String contentChecksum;
  final DateTime publishedAt;
  final bool active;

  Map<String, Object?> toMap() => {
        'termino_id': termId,
        'version': version,
        'contenido_checksum': contentChecksum,
        'publicado_at': ModelUtils.dateToText(publishedAt),
        'activo': ModelUtils.boolToInt(active),
      };

  factory TermVersion.fromMap(Map<String, Object?> map) => TermVersion(
        termId: map['termino_id'] as int?,
        version: map['version'] as String,
        contentChecksum: map['contenido_checksum'] as String,
        publishedAt: ModelUtils.textToDate(map['publicado_at'] as String),
        active: ModelUtils.intToBool(map['activo'] as int),
      );
}
