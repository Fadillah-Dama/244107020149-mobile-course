import 'package:campus_notify/core/format.dart';

import 'dart:async';

import 'package:campus_notify/features/auth/data/datasources/secure_token_store.dart';
import 'package:campus_notify/app/app.dart';
import 'package:campus_notify/app/routing/app_router.dart';
import 'package:campus_notify/app/di/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/auth_fakes.dart';

class DelayedTokenStore extends TokenStore {
  final ready = Completer<String?>();

  @override
  Future<String?> readAccess() => ready.future;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('route payload dinormalisasi dan route tidak dikenal ditolak', () {
    expect(routeFromMessage({}), '/');
    expect(routeFromMessage({'route': ''}), '/');
    expect(routeFromMessage({'route': 3}), '/');
    expect(routeFromMessage({'route': 'pengumuman/3'}), '/pengumuman/3');
    expect(
      routeFromMessage({'route': '/pengumuman/3', 'id': '3'}),
      '/pengumuman/3',
    );
    expect(routeFromMessage({'route': 'https://example.com'}), '/');
    expect(routeFromMessage({'route': '//example.com'}), '/');
    expect(routeFromMessage({'route': '/pengumuman/../login'}), '/');
  });

  testWidgets('klik background/foreground membuka detail hanya sekali', (
    tester,
  ) async {
    await TokenStore().save(access: 'access', refresh: 'refresh');
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
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MyApp()),
    );
    await tester.pumpAndSettle();
    container.read(notificationRouteProvider).open('/pengumuman/3');
    await tester.pumpAndSettle();
    expect(find.text('Pengumuman #3'), findsOneWidget);
    container.read(routerProvider).go('/');
    await tester.pumpAndSettle();
    expect(find.text('Pengumuman Kampus'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('tujuan terminated menunggu pemulihan sesi', (tester) async {
    final store = DelayedTokenStore();
    final container = ProviderContainer(
      overrides: [
        badgeServiceProvider.overrideWithValue(TestBadges()),
        notificationRepositoryProvider.overrideWithValue(
          TestNotificationRepository(),
        ),
        deviceSyncProvider.overrideWithValue(TestDeviceSyncService()),
        tokenStoreProvider.overrideWithValue(store),
        authRepositoryProvider.overrideWithValue(TestAuthRepository()),
      ],
    );
    addTearDown(container.dispose);
    // Sama dengan callback getInitialMessage sebelum UI mulai ditampilkan.
    container.read(notificationRouteProvider).open('/pengumuman/3');
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MyApp()),
    );
    await tester.pump();
    expect(find.text('Pengumuman #3'), findsNothing);
    store.ready.complete('saved-access');
    await tester.pumpAndSettle();
    expect(find.text('Pengumuman #3'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('klik tanpa sesi menunggu login lalu membuka tujuan', (
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
    addTearDown(container.dispose);
    await container.read(authStateProvider.future);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MyApp()),
    );
    await tester.pumpAndSettle();
    container.read(notificationRouteProvider).open('/pengumuman/3');
    await tester.pumpAndSettle();
    expect(
      container.read(routerProvider).routeInformationProvider.value.uri.path,
      '/login',
    );
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'mahasiswa@kampus.ac.id',
    );
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Pengumuman #3'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
