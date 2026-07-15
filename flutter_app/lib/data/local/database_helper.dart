import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'database_config.dart';
import 'database_runtime_config.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _database;

  Future<void> init() async {
    await database;
  }

  Future<Database> get database async {
    final existing = _database;
    if (existing != null) {
      return existing;
    }

    DatabaseRuntimeConfig.configure();
    final created = await _open();
    _database = created;
    return created;
  }

  Future<Database> _open() async {
    final dbRootPath = await getDatabasesPath();
    final dbPath = p.join(dbRootPath, DatabaseConfig.dbName);

    return openDatabase(
      dbPath,
      version: DatabaseConfig.dbVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    await _createIndexes(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Database starts at version 1. Future migrations will go here.
    if (oldVersion >= newVersion) {
      return;
    }
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE usuario (
        usuario_id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE COLLATE NOCASE,
        display_name TEXT,
        email TEXT UNIQUE,
        estado TEXT NOT NULL CHECK (estado IN ('activo', 'inactivo', 'bloqueado')),
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        last_login_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE credencial (
        usuario_id INTEGER PRIMARY KEY,
        password_hash TEXT NOT NULL,
        hash_algo TEXT NOT NULL,
        password_updated_at TEXT NOT NULL,
        failed_attempts INTEGER NOT NULL DEFAULT 0 CHECK (failed_attempts >= 0),
        blocked_until TEXT,
        FOREIGN KEY (usuario_id) REFERENCES usuario(usuario_id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE termino_version (
        termino_id INTEGER PRIMARY KEY AUTOINCREMENT,
        version TEXT NOT NULL UNIQUE,
        contenido_checksum TEXT NOT NULL UNIQUE,
        publicado_at TEXT NOT NULL,
        activo INTEGER NOT NULL DEFAULT 1 CHECK (activo IN (0, 1))
      )
    ''');

    await db.execute('''
      CREATE TABLE usuario_termino_aceptacion (
        aceptacion_id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER NOT NULL,
        termino_id INTEGER NOT NULL,
        aceptado INTEGER NOT NULL DEFAULT 1 CHECK (aceptado IN (0, 1)),
        aceptado_at TEXT NOT NULL,
        ip_origen TEXT,
        user_agent TEXT,
        UNIQUE (usuario_id, termino_id),
        FOREIGN KEY (usuario_id) REFERENCES usuario(usuario_id) ON DELETE CASCADE,
        FOREIGN KEY (termino_id) REFERENCES termino_version(termino_id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE sesion (
        sesion_id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER NOT NULL,
        token_publico TEXT NOT NULL UNIQUE,
        iniciado_at TEXT NOT NULL,
        cerrado_at TEXT,
        estado TEXT NOT NULL CHECK (estado IN ('abierta', 'cerrada', 'expirada')),
        motivo_cierre TEXT,
        dispositivo TEXT,
        app_version TEXT,
        FOREIGN KEY (usuario_id) REFERENCES usuario(usuario_id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE catalogo_componente (
        componente_id INTEGER PRIMARY KEY AUTOINCREMENT,
        codigo TEXT NOT NULL UNIQUE,
        tipo_control TEXT NOT NULL,
        descripcion TEXT,
        activo INTEGER NOT NULL DEFAULT 1 CHECK (activo IN (0, 1))
      )
    ''');

    await db.execute('''
      CREATE TABLE estado_componente_usuario (
        estado_id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER NOT NULL,
        componente_id INTEGER NOT NULL,
        valor_bool INTEGER CHECK (valor_bool IN (0, 1)),
        valor_num REAL,
        valor_texto TEXT,
        valor_json TEXT,
        actualizado_at TEXT NOT NULL,
        UNIQUE (usuario_id, componente_id),
        FOREIGN KEY (usuario_id) REFERENCES usuario(usuario_id) ON DELETE CASCADE,
        FOREIGN KEY (componente_id) REFERENCES catalogo_componente(componente_id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE evento_ui (
        evento_id INTEGER PRIMARY KEY AUTOINCREMENT,
        sesion_id INTEGER,
        usuario_id INTEGER,
        componente_id INTEGER,
        pantalla TEXT NOT NULL,
        accion TEXT NOT NULL,
        payload_json TEXT,
        creado_at TEXT NOT NULL,
        FOREIGN KEY (sesion_id) REFERENCES sesion(sesion_id) ON DELETE SET NULL,
        FOREIGN KEY (usuario_id) REFERENCES usuario(usuario_id) ON DELETE SET NULL,
        FOREIGN KEY (componente_id) REFERENCES catalogo_componente(componente_id) ON DELETE SET NULL
      )
    ''');
  }

  Future<void> _createIndexes(Database db) async {
    await db.execute(
      'CREATE INDEX idx_sesion_usuario_estado_inicio ON sesion(usuario_id, estado, iniciado_at DESC)',
    );
    await db.execute(
      "CREATE INDEX idx_sesion_abierta_usuario ON sesion(usuario_id) WHERE estado = 'abierta'",
    );
    await db.execute(
      'CREATE INDEX idx_uta_usuario_fecha ON usuario_termino_aceptacion(usuario_id, aceptado_at DESC)',
    );
    await db.execute(
      'CREATE INDEX idx_evento_sesion_fecha ON evento_ui(sesion_id, creado_at DESC)',
    );
    await db.execute(
      'CREATE INDEX idx_evento_usuario_fecha ON evento_ui(usuario_id, creado_at DESC)',
    );
    await db.execute(
      'CREATE INDEX idx_evento_pantalla_accion_fecha ON evento_ui(pantalla, accion, creado_at DESC)',
    );
  }

  Future<T> inTransaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return db.transaction(action);
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  Future<void> resetForTests() async {
    await close();

    final dbRootPath = await getDatabasesPath();
    final dbPath = p.join(dbRootPath, DatabaseConfig.dbName);
    await deleteDatabase(dbPath);
  }
}

