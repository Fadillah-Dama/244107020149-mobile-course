import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/repositories/session_store.dart';

import 'package:campus_notify/shared/data/network/guard_request.dart';

class TokenStore implements SessionStore {
  TokenStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  @override
  Future<void> save({required String access, required String refresh}) =>
      guardRequest(() async {
        await _storage.write(key: _accessKey, value: access);
        await _storage.write(key: _refreshKey, value: refresh);
      });

  @override
  Future<String?> readAccess() =>
      guardRequest(() => _storage.read(key: _accessKey));
  @override
  Future<String?> readRefresh() =>
      guardRequest(() => _storage.read(key: _refreshKey));

  @override
  Future<void> clear() => guardRequest(() => _storage.deleteAll());
}
