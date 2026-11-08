import 'package:dio/dio.dart';

import '../../../core/failures.dart';

/// Detail exception plugin/HTTP tidak pernah dikirim mentah ke UI.
Future<T> guardRequest<T>(Future<T> Function() operation) async {
  try {
    return await operation();
  } on Failure {
    rethrow;
  } on DioException catch (error) {
    final failure = error.error;
    if (failure is Failure) throw failure;
    if (error.response?.statusCode == 401) throw const AuthenticationFailure();
    if (error.response?.statusCode == 422) throw const ValidationFailure();
    if (error.response == null) throw const NetworkFailure();
    if (error.response?.statusCode == 404) {
      throw const DataFailure(
        'Data tidak ditemukan atau tidak tersedia untuk akun ini.',
      );
    }
    throw const UnexpectedFailure(
      'Server belum dapat memproses permintaan. Coba lagi.',
    );
  } on FormatException {
    throw const DataFailure();
  } catch (_) {
    throw const UnexpectedFailure();
  }
}
