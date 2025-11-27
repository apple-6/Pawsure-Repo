import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:developer' as developer;

/// Abstract storage service interface
abstract class StorageService {
  Future<void> write({required String key, required String value});
  Future<String?> read({required String key});
  Future<void> delete({required String key});
}

/// File-based storage implementation for desktop and mobile platforms
class FileStorageService implements StorageService {
  Future<File> _getFile() async {
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}/secure_storage.json');
  }

  Future<Map<String, String>> _readMap() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        return Map<String, String>.from(json.decode(content));
      }
    } catch (e, st) {
      developer.log(
        'Error reading storage file: $e',
        name: 'FileStorageService',
        error: e,
        stackTrace: st,
      );
    }
    return {};
  }

  Future<void> _writeMap(Map<String, String> data) async {
    try {
      final file = await _getFile();
      await file.writeAsString(json.encode(data));
    } catch (e, st) {
      developer.log(
        'Error writing storage file: $e',
        name: 'FileStorageService',
        error: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> write({required String key, required String value}) async {
    final map = await _readMap();
    map[key] = value;
    await _writeMap(map);
  }

  @override
  Future<String?> read({required String key}) async {
    final map = await _readMap();
    return map[key];
  }

  @override
  Future<void> delete({required String key}) async {
    final map = await _readMap();
    map.remove(key);
    await _writeMap(map);
  }
}
