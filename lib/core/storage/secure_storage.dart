import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const _keyEncryptionKey = 'hiveExtensionKey';

  /// Retrieves the encryption key for Hive or generates a new one if it doesn't exist.
  static Future<Uint8List> getHiveEncryptionKey() async {
    final keyString = await _storage.read(key: _keyEncryptionKey);
    if (keyString == null) {
      final key = Hive.generateSecureKey();
      await _storage.write(
        key: _keyEncryptionKey,
        value: base64UrlEncode(key),
      );
      return Uint8List.fromList(key);
    } else {
      return base64Url.decode(keyString);
    }
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
