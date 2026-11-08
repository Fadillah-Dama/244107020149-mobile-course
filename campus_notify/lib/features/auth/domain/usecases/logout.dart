import '../../../../core/failures.dart';
import '../../../../core/ports/device_session.dart';
import '../repositories/session_revoker.dart';
import 'end_session.dart';

/// Pelepasan perangkat dilakukan sebelum akses server dicabut.
class Logout {
  const Logout(this._repository, this._devices, this._endSession);
  final SessionRevoker _repository;
  final DeviceSession _devices;
  final EndSession _endSession;

  Future<bool> call() async {
    var deviceRemoved = false;
    var serverRevoked = false;
    try {
      deviceRemoved = await _devices.unregister();
      await _repository.logout();
      serverRevoked = true;
    } on Failure {
      // Kegagalan server tidak mencegah penghapusan sesi lokal.
    } finally {
      await _endSession();
    }
    return deviceRemoved && serverRevoked;
  }
}
