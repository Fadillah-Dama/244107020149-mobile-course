import '../../../../core/failures.dart';
import '../repositories/auth_repository.dart';
import '../repositories/session_store.dart';

/// Login baru berhasil setelah kedua token tersimpan.
class Login {
  const Login(this._repository, this._store);
  final AuthRepository _repository;
  final SessionStore _store;

  Future<void> call(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      throw const ValidationFailure('Email dan kata sandi wajib diisi.');
    }
    final session = await _repository.login(
      email: email.trim(),
      password: password,
    );
    try {
      await _store.save(access: session.access, refresh: session.refresh);
    } catch (_) {
      await _store.clear();
      rethrow;
    }
  }
}
