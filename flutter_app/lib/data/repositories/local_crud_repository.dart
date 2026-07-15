import 'package:sqflite/sqflite.dart';

import '../local/database_helper.dart';
import '../models/models.dart';

class LocalCrudRepository {
  LocalCrudRepository({DatabaseHelper? helper})
      : _helper = helper ?? DatabaseHelper.instance;

  final DatabaseHelper _helper;

  int _requireId(int? id, String field) {
    if (id == null) {
      throw ArgumentError('El campo $field es obligatorio para esta operacion');
    }
    return id;
  }

  Future<int> _insert(String table, Map<String, Object?> data) async {
    final db = await _helper.database;
    return db.insert(table, data);
  }

  Future<int> _update(
    String table,
    Map<String, Object?> data,
    String where,
    List<Object?> args,
  ) async {
    final db = await _helper.database;
    return db.update(table, data, where: where, whereArgs: args);
  }

  Future<int> _delete(String table, String where, List<Object?> args) async {
    final db = await _helper.database;
    return db.delete(table, where: where, whereArgs: args);
  }

  Future<Map<String, Object?>?> _getById(
    String table,
    String idColumn,
    int id,
  ) async {
    final db = await _helper.database;
    final rows = await db.query(table, where: '$idColumn = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : rows.first;
  }

  Future<List<Map<String, Object?>>> _query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final db = await _helper.database;
    return db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  Future<int> createUser(AppUser user) => _insert('usuario', user.toMap());

  Future<AppUser?> getUserById(int userId) async {
    final row = await _getById('usuario', 'usuario_id', userId);
    return row == null ? null : AppUser.fromMap(row);
  }

  Future<AppUser?> getUserByUsername(String username) async {
    final rows = await _query(
      'usuario',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    return rows.isEmpty ? null : AppUser.fromMap(rows.first);
  }

  Future<int> updateUser(AppUser user) => _update(
        'usuario',
        user.toMap()..remove('usuario_id'),
        'usuario_id = ?',
      [_requireId(user.userId, 'usuario_id')],
      );

  Future<int> deleteUser(int userId) => _delete('usuario', 'usuario_id = ?', [userId]);

  Future<int> upsertCredential(Credential credential) async {
    final db = await _helper.database;
    return db.insert(
      'credencial',
      credential.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Credential?> getCredential(int userId) async {
    final row = await _getById('credencial', 'usuario_id', userId);
    return row == null ? null : Credential.fromMap(row);
  }

  Future<int> deleteCredential(int userId) =>
      _delete('credencial', 'usuario_id = ?', [userId]);

  Future<int> createTerm(TermVersion term) =>
      _insert('termino_version', term.toMap());

  Future<TermVersion?> getTermById(int termId) async {
    final row = await _getById('termino_version', 'termino_id', termId);
    return row == null ? null : TermVersion.fromMap(row);
  }

  Future<TermVersion?> getActiveTerm() async {
    final rows = await _query(
      'termino_version',
      where: 'activo = 1',
      orderBy: 'publicado_at DESC',
      limit: 1,
    );
    return rows.isEmpty ? null : TermVersion.fromMap(rows.first);
  }

  Future<int> updateTerm(TermVersion term) => _update(
        'termino_version',
        term.toMap()..remove('termino_id'),
        'termino_id = ?',
      [_requireId(term.termId, 'termino_id')],
      );

  Future<int> deleteTerm(int termId) =>
      _delete('termino_version', 'termino_id = ?', [termId]);

  Future<int> createAcceptance(UserTermAcceptance acceptance) =>
      _insert('usuario_termino_aceptacion', acceptance.toMap());

  Future<UserTermAcceptance?> getAcceptance(int userId, int termId) async {
    final rows = await _query(
      'usuario_termino_aceptacion',
      where: 'usuario_id = ? AND termino_id = ?',
      whereArgs: [userId, termId],
      limit: 1,
    );
    return rows.isEmpty ? null : UserTermAcceptance.fromMap(rows.first);
  }

  Future<int> deleteAcceptance(int acceptanceId) =>
      _delete('usuario_termino_aceptacion', 'aceptacion_id = ?', [acceptanceId]);

  Future<int> createSession(AppSession session) => _insert('sesion', session.toMap());

  Future<AppSession?> getSessionById(int sessionId) async {
    final row = await _getById('sesion', 'sesion_id', sessionId);
    return row == null ? null : AppSession.fromMap(row);
  }

  Future<AppSession?> getOpenSession(int userId) async {
    final rows = await _query(
      'sesion',
      where: 'usuario_id = ? AND estado = ?',
      whereArgs: [userId, 'abierta'],
      orderBy: 'iniciado_at DESC',
      limit: 1,
    );
    return rows.isEmpty ? null : AppSession.fromMap(rows.first);
  }

  Future<int> updateSession(AppSession session) => _update(
        'sesion',
        session.toMap()..remove('sesion_id'),
        'sesion_id = ?',
      [_requireId(session.sessionId, 'sesion_id')],
      );

  Future<int> deleteSession(int sessionId) =>
      _delete('sesion', 'sesion_id = ?', [sessionId]);

  Future<int> upsertComponent(ComponentCatalog component) async {
    final db = await _helper.database;
    return db.insert(
      'catalogo_componente',
      component.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<ComponentCatalog?> getComponentByCode(String code) async {
    final rows = await _query(
      'catalogo_componente',
      where: 'codigo = ?',
      whereArgs: [code],
      limit: 1,
    );
    return rows.isEmpty ? null : ComponentCatalog.fromMap(rows.first);
  }

  Future<int> deleteComponent(int componentId) =>
      _delete('catalogo_componente', 'componente_id = ?', [componentId]);

  Future<int> upsertUserComponentState(UserComponentState state) async {
    final db = await _helper.database;
    return db.insert(
      'estado_componente_usuario',
      state.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserComponentState?> getUserComponentState(int userId, int componentId) async {
    final rows = await _query(
      'estado_componente_usuario',
      where: 'usuario_id = ? AND componente_id = ?',
      whereArgs: [userId, componentId],
      limit: 1,
    );
    return rows.isEmpty ? null : UserComponentState.fromMap(rows.first);
  }

  Future<int> deleteUserComponentState(int stateId) =>
      _delete('estado_componente_usuario', 'estado_id = ?', [stateId]);

  Future<int> createUiEvent(UiEvent event) => _insert('evento_ui', event.toMap());

  Future<List<UiEvent>> listUiEventsByUser(int userId, {int limit = 100}) async {
    final rows = await _query(
      'evento_ui',
      where: 'usuario_id = ?',
      whereArgs: [userId],
      orderBy: 'creado_at DESC',
      limit: limit,
    );
    return rows.map(UiEvent.fromMap).toList();
  }

  Future<int> deleteUiEvent(int eventId) =>
      _delete('evento_ui', 'evento_id = ?', [eventId]);
}
