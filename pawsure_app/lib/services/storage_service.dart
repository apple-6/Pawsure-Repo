//Pawsure-Repo\pawsure_app\lib\services\storage_service.dart

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Abstract storage service interface
abstract class StorageService {
  Future<void> write({required String key, required String value});
  Future<String?> read({required String key});
  Future<void> delete({required String key});
  Future<void> clear();

  // Helper method for auth token
  Future<void> deleteToken() async {
    await delete(key: 'auth_token');
  }
}

/// File-based storage implementation for desktop and mobile platforms
class FileStorageService implements StorageService {
  static const String _fileName = 'secure_storage.json';

  Future<File> _getFile() async {
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}/$_fileName');
  }

  /// 🔧 FIX: Robust file reading with empty/corrupted file handling
  Future<Map<String, String>> _readMap() async {
    try {
      final file = await _getFile();

      // Check if file exists
      if (!await file.exists()) {
        debugPrint('📄 Storage file does not exist, creating new one');
        await _writeMap({});
        return {};
      }

      // Read file content
      final content = await file.readAsString();

      // 🔧 FIX: Handle empty file
      if (content.trim().isEmpty) {
        debugPrint('📄 Storage file is empty, initializing with empty map');
        await _writeMap({});
        return {};
      }

      // Try to decode JSON
      try {
        final decoded = json.decode(content);

        // Ensure it's a Map<String, String>
        if (decoded is Map) {
          return Map<String, String>.from(
            decoded.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            ),
          );
        } else {
          debugPrint('⚠️ Invalid storage format, resetting');
          await _writeMap({});
          return {};
        }
      } on FormatException catch (e) {
        debugPrint('⚠️ Corrupted JSON in storage file, resetting: $e');
        // Reset corrupted file
        await _writeMap({});
        return {};
      }
    } catch (e, st) {
      debugPrint('❌ Error reading storage file: $e');
      debugPrint('Stack trace: $st');

      // Try to create a fresh file
      try {
        await _writeMap({});
      } catch (_) {
        // If we can't even create a file, return empty map
      }
      return {};
    }
  }

  /// 🔧 FIX: Safe write operation with error handling
  Future<void> _writeMap(Map<String, String> data) async {
    try {
      final file = await _getFile();

      // Ensure directory exists
      final directory = file.parent;
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Write JSON data
      final jsonString = json.encode(data);
      await file.writeAsString(jsonString);

      debugPrint('✅ Storage written successfully (${data.length} keys)');
    } catch (e, st) {
      debugPrint('❌ Error writing storage file: $e');
      debugPrint('Stack trace: $st');
      rethrow; // Let caller handle the error
    }
  }

  @override
  Future<void> write({required String key, required String value}) async {
    try {
      final map = await _readMap();
      map[key] = value;
      await _writeMap(map);
      debugPrint('✅ Stored key: $key');
    } catch (e) {
      debugPrint('❌ Error writing key "$key": $e');
      rethrow;
    }
  }

  @override
  Future<String?> read({required String key}) async {
    try {
      final map = await _readMap();
      final value = map[key];

      if (value != null) {
        debugPrint('✅ Read key: $key');
      } else {
        debugPrint('⚠️ Key not found: $key');
      }

      return value;
    } catch (e) {
      debugPrint('❌ Error reading key "$key": $e');
      return null;
    }
  }

  @override
  Future<void> delete({required String key}) async {
    try {
      final map = await _readMap();
      final existed = map.remove(key) != null;
      await _writeMap(map);

      if (existed) {
        debugPrint('✅ Deleted key: $key');
      } else {
        debugPrint('⚠️ Key not found for deletion: $key');
      }
    } catch (e) {
      debugPrint('❌ Error deleting key "$key": $e');
      rethrow;
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _writeMap({});
      debugPrint('✅ Storage cleared');
    } catch (e) {
      debugPrint('❌ Error clearing storage: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteToken() async {
    await delete(key: 'auth_token');
  }

  /// Debug helper: Print all stored keys (without values for security)
  Future<void> debugPrintKeys() async {
    try {
      final map = await _readMap();
      debugPrint('📋 Stored keys: ${map.keys.join(", ")}');
    } catch (e) {
      debugPrint('❌ Error printing keys: $e');
    }
  }

  /// Debug helper: Check if storage file exists and its size
  Future<void> debugFileInfo() async {
    try {
      final file = await _getFile();
      final exists = await file.exists();

      if (exists) {
        final size = await file.length();
        debugPrint('📄 Storage file: ${file.path}');
        debugPrint('📊 File size: $size bytes');
      } else {
        debugPrint('📄 Storage file does not exist: ${file.path}');
      }
    } catch (e) {
      debugPrint('❌ Error getting file info: $e');
    }
  }
}
