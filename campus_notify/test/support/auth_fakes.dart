import 'dart:async';
import 'dart:typed_data';

import 'package:campus_notify/core/failures.dart';
import 'package:campus_notify/core/ports/device_session.dart';
import 'package:campus_notify/core/ports/notification_badges.dart';
import 'package:campus_notify/features/auth/domain/entities/auth_session.dart';
import 'package:campus_notify/features/auth/domain/repositories/auth_repository.dart';
import 'package:campus_notify/features/announcements/domain/entities/inbox_notification.dart';
import 'package:campus_notify/features/announcements/domain/repositories/notification_repository.dart';
import 'package:dio/dio.dart';

class TestDeviceSyncService implements DeviceSession {
  @override
  Future<void> start() async {}
  @override
  Future<void> stop() async {}
  @override
  Future<bool> unregister() async => true;
}

class TestBadges implements NotificationBadges {
  @override
  Future<void> sync(Set<String> unreadIds, {bool clearAll = false}) async {}
}

class TestNotificationRepository implements NotificationRepository {
  List<InboxNotification> items = [];
  Failure? failure;
  final readIds = <String>[];
  @override
  Future<List<InboxNotification>> fetchUnread() async {
    if (failure != null) throw failure!;
    return List.of(items);
  }

  @override
  Future<InboxNotification> fetch(String id) async {
    if (failure != null) throw failure!;
    for (final item in items) {
      if (item.id == id) return item;
    }
    throw const DataFailure('Notifikasi tidak ditemukan');
  }

  @override
  Future<void> markAsRead(String id) async {
    if (failure != null) throw failure!;
    readIds.add(id);
    items.removeWhere((item) => item.id == id);
  }
}

class TestAuthRepository implements AuthRepository {
  int refreshCalls = 0;
  bool failRefresh = false;
  Failure? refreshError;
  Completer<void>? refreshGate;
  Completer<void>? refreshStarted;
  Future<void> Function()? logoutAction;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    if (email != 'mahasiswa@kampus.ac.id' || password != '123456') {
      throw const AuthenticationFailure();
    }
    return const AuthSession(access: 'login-access', refresh: 'login-refresh');
  }

  @override
  Future<AuthSession> refresh(String refreshToken) async {
    refreshCalls++;
    if (!(refreshStarted?.isCompleted ?? true)) refreshStarted!.complete();
    await refreshGate?.future;
    if (refreshError != null) throw refreshError!;
    if (failRefresh) throw const AuthenticationFailure();
    return const AuthSession(
      access: 'renewed-access',
      refresh: 'renewed-refresh',
    );
  }
}

class RecordingAdapter implements HttpClientAdapter {
  RecordingAdapter(this.respond);
  final FutureOr<ResponseBody> Function(RequestOptions options) respond;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    // Salin header agar nilai setiap percobaan tetap tercatat setelah retry.
    requests.add(
      options.copyWith(headers: Map<String, dynamic>.from(options.headers)),
    );
    return await respond(options);
  }

  @override
  void close({bool force = false}) {}
}
