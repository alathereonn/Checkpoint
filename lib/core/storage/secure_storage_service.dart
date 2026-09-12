import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  const SecureStorageService();
  static const _s = FlutterSecureStorage();
  Future<String?> get token => _s.read(key: 'jwt');
  Future<void> saveToken(String v) => _s.write(key: 'jwt', value: v);
  Future<void> clear() => _s.deleteAll();
}
