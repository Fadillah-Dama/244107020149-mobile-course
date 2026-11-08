/// Siklus registrasi perangkat, terpisah dari login dan detail Firebase.
abstract class DeviceSession {
  Future<void> start();
  Future<void> stop();
  Future<bool> unregister();
}
