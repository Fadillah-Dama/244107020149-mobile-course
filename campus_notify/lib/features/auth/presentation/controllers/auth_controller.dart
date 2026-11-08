import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ports/device_session.dart';
import '../../../../core/session_expiration.dart';
import '../../domain/repositories/session_store.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/end_session.dart';

class AuthDependencies {
  const AuthDependencies(
    this.login,
    this.logout,
    this.endSession,
    this.store,
    this.devices,
    this.expiration,
  );
  final Login login;
  final Logout logout;
  final EndSession endSession;
  final SessionStore store;
  final DeviceSession devices;
  final SessionExpiration expiration;
}

class AuthNotifier extends AsyncNotifier<bool> {
  AuthNotifier(this._resolve);
  final AuthDependencies Function(Ref ref) _resolve;
  late AuthDependencies _dependencies;

  @override
  Future<bool> build() async {
    _dependencies = _resolve(ref);
    final devices = _dependencies.devices;
    final expiration = _dependencies.expiration;
    final onExpired = clearSession;
    expiration.listen(onExpired);
    ref.onDispose(() => expiration.removeListener(onExpired));
    ref.onDispose(() => unawaited(devices.stop()));
    final token = await _dependencies.store.readAccess();
    final loggedIn = token != null && token.isNotEmpty;
    if (loggedIn) unawaited(_dependencies.devices.start());
    return loggedIn;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _dependencies.login(email, password);
      return true;
    });
    if (state.asData?.value == true) unawaited(_dependencies.devices.start());
  }

  Future<void> clearSession() async {
    await _dependencies.endSession();
    state = const AsyncData(false);
  }

  Future<bool> logout() async {
    final confirmed = await _dependencies.logout();
    state = const AsyncData(false);
    return confirmed;
  }
}
