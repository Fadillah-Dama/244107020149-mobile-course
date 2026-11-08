import '../../features/auth/domain/repositories/session_revoker.dart';
import '../../features/auth/data/repositories/api_session_revoker.dart';

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ports/device_session.dart';
import '../../core/session_expiration.dart';
import '../../core/ports/notification_badges.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/repositories/session_store.dart';
import '../../features/auth/domain/usecases/login.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/auth/domain/usecases/end_session.dart';
import '../../features/auth/data/datasources/secure_token_store.dart';
import '../../features/auth/data/repositories/laravel_auth_repository.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/announcements/domain/repositories/notification_repository.dart';
import '../../features/announcements/domain/repositories/device_repository.dart';
import '../../features/announcements/domain/repositories/push_preferences.dart';
import '../../features/announcements/domain/usecases/open_notification.dart';
import '../../features/announcements/data/repositories/api_notification_repository.dart';
import '../../features/announcements/data/repositories/api_device_repository.dart';
import '../../features/announcements/data/services/device_sync_service.dart';
import '../../features/announcements/data/services/platform_badge_service.dart';
import '../../features/announcements/data/services/firebase_push_preferences.dart';
import '../../shared/data/network/api_client.dart';

/// Composition root: satu-satunya tempat yang memilih implementasi konkret.
final tokenStoreProvider = Provider<SessionStore>((ref) => TokenStore());
final sessionExpirationProvider = Provider<SessionExpiration>(
  (ref) => SessionExpiration(),
);

final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>((ref) {
      final repository = LaravelAuthRepository();
      ref.onDispose(repository.close);
      return repository;
    });

final Provider<Dio> apiClientProvider = Provider<Dio>((ref) {
  final dio = buildApiClient(
    ref.watch(tokenStoreProvider),
    ref.watch(authRepositoryProvider),
    onSessionExpired: ref.watch(sessionExpirationProvider).expire,
  );
  ref.onDispose(() => dio.close(force: true));
  return dio;
});

final deviceRepositoryProvider = Provider<DeviceRepository>(
  (ref) => ApiDeviceRepository(ref.watch(apiClientProvider)),
);

final deviceSyncProvider = Provider<DeviceSession>((ref) {
  final service = DeviceSyncService(ref.watch(deviceRepositoryProvider));
  ref.onDispose(() => unawaited(service.stop()));
  return service;
});

final badgeServiceProvider = Provider<NotificationBadges>(
  (ref) => BadgeService(),
);
final pushPreferencesProvider = Provider<PushPreferences>(
  (ref) => FirebasePushPreferences(),
);
final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => ApiNotificationRepository(ref.watch(apiClientProvider)),
);

final loginProvider = Provider<Login>(
  (ref) =>
      Login(ref.watch(authRepositoryProvider), ref.watch(tokenStoreProvider)),
);
final endSessionProvider = Provider<EndSession>(
  (ref) => EndSession(
    ref.watch(tokenStoreProvider),
    ref.watch(deviceSyncProvider),
    ref.watch(badgeServiceProvider),
  ),
);
final sessionRevokerProvider = Provider<SessionRevoker>(
  (ref) => ApiSessionRevoker(ref.watch(apiClientProvider)),
);
final logoutProvider = Provider<Logout>(
  (ref) => Logout(
    ref.watch(sessionRevokerProvider),
    ref.watch(deviceSyncProvider),
    ref.watch(endSessionProvider),
  ),
);
final openNotificationProvider = Provider<OpenNotification>(
  (ref) => OpenNotification(ref.watch(notificationRepositoryProvider)),
);

final authStateProvider = AsyncNotifierProvider<AuthNotifier, bool>(
  () => AuthNotifier(
    (ref) => AuthDependencies(
      ref.watch(loginProvider),
      ref.watch(logoutProvider),
      ref.watch(endSessionProvider),
      ref.watch(tokenStoreProvider),
      ref.watch(deviceSyncProvider),
      ref.watch(sessionExpirationProvider),
    ),
  ),
);
