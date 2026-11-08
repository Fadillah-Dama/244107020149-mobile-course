import 'dart:typed_data';

import 'package:campus_notify/shared/data/network/api_client.dart';
import 'package:campus_notify/features/auth/data/datasources/secure_token_store.dart';
import 'package:campus_notify/app/app.dart';
import 'package:campus_notify/app/routing/app_router.dart';
import 'package:campus_notify/app/di/providers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/auth_fakes.dart';

class TestAdapter implements HttpClientAdapter {
  TestAdapter(this.statuses);
  final List<int> statuses;
  final headers = <String?>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    headers.add(options.headers['Authorization'] as String?);
    return ResponseBody.fromString(
      '{}',
      statuses.removeAt(0),
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('TokenStore menyimpan, membaca, dan menghapus kedua token', () async {
    final store = TokenStore();
    await store.save(access: 'access', refresh: 'refresh');
    expect(await store.readAccess(), 'access');
    expect(await store.readRefresh(), 'refresh');
    await store.clear();
    expect(await store.readAccess(), isNull);
    expect(await store.readRefresh(), isNull);
  });

  test(
    'provider memulihkan sesi yang tersimpan dan logout menghapus sesi',
    () async {
      final store = TokenStore();
      await store.save(access: 'saved-access', refresh: 'saved-refresh');
      final container = ProviderContainer(
        overrides: [
          badgeServiceProvider.overrideWithValue(TestBadges()),
          notificationRepositoryProvider.overrideWithValue(
            TestNotificationRepository(),
          ),
          deviceSyncProvider.overrideWithValue(TestDeviceSyncService()),
          authRepositoryProvider.overrideWithValue(TestAuthRepository()),
        ],
      );
      container.read(apiClientProvider).httpClientAdapter = TestAdapter([200]);
      addTearDown(container.dispose);
      expect(await container.read(authStateProvider.future), isTrue);
      await container.read(authStateProvider.notifier).logout();
      expect(container.read(authStateProvider).asData?.value, isFalse);
      expect(await store.readAccess(), isNull);
      expect(await store.readRefresh(), isNull);
    },
  );

  test('login invalid menghasilkan error tanpa menyimpan token', () async {
    final container = ProviderContainer(
      overrides: [
        badgeServiceProvider.overrideWithValue(TestBadges()),
        notificationRepositoryProvider.overrideWithValue(
          TestNotificationRepository(),
        ),
        deviceSyncProvider.overrideWithValue(TestDeviceSyncService()),
        authRepositoryProvider.overrideWithValue(TestAuthRepository()),
      ],
    );
    addTearDown(container.dispose);
    await container.read(authStateProvider.future);
    await container.read(authStateProvider.notifier).login('invalid', '123');
    expect(container.read(authStateProvider).hasError, isTrue);
    expect(await container.read(tokenStoreProvider).readAccess(), isNull);
  });

  testWidgets('guard, validasi form, login, detail, dan logout', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        badgeServiceProvider.overrideWithValue(TestBadges()),
        notificationRepositoryProvider.overrideWithValue(
          TestNotificationRepository(),
        ),
        deviceSyncProvider.overrideWithValue(TestDeviceSyncService()),
        authRepositoryProvider.overrideWithValue(TestAuthRepository()),
      ],
    );
    container.read(apiClientProvider).httpClientAdapter = TestAdapter([200]);
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MyApp()),
    );
    await tester.pumpAndSettle();
    final router = container.read(routerProvider);
    router.go('/pengumuman/3');
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/login');

    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pumpAndSettle();
    expect(find.text('Masukkan email yang valid'), findsOneWidget);
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'mahasiswa@kampus.ac.id',
    );
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Pengumuman Kampus'), findsOneWidget);
    expect(await TokenStore().readAccess(), isNotNull);

    await tester.tap(find.text('Jadwal kuliah berubah'));
    await tester.pumpAndSettle();
    expect(find.text('Pengumuman #3'), findsOneWidget);
    router.go('/');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keluar'));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/login');
    expect(await TokenStore().readRefresh(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  test(
    '401 memperbarui token dan mengulang request dengan Bearer baru',
    () async {
      final store = TokenStore();
      await store.save(access: 'old-access', refresh: 'refresh');
      final auth = TestAuthRepository();
      final adapter = TestAdapter([401, 200]);
      final dio = buildApiClient(store, auth)..httpClientAdapter = adapter;
      addTearDown(() => dio.close());
      expect((await dio.get<dynamic>('/protected')).statusCode, 200);
      expect(auth.refreshCalls, 1);
      expect(adapter.headers, ['Bearer old-access', 'Bearer renewed-access']);
      expect(await store.readAccess(), 'renewed-access');
      expect(await store.readRefresh(), 'renewed-refresh');
    },
  );

  test('401 berulang berhenti setelah satu retry dan memaksa logout', () async {
    final store = TokenStore();
    await store.save(access: 'old-access', refresh: 'refresh');
    final auth = TestAuthRepository();
    final container = ProviderContainer(
      overrides: [
        badgeServiceProvider.overrideWithValue(TestBadges()),
        notificationRepositoryProvider.overrideWithValue(
          TestNotificationRepository(),
        ),
        deviceSyncProvider.overrideWithValue(TestDeviceSyncService()),
        authRepositoryProvider.overrideWithValue(auth),
      ],
    );
    addTearDown(container.dispose);
    expect(await container.read(authStateProvider.future), isTrue);
    final adapter = TestAdapter([401, 401]);
    final dio = container.read(apiClientProvider)..httpClientAdapter = adapter;
    await expectLater(
      dio.get<dynamic>('/protected'),
      throwsA(isA<DioException>()),
    );
    expect(auth.refreshCalls, 1);
    expect(adapter.headers.length, 2);
    expect(await store.readAccess(), isNull);
    expect(container.read(authStateProvider).asData?.value, isFalse);
  });

  test(
    'refresh gagal atau hilang membersihkan kedua token tanpa retry',
    () async {
      for (final refresh in ['refresh', '']) {
        final store = TokenStore();
        await store.save(access: 'old-access', refresh: refresh);
        final auth = TestAuthRepository()..failRefresh = true;
        final adapter = TestAdapter([401]);
        var expired = false;
        final dio = buildApiClient(
          store,
          auth,
          onSessionExpired: () async {
            expired = true;
          },
        )..httpClientAdapter = adapter;
        await expectLater(
          dio.get<dynamic>('/protected'),
          throwsA(isA<DioException>()),
        );
        expect(expired, isTrue);
        expect(adapter.headers.length, 1);
        expect(await store.readAccess(), isNull);
        expect(await store.readRefresh(), isNull);
        dio.close();
      }
    },
  );
}
