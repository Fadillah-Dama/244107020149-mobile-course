import 'package:campus_notify/core/failures.dart';

import 'dart:async';
import 'dart:convert';

import 'package:campus_notify/shared/data/network/api_client.dart';
import 'package:campus_notify/shared/data/network/api_config.dart';
import 'package:campus_notify/features/auth/data/repositories/laravel_auth_repository.dart';
import 'package:campus_notify/features/auth/data/datasources/secure_token_store.dart';
import 'package:campus_notify/app/di/providers.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/auth_fakes.dart';

ResponseBody jsonResponse(int status, [Object? data = const {}]) =>
    ResponseBody.fromString(
      jsonEncode(data),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('repository mengirim kredensial ke login Laravel dan membaca pasangan token', () async {
    final adapter = RecordingAdapter(
      (options) => jsonResponse(200, {
        'access_token': 'api-access',
        'refresh_token': 'api-refresh',
      }),
    );
    final dio = Dio(
      BaseOptions(
        baseUrl: apiBaseUrl,
        contentType: Headers.jsonContentType,
        headers: {'Accept': 'application/json'},
      ),
    )..httpClientAdapter = adapter;
    final auth = LaravelAuthRepository(dio: dio);
    addTearDown(auth.close);

    final session = await auth.login(
      email: 'mahasiswa@kampus.ac.id',
      password: '123456',
    );

    final request = adapter.requests.single;
    expect(request.uri.path, '/api/auth/login');
    expect(request.method, 'POST');
    expect(request.headers['Accept'], 'application/json');
    expect(request.data, {
      'email': 'mahasiswa@kampus.ac.id',
      'password': '123456',
      'device_name': 'Campus Notify Android',
    });
    expect(session.access, 'api-access');
    expect(session.refresh, 'api-refresh');
  });

  test(
    'repository mengirim refresh tanpa Bearer atau interceptor API',
    () async {
      final adapter = RecordingAdapter(
        (options) => jsonResponse(200, {
          'access_token': 'rotated-access',
          'refresh_token': 'rotated-refresh',
        }),
      );
      final dio = Dio(BaseOptions(baseUrl: apiBaseUrl))
        ..httpClientAdapter = adapter;
      final auth = LaravelAuthRepository(dio: dio);
      addTearDown(auth.close);

      final session = await auth.refresh('old-refresh');

      expect(adapter.requests.single.uri.path, '/api/auth/refresh');
      expect(adapter.requests.single.data, {'refresh_token': 'old-refresh'});
      expect(adapter.requests.single.headers['Authorization'], isNull);
      expect(session.access, 'rotated-access');
      expect(session.refresh, 'rotated-refresh');
    },
  );

  test('login yang ditolak server tidak menyimpan token', () async {
    final dio = Dio(BaseOptions(baseUrl: apiBaseUrl))
      ..httpClientAdapter = RecordingAdapter((_) => jsonResponse(401));
    final auth = LaravelAuthRepository(dio: dio);
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
    addTearDown(auth.close);
    await container.read(authStateProvider.future);

    await container
        .read(authStateProvider.notifier)
        .login('unknown@kampus.ac.id', '123456');

    expect(container.read(authStateProvider).hasError, isTrue);
    expect(await TokenStore().readAccess(), isNull);
    expect(await TokenStore().readRefresh(), isNull);
  });

  for (final body in <Object?>[
    null,
    {},
    {'access_token': 'access'},
    {'access_token': '', 'refresh_token': 'refresh'},
  ]) {
    test('respons pasangan token tidak valid ditolak: $body', () async {
      final dio = Dio(BaseOptions(baseUrl: apiBaseUrl))
        ..httpClientAdapter = RecordingAdapter((_) => jsonResponse(200, body));
      final auth = LaravelAuthRepository(dio: dio);
      addTearDown(auth.close);

      await expectLater(
        auth.login(email: 'mahasiswa@kampus.ac.id', password: '123456'),
        throwsA(isA<DataFailure>()),
      );
    });
  }

  test('dua request 401 bersamaan hanya melakukan satu rotasi token', () async {
    final store = TokenStore();
    await store.save(access: 'old-access', refresh: 'old-refresh');
    final auth = TestAuthRepository()..refreshGate = Completer<void>();
    final bothStarted = Completer<void>();
    var oldRequests = 0;
    final adapter = RecordingAdapter((options) {
      if (options.headers['Authorization'] == 'Bearer old-access') {
        oldRequests++;
        if (oldRequests == 2) bothStarted.complete();
        return jsonResponse(401);
      }
      return jsonResponse(200);
    });
    final dio = buildApiClient(store, auth)..httpClientAdapter = adapter;
    addTearDown(() => dio.close());

    final responses = Future.wait([
      dio.get<dynamic>('/first'),
      dio.get<dynamic>('/second'),
    ]);
    await bothStarted.future;
    auth.refreshGate!.complete();
    expect((await responses).map((response) => response.statusCode), [
      200,
      200,
    ]);
    expect(auth.refreshCalls, 1);
    expect(adapter.requests.length, 4);
    expect(await store.readRefresh(), 'renewed-refresh');
  });

  test(
    '401 yang terlambat memakai token terbaru tanpa refresh kedua',
    () async {
      final store = TokenStore();
      await store.save(access: 'old-access', refresh: 'old-refresh');
      final auth = TestAuthRepository();
      final slowStarted = Completer<void>();
      final releaseSlow = Completer<void>();
      final adapter = RecordingAdapter((options) async {
        if (options.headers['Authorization'] == 'Bearer old-access') {
          if (options.path == '/slow') {
            slowStarted.complete();
            await releaseSlow.future;
          }
          return jsonResponse(401);
        }
        return jsonResponse(200);
      });
      final dio = buildApiClient(store, auth)..httpClientAdapter = adapter;
      addTearDown(() => dio.close());

      final slow = dio.get<dynamic>('/slow');
      await slowStarted.future;
      expect((await dio.get<dynamic>('/fast')).statusCode, 200);
      releaseSlow.complete();

      expect((await slow).statusCode, 200);
      expect(auth.refreshCalls, 1);
    },
  );

  test(
    'gangguan jaringan saat refresh mempertahankan token dan status sesi',
    () async {
      final store = TokenStore();
      await store.save(access: 'old-access', refresh: 'old-refresh');
      final auth = TestAuthRepository()..refreshError = const NetworkFailure();
      var expired = false;
      final dio = buildApiClient(
        store,
        auth,
        onSessionExpired: () async {
          expired = true;
        },
      )..httpClientAdapter = RecordingAdapter((_) => jsonResponse(401));
      addTearDown(() => dio.close());

      await expectLater(
        dio.get<dynamic>('/user'),
        throwsA(isA<DioException>()),
      );

      expect(expired, isFalse);
      expect(await store.readAccess(), 'old-access');
      expect(await store.readRefresh(), 'old-refresh');
    },
  );

  for (final rejected in [false, true]) {
    test(
      'hasil refresh sesi lama tidak menimpa sesi baru (ditolak: $rejected)',
      () async {
        final store = TokenStore();
        await store.save(access: 'old-access', refresh: 'old-refresh');
        final auth = TestAuthRepository()
          ..refreshStarted = Completer<void>()
          ..refreshGate = Completer<void>()
          ..failRefresh = rejected;
        var expired = false;
        final dio =
            buildApiClient(
                store,
                auth,
                onSessionExpired: () async {
                  expired = true;
                },
              )
              ..httpClientAdapter = RecordingAdapter(
                (options) => jsonResponse(
                  options.headers['Authorization'] ==
                          'Bearer new-session-access'
                      ? 200
                      : 401,
                ),
              );
        addTearDown(() => dio.close());

        final request = dio.get<dynamic>('/user');
        await auth.refreshStarted!.future;
        await store.save(
          access: 'new-session-access',
          refresh: 'new-session-refresh',
        );
        auth.refreshGate!.complete();

        expect((await request).statusCode, 200);
        expect(expired, isFalse);
        expect(await store.readAccess(), 'new-session-access');
        expect(await store.readRefresh(), 'new-session-refresh');
      },
    );
  }

  test(
    'logout memanggil endpoint server lalu membersihkan kedua token',
    () async {
      final store = TokenStore();
      await store.save(access: 'access', refresh: 'refresh');
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
      final adapter = RecordingAdapter((_) => jsonResponse(200));
      container.read(apiClientProvider).httpClientAdapter = adapter;
      await container.read(authStateProvider.future);

      expect(await container.read(authStateProvider.notifier).logout(), isTrue);

      expect(adapter.requests.single.uri.path, '/api/auth/logout');
      expect(adapter.requests.single.method, 'POST');
      expect(adapter.requests.single.headers['Authorization'], 'Bearer access');
      expect(await store.readAccess(), isNull);
      expect(await store.readRefresh(), isNull);
      expect(container.read(authStateProvider).asData?.value, isFalse);
    },
  );

  test('logout offline melaporkan pencabutan belum terkonfirmasi dan tetap menghapus sesi lokal', () async {
    final store = TokenStore();
    await store.save(access: 'access', refresh: 'refresh');
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
    container.read(apiClientProvider).httpClientAdapter = RecordingAdapter((
      options,
    ) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      );
    });
    await container.read(authStateProvider.future);

    expect(await container.read(authStateProvider.notifier).logout(), isFalse);
    expect(await store.readAccess(), isNull);
    expect(await store.readRefresh(), isNull);
    expect(container.read(authStateProvider).asData?.value, isFalse);
  });
}
