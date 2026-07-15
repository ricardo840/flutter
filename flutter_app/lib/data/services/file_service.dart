import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'dart:html' if (dart.library.html) 'dart:html' as html;
import '../../services/notification_service.dart';

class FileService {
  static final FileService _instance = FileService._internal();
  factory FileService() => _instance;
  FileService._internal();

  bool get isWeb => kIsWeb;

  // ─── WEB: localStorage ────────────────────────────────────
  Future<bool> _createFileWeb(String fileName, String content) async {
    try {
      // Ahora 'html' está disponible solo en web
      html.window.localStorage[fileName] = content;
      print('✅ Archivo creado en localStorage: $fileName');
      final notifications = NotificationService();
      await notifications.showNotification(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        title: 'Archivo creado (Web)',
        body: 'Se creó "$fileName" en localStorage',
      );
      return true;
    } catch (e) {
      print('❌ Error al crear en localStorage: $e');
      return false;
    }
  }

  Future<String?> _readFileWeb(String fileName) async {
    try {
      final content = html.window.localStorage[fileName];
      if (content == null) {
        print('⚠️ Archivo no existe en localStorage: $fileName');
        return null;
      }
      print('📖 Archivo leído de localStorage: $fileName');
      return content;
    } catch (e) {
      print('❌ Error al leer de localStorage: $e');
      return null;
    }
  }

  Future<bool> _updateFileWeb(String fileName, String content) async {
    try {
      if (!html.window.localStorage.containsKey(fileName)) {
        print('⚠️ Archivo no existe para actualizar: $fileName');
        return false;
      }
      html.window.localStorage[fileName] = content;
      print('✅ Archivo actualizado en localStorage: $fileName');
      return true;
    } catch (e) {
      print('❌ Error al actualizar en localStorage: $e');
      return false;
    }
  }

  Future<bool> _deleteFileWeb(String fileName) async {
    try {
      if (!html.window.localStorage.containsKey(fileName)) {
        print('⚠️ Archivo no existe para eliminar: $fileName');
        return false;
      }
      html.window.localStorage.remove(fileName);
      print('🗑️ Archivo eliminado de localStorage: $fileName');
      final notifications = NotificationService();
      await notifications.showNotification(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        title: 'Archivo eliminado (Web)',
        body: 'Se eliminó "$fileName" de localStorage',
      );
      return true;
    } catch (e) {
      print('❌ Error al eliminar de localStorage: $e');
      return false;
    }
  }

  Future<List<String>> _listFilesWeb() async {
    try {
      final keys = html.window.localStorage.keys;
      final names = keys.where((key) => key.isNotEmpty).toList();
      print('📂 Archivos en localStorage: $names');
      return names;
    } catch (e) {
      print('❌ Error al listar localStorage: $e');
      return [];
    }
  }

  // ─── NATIVO ────────────────────────────────────────────────
  Future<Directory> _getDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    print('📁 Directorio de documentos: ${dir.path}');
    return dir;
  }

  Future<String> _getFilePath(String fileName) async {
    final dir = await _getDirectory();
    return '${dir.path}/$fileName';
  }

  Future<bool> _createFileNative(String fileName, String content) async {
    try {
      final path = await _getFilePath(fileName);
      final file = File(path);
      await file.writeAsString(content);
      print('✅ Archivo creado: $path');
      final notifications = NotificationService();
      await notifications.showNotification(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        title: 'Archivo creado',
        body: 'Se creó "$fileName" en el dispositivo',
      );
      return true;
    } catch (e) {
      print('❌ Error al crear archivo nativo: $e');
      return false;
    }
  }

  Future<String?> _readFileNative(String fileName) async {
    try {
      final path = await _getFilePath(fileName);
      final file = File(path);
      if (!await file.exists()) {
        print('⚠️ Archivo no existe: $path');
        return null;
      }
      final content = await file.readAsString();
      print('📖 Archivo leído: $path');
      return content;
    } catch (e) {
      print('❌ Error al leer archivo nativo: $e');
      return null;
    }
  }

  Future<bool> _updateFileNative(String fileName, String content) async {
    try {
      final path = await _getFilePath(fileName);
      final file = File(path);
      if (!await file.exists()) {
        print('⚠️ Archivo no existe para actualizar: $path');
        return false;
      }
      await file.writeAsString(content);
      print('✅ Archivo actualizado: $path');
      return true;
    } catch (e) {
      print('❌ Error al actualizar archivo nativo: $e');
      return false;
    }
  }

  Future<bool> _deleteFileNative(String fileName) async {
    try {
      final path = await _getFilePath(fileName);
      final file = File(path);
      if (!await file.exists()) {
        print('⚠️ Archivo no existe para eliminar: $path');
        return false;
      }
      await file.delete();
      print('🗑️ Archivo eliminado: $path');
      final notifications = NotificationService();
      await notifications.showNotification(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        title: 'Archivo eliminado',
        body: 'Se eliminó "$fileName" del dispositivo',
      );
      return true;
    } catch (e) {
      print('❌ Error al eliminar archivo nativo: $e');
      return false;
    }
  }

  Future<List<String>> _listFilesNative() async {
    try {
      final dir = await _getDirectory();
      final files = await dir.list().toList();
      final names = files
          .whereType<File>()
          .map((f) => f.path.split('/').last)
          .toList();
      print('📂 Archivos nativos: $names');
      return names;
    } catch (e) {
      print('❌ Error al listar archivos nativos: $e');
      return [];
    }
  }

  // ─── MÉTODOS PÚBLICOS ─────────────────────────────────────
  Future<bool> createFile(String fileName, String content) async {
    if (isWeb) {
      return await _createFileWeb(fileName, content);
    } else {
      return await _createFileNative(fileName, content);
    }
  }

  Future<String?> readFile(String fileName) async {
    if (isWeb) {
      return await _readFileWeb(fileName);
    } else {
      return await _readFileNative(fileName);
    }
  }

  Future<bool> updateFile(String fileName, String content) async {
    if (isWeb) {
      return await _updateFileWeb(fileName, content);
    } else {
      return await _updateFileNative(fileName, content);
    }
  }

  Future<bool> deleteFile(String fileName) async {
    if (isWeb) {
      return await _deleteFileWeb(fileName);
    } else {
      return await _deleteFileNative(fileName);
    }
  }

  Future<List<String>> listFiles() async {
    if (isWeb) {
      return await _listFilesWeb();
    } else {
      return await _listFilesNative();
    }
  }
}