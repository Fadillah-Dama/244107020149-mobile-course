import 'package:dio/dio.dart';

import '../../domain/repositories/device_repository.dart';

import 'package:campus_notify/shared/data/network/guard_request.dart';

class ApiDeviceRepository implements DeviceRepository {
  ApiDeviceRepository(this._dio);

  final Dio _dio;

  @override
  Future<void> register(String token) => guardRequest(() async {
    await _dio.post<dynamic>(
      '/devices',
      data: {
        'fcm_token': token,
        'platform': 'android',
        'device_name': 'Campus Notify Android',
      },
    );
  });

  @override
  Future<void> unregister(String token) => guardRequest(() async {
    await _dio.delete<dynamic>('/devices', data: {'fcm_token': token});
  });
}
