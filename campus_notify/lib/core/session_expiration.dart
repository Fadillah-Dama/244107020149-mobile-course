/// Penghubung sesi tanpa membuat network bergantung pada controller UI.
class SessionExpiration {
  Future<void> Function()? _listener;

  void listen(Future<void> Function() listener) => _listener = listener;

  void removeListener(Future<void> Function() listener) {
    if (identical(_listener, listener)) _listener = null;
  }

  Future<void> expire() async {
    await _listener?.call();
  }
}
