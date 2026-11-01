import 'dart:async';

import 'package:campus_notify/data/token_store.dart';
import 'package:campus_notify/main.dart';
import 'package:campus_notify/messaging/notification_route.dart';
import 'package:campus_notify/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

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
    final container = ProviderContainer();
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
      overrides: [tokenStoreProvider.overrideWithValue(store)],
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
    final container = ProviderContainer();
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
