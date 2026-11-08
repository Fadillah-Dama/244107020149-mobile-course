import 'package:dio/dio.dart';
import 'package:campus_notify/shared/data/network/guard_request.dart';

import '../../domain/repositories/session_revoker.dart';

class ApiSessionRevoker implements SessionRevoker {
  const ApiSessionRevoker(this._dio);
  final Dio _dio;

  @override
  Future<void> logout() => guardRequest(() async {
    await _dio.post<dynamic>('/auth/logout');
  });
}
