import 'package:campus_notify/features/auth/domain/repositories/session_revoker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/core/failures.dart';
import 'package:campus_notify/core/ports/device_session.dart';
import 'package:campus_notify/core/ports/notification_badges.dart';
import 'package:campus_notify/features/auth/domain/entities/auth_session.dart';
import 'package:campus_notify/features/auth/domain/repositories/auth_repository.dart';
import 'package:campus_notify/features/auth/domain/repositories/session_store.dart';
import 'package:campus_notify/features/auth/domain/usecases/login.dart';
import 'package:campus_notify/features/auth/domain/usecases/logout.dart';
import 'package:campus_notify/features/auth/domain/usecases/end_session.dart';
import 'package:campus_notify/features/announcements/domain/entities/inbox_notification.dart';
import 'package:campus_notify/features/announcements/domain/repositories/notification_repository.dart';
import 'package:campus_notify/features/announcements/domain/usecases/open_notification.dart';

class MemoryStore implements SessionStore {
  String? access;
  String? refresh;
  bool failSaving = false;
  @override
  Future<void> save({required String access, required String refresh}) async {
    this.access = access;
    if (failSaving) throw const UnexpectedFailure('Penyimpanan gagal');
    this.refresh = refresh;
  }

  @override
  Future<String?> readAccess() async => access;
  @override
  Future<String?> readRefresh() async => refresh;
  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
  }
}

class FakeAuth implements AuthRepository, SessionRevoker {
  Failure? failure;
  String? receivedEmail;
  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    receivedEmail = email;
    if (failure != null) throw failure!;
    return const AuthSession(access: 'access', refresh: 'refresh');
  }

  @override
  Future<AuthSession> refresh(String refreshToken) async {
    if (failure != null) throw failure!;
    return const AuthSession(access: 'new-access', refresh: 'new-refresh');
  }

  @override
  Future<void> logout() async {
    if (failure != null) throw failure!;
  }
}

class FakeDevice implements DeviceSession {
  bool stopped = false;
  @override
  Future<void> start() async {}
  @override
  Future<void> stop() async {
    stopped = true;
  }

  @override
  Future<bool> unregister() async => true;
}

class FakeBadges implements NotificationBadges {
  bool cleared = false;
  @override
  Future<void> sync(Set<String> unreadIds, {bool clearAll = false}) async {
    cleared = clearAll;
  }
}

class FakeInbox implements NotificationRepository {
  Failure? failure;
  final readIds = <String>[];
  final item = const InboxNotification(
    id: 'notification-1',
    title: 'Jadwal',
    body: 'Ruang A2',
    route: '/pengumuman/3',
  );
  @override
  Future<List<InboxNotification>> fetchUnread() async => [await fetch(item.id)];
  @override
  Future<InboxNotification> fetch(String id) async {
    if (failure != null) throw failure!;
    return item;
  }

  @override
  Future<void> markAsRead(String id) async {
    readIds.add(id);
  }
}

void main() {
  test('login sukses menormalisasi email dan menyimpan kedua token', () async {
    final repository = FakeAuth();
    final store = MemoryStore();
    await Login(repository, store)(' mahasiswa@kampus.ac.id ', '123456');
    expect(repository.receivedEmail, 'mahasiswa@kampus.ac.id');
    expect(store.access, 'access');
    expect(store.refresh, 'refresh');
  });

  test('login ditolak tidak meninggalkan token', () async {
    final store = MemoryStore();
    final repository = FakeAuth()..failure = const AuthenticationFailure();
    await expectLater(
      Login(repository, store)('a@b.id', 'wrong'),
      throwsA(isA<AuthenticationFailure>()),
    );
    expect(store.access, isNull);
    expect(store.refresh, isNull);
  });

  test('penyimpanan pasangan token gagal membatalkan token parsial', () async {
    final store = MemoryStore()..failSaving = true;
    await expectLater(
      Login(FakeAuth(), store)('a@b.id', '123456'),
      throwsA(isA<UnexpectedFailure>()),
    );
    expect(store.access, isNull);
    expect(store.refresh, isNull);
  });

  test(
    'open notification mengambil detail sebelum menandainya dibaca',
    () async {
      final repository = FakeInbox();
      final item = await OpenNotification(repository)('notification-1');
      expect(item.title, 'Jadwal');
      expect(repository.readIds, ['notification-1']);
    },
  );

  test('fetch gagal tidak menandai pesan dibaca', () async {
    final repository = FakeInbox()..failure = const NetworkFailure();
    await expectLater(
      OpenNotification(repository)('notification-1'),
      throwsA(isA<NetworkFailure>()),
    );
    expect(repository.readIds, isEmpty);
  });

  test('halaman ditinggalkan saat fetch tidak menandai pesan dibaca', () async {
    final repository = FakeInbox();
    await OpenNotification(repository)('notification-1', isActive: () => false);
    expect(repository.readIds, isEmpty);
  });

  test(
    'logout offline tetap membersihkan sesi dan badge serta melaporkan false',
    () async {
      final store = MemoryStore();
      await store.save(access: 'access', refresh: 'refresh');
      final devices = FakeDevice();
      final badges = FakeBadges();
      final repository = FakeAuth()..failure = const NetworkFailure();
      final confirmed = await Logout(
        repository,
        devices,
        EndSession(store, devices, badges),
      )();
      expect(confirmed, isFalse);
      expect(store.access, isNull);
      expect(store.refresh, isNull);
      expect(devices.stopped, isTrue);
      expect(badges.cleared, isTrue);
    },
  );
}
