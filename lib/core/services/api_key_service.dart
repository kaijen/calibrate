import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiKeyService {
  static const _storage = FlutterSecureStorage();
  static const _keyName = 'openrouter_api_key';
  static const _modelKey = 'openrouter_model';

  static Future<String?> getKey() => _storage.read(key: _keyName);
  static Future<void> saveKey(String v) => _storage.write(key: _keyName, value: v);
  static Future<void> deleteKey() => _storage.delete(key: _keyName);
  static Future<String?> getModel() => _storage.read(key: _modelKey);
  static Future<void> saveModel(String v) => _storage.write(key: _modelKey, value: v);
}
