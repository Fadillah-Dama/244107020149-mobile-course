/// Error aman yang boleh melewati batas data menuju domain/presentation.
sealed class Failure implements Exception {
  const Failure(this.message);
  final String message;

  @override
  String toString() => message;
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'Tidak dapat terhubung. Periksa koneksi lalu coba lagi.',
  ]);
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure([
    super.message = 'Sesi berakhir atau email dan kata sandi tidak sesuai.',
  ]);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Data yang dikirim tidak valid.']);
}

class DataFailure extends Failure {
  const DataFailure([
    super.message = 'Respons server tidak valid. Silakan coba lagi.',
  ]);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([
    super.message = 'Operasi belum berhasil. Silakan coba lagi.',
  ]);
}

String failureMessage(Object? error) => error is Failure
    ? error.message
    : 'Operasi belum berhasil. Silakan coba lagi.';
