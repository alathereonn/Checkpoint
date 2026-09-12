import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/storage/secure_storage_service.dart';

final storageProvider = Provider((_) => const SecureStorageService());
final apiProvider = Provider((r) => ApiClient(r.read(storageProvider)));

class AuthState {
  const AuthState({
    this.loading = true,
    this.authenticated = false,
    this.error,
  });
  final bool loading, authenticated;
  final String? error;
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    Future.microtask(restore);
    return const AuthState();
  }

  Future<void> restore() async {
    try {
      if (await ref.read(storageProvider).token == null) {
        state = const AuthState(loading: false);
        return;
      }
      await ref.read(apiProvider).get('/api/auth/me');
      state = const AuthState(loading: false, authenticated: true);
    } catch (_) {
      await ref.read(storageProvider).clear();
      state = const AuthState(loading: false);
    }
  }

  Future<void> login(String l, String p) async {
    state = const AuthState();
    try {
      final d = await ref
          .read(apiProvider)
          .post('/api/auth/login', data: {'login': l, 'password': p});
      await ref.read(storageProvider).saveToken(d['token']);
      state = const AuthState(loading: false, authenticated: true);
    } catch (e) {
      state = AuthState(loading: false, error: e.toString());
    }
  }

  Future<void> register(String u, String e, String p) async {
    state = const AuthState();
    try {
      final d = await ref
          .read(apiProvider)
          .post(
            '/api/auth/register',
            data: {'username': u, 'email': e, 'password': p},
          );
      await ref.read(storageProvider).saveToken(d['token']);
      state = const AuthState(loading: false, authenticated: true);
    } catch (e) {
      state = AuthState(loading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    try {
      await ref.read(apiProvider).post('/api/auth/logout');
    } catch (_) {}
    await ref.read(storageProvider).clear();
    state = const AuthState(loading: false);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
