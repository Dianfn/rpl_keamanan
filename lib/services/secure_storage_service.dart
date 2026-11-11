import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/logger.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  // Key yang digunakan
  static const String _tokenKey = 'auth_token';
  static const String _pinKey = 'user_pin';
  // Menyimpan token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    // ✅ Logging aman: tidak mencetak token
    Logger.info('Token berhasil disimpan');
  }

  // Membaca token
  Future<String?> getToken() async {
    final token = await _storage.read(key: _tokenKey);
    // ✅ Logging aman: hanya menyebutkan status
    Logger.info(token != null ? 'Token ditemukan' : 'Token tidak ditemukan');
    return token;
  }

  // Menghapus token
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
    Logger.info('Token berhasil dihapus');
  }

  // Menyimpan PIN
  Future<void> savePin(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
    Logger.info('PIN berhasil disimpan');
  }

  // Membaca PIN
  Future<String?> getPin() async {
    return await _storage.read(key: _pinKey);
  }

  // Menghapus semua data
  Future<void> deleteAll() async {
    await _storage.deleteAll();
    Logger.info('Semua data berhasil dihapus');
  }

  // Cek keberadaan token
  Future<bool> hasToken() async {
    return await _storage.containsKey(key: _tokenKey);
  }
}
