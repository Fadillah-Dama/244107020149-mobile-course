import '../../domain/entities/auth_session.dart';

class AuthSessionModel {
  const AuthSessionModel(this.access, this.refresh);
  final String access;
  final String refresh;

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    final access = json['access_token'];
    final refresh = json['refresh_token'];
    if (access is! String ||
        access.isEmpty ||
        refresh is! String ||
        refresh.isEmpty) {
      throw const FormatException('Respons token tidak valid');
    }
    return AuthSessionModel(access, refresh);
  }

  AuthSession toEntity() => AuthSession(access: access, refresh: refresh);
}
