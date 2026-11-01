import 'package:dio/dio.dart';

import 'auth_repository.dart';
import 'token_store.dart';

Dio buildApiClient(
  TokenStore store,
  AuthRepository auth, {
  Future<void> Function()? onSessionExpired,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example-campus-api.test'));
  Future<void> expireSession() async {
    await store.clear();
    await onSessionExpired?.call();
  }

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final access = await store.readAccess();
        if (access != null) {
          options.headers['Authorization'] = 'Bearer $access';
        } else {
          options.headers.remove('Authorization');
        }
        handler.next(options);
      },
      onError: (e, handler) async {
        if (e.response?.statusCode != 401) return handler.next(e);
        // Batasi refresh dan retry menjadi satu kali per request.
        if (e.requestOptions.extra['authRetried'] == true) {
          await expireSession();
          return handler.next(e);
        }
        final refresh = await store.readRefresh();
        if (refresh == null || refresh.isEmpty) {
          await expireSession();
          return handler.next(e);
        }
        try {
          final renewed = await auth.refresh(refresh);
          await store.save(access: renewed, refresh: refresh);
        } catch (_) {
          await expireSession();
          return handler.next(e);
        }
        try {
          final options = e.requestOptions;
          options.extra['authRetried'] = true;
          final retry = await dio.fetch<dynamic>(options);
          handler.resolve(retry);
        } on DioException catch (retryError) {
          handler.next(retryError);
        }
      },
    ),
  );
  return dio;
}
