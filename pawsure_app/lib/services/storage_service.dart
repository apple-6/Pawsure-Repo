//pawsure_app\lib\services\storage_service.dart
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
  Future<void> deleteToken() async {
    await delete(key: 'auth_token');
  }
}

/// File-based storage implementation for desktop and mobile platforms
class FileStorageService implements StorageService {
  static const String _fileName = 'secure_storage.json';

  // ✅ Singleton instance
  static FileStorageService? _instance;

  // ✅ In-memory cache to avoid constant file reads
  Map<String, String>? _cache;
  bool _isInitialized = false;
  File? _file;

  // ✅ Private constructor for singleton
  FileStorageService._internal();

  // ✅ Factory constructor returns singleton
  factory FileStorageService() {
    _instance ??= FileStorageService._internal();
    return _instance!;
  }

  /// ✅ Initialize storage once
  Future<void> _ensureInitialized() async {
    if (_isInitialized && _cache != null) {
      return; // Already initialized
    }

    try {
      _file = await _getFile();
      _cache = await _loadFromFile();
      _isInitialized = true;

      debugPrint('✅ FileStorageService initialized');
      debugPrint(
        '📋 Loaded ${_cache!.length} keys: ${_cache!.keys.join(", ")}',
      );

      if (_cache!.containsKey('jwt')) {
        debugPrint('🔑 JWT token found in storage');
      }
    } catch (e) {
      debugPrint('❌ Storage initialization error: $e');
      _cache = {};
      _isInitialized = true;
    }
  }

  Future<File> _getFile() async {
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}/$_fileName');
  }

  /// ✅ Load from file WITHOUT clearing existing cache
  Future<Map<String, String>> _loadFromFile() async {
    try {
      final file = _file ?? await _getFile();

      if (!await file.exists()) {
        debugPrint(
          '📄 Storage file does not exist, will create on first write',
        );
        return {};
      }

      final content = await file.readAsString();

      if (content.trim().isEmpty) {
        debugPrint('📄 Storage file is empty');
        return {};
      }

      try {
        final decoded = json.decode(content);
        if (decoded is Map) {
          return Map<String, String>.from(
            decoded.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            ),
          );
        } else {
          debugPrint('⚠️ Invalid storage format, resetting');
          return {};
        }
      } on FormatException catch (e) {
        debugPrint('⚠️ Corrupted JSON in storage file, resetting: $e');
        return {};
      }
    } catch (e) {
      debugPrint('❌ Error reading storage file: $e');
      return {};
    }
  }

  /// ✅ Save cache to file
  Future<void> _saveToFile() async {
    if (_cache == null) return;

    try {
      final file = _file ?? await _getFile();
      final directory = file.parent;

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final jsonString = json.encode(_cache);
      await file.writeAsString(jsonString);
      debugPrint('💾 Storage saved (${_cache!.length} keys)');
    } catch (e) {
      debugPrint('❌ Failed to save storage: $e');
      rethrow;
    }
  }

  @override
  Future<void> write({required String key, required String value}) async {
    await _ensureInitialized();

    _cache![key] = value;
    await _saveToFile();
    debugPrint('✅ Stored key: $key');
  }

  @override
  Future<String?> read({required String key}) async {
    await _ensureInitialized();

    final value = _cache![key];

    if (value != null) {
      debugPrint('✅ Read key: $key');
    } else {
      debugPrint('! Key not found: $key');
      debugPrint('📋 Available keys: ${_cache!.keys.join(", ")}');
    }

    return value;
  }

  @override
  Future<void> delete({required String key}) async {
    await _ensureInitialized();

    final existed = _cache!.remove(key) != null;
    await _saveToFile();

    if (existed) {
      debugPrint('✅ Deleted key: $key');
    } else {
      debugPrint('⚠️ Key not found for deletion: $key');
    }
  }

  @override
  Future<void> clear() async {
    await _ensureInitialized();

    debugPrint('🗑️ Clearing all storage (${_cache!.length} keys)');
    _cache!.clear();
    await _saveToFile();
  }

  @override
  Future<void> deleteToken() async {
    await delete(key: 'auth_token');
  }

  /// Debug helper: Print all stored keys (without values for security)
  Future<void> debugPrintKeys() async {
    await _ensureInitialized();
    debugPrint('📋 Stored keys: ${_cache!.keys.join(", ")}');
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

  /// Force reload from file (useful for debugging)
  Future<void> reload() async {
    _cache = await _loadFromFile();
    debugPrint('🔄 Storage reloaded (${_cache!.length} keys)');
  }
}
