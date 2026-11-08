/// Logout memakai client terautentikasi; login/refresh memakai client publik.
abstract class SessionRevoker {
  Future<void> logout();
}
