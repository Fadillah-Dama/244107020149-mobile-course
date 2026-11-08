import '../entities/auth_session.dart';

/// Implementasi menerjemahkan kegagalan eksternal menjadi Failure.
abstract class AuthRepository {
  Future<AuthSession> login({required String email, required String password});
  Future<AuthSession> refresh(String refreshToken);
}
