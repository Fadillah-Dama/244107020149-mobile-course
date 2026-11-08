import 'package:dio/dio.dart';

import 'package:campus_notify/shared/data/network/api_config.dart';
import 'package:campus_notify/shared/data/network/guard_request.dart';

import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/auth_session_model.dart';

class LaravelAuthRepository implements AuthRepository {
  LaravelAuthRepository({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: apiBaseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              contentType: Headers.jsonContentType,
              headers: {'Accept': 'application/json'},
            ),
          );

  final Dio _dio;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) => guardRequest(() async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
        'device_name': 'Campus Notify Android',
      },
    );

    return AuthSessionModel.fromJson(response.data ?? const {}).toEntity();
  });

  @override
  Future<AuthSession> refresh(String refreshToken) => guardRequest(() async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
    );

    return AuthSessionModel.fromJson(response.data ?? const {}).toEntity();
  });

  void close() => _dio.close(force: true);
}
