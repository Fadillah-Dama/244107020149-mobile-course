import '../../../../core/ports/device_session.dart';
import '../../../../core/ports/notification_badges.dart';
import '../repositories/session_store.dart';

class EndSession {
  const EndSession(this._store, this._devices, this._badges);
  final SessionStore _store;
  final DeviceSession _devices;
  final NotificationBadges _badges;

  Future<void> call() async {
    await _devices.stop();
    await _store.clear();
    await _badges.sync({}, clearAll: true);
  }
}
