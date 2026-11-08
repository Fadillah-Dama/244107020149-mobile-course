import 'package:dio/dio.dart';

import 'package:campus_notify/shared/data/network/api_config.dart';
import 'package:campus_notify/features/auth/domain/entities/auth_session.dart';
import 'package:campus_notify/features/auth/domain/repositories/auth_repository.dart';
import 'package:campus_notify/features/auth/domain/repositories/session_store.dart';
import 'package:campus_notify/core/failures.dart';

class SessionExpiredException implements Exception {
  const SessionExpiredException();
}

Dio buildApiClient(
  SessionStore store,
  AuthRepository auth, {
  Future<void> Function()? onSessionExpired,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    ),
  );

  Future<void>? refreshInProgress;

  Future<void> expireSession() async {
    await store.clear();
    await onSessionExpired?.call();
  }

  Future<void> renewTokens(String? failedAuthorization) async {
    final currentAccess = await store.readAccess();

    if (currentAccess == null || currentAccess.isEmpty) {
      throw const SessionExpiredException();
    }

    // Request lama mungkin gagal setelah request lain memperbarui token.
    if (failedAuthorization != 'Bearer $currentAccess') return;

    final refreshToken = await store.readRefresh();

    if (refreshToken == null || refreshToken.isEmpty) {
      throw const SessionExpiredException();
    }

    final AuthSession renewed;
    try {
      renewed = await auth.refresh(refreshToken);
    } catch (_) {
      // Respons untuk sesi lama tidak boleh menghapus sesi login yang baru.
      if (await store.readRefresh() != refreshToken) return;
      rethrow;
    }

    // Jangan menimpa sesi jika pengguna sudah logout atau berganti sesi.
    if (await store.readRefresh() != refreshToken) return;

    await store.save(access: renewed.access, refresh: renewed.refresh);
  }

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final access = await store.readAccess();

        if (access != null && access.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $access';
        } else {
          options.headers.remove('Authorization');
        }

        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode != 401) {
          return handler.next(error);
        }

        if (error.requestOptions.extra['authRetried'] == true) {
          await expireSession();
          return handler.next(error);
        }

        try {
          final operation = refreshInProgress ??= renewTokens(
            error.requestOptions.headers['Authorization'] as String?,
          );

          try {
            await operation;
          } finally {
            if (identical(refreshInProgress, operation)) {
              refreshInProgress = null;
            }
          }
        } on SessionExpiredException {
          await expireSession();
          return handler.next(error);
        } on Failure catch (failure) {
          if (failure is AuthenticationFailure ||
              failure is ValidationFailure) {
            await expireSession();
          }
          return handler.next(
            DioException(requestOptions: error.requestOptions, error: failure),
          );
        } on DioException catch (refreshError) {
          final status = refreshError.response?.statusCode;

          if (status == 401 || status == 422) {
            await expireSession();
          }

          // Gangguan jaringan tidak otomatis menghapus sesi.
          return handler.next(refreshError);
        } catch (_) {
          return handler.next(error);
        }

        try {
          final options = error.requestOptions;
          options.extra['authRetried'] = true;

          final response = await dio.fetch<dynamic>(options);
          handler.resolve(response);
        } on DioException catch (retryError) {
          handler.next(retryError);
        }
      },
    ),
  );

  return dio;
}
