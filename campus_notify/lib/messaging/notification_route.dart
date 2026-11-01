import 'package:flutter/foundation.dart';

/// Hanya buka halaman aplikasi yang memang tersedia, bukan URL dari luar.
String routeFromMessage(Map<String, dynamic> data) {
  final value = data['route'];
  if (value is! String || value.trim().isEmpty) return '/';
  final route = value.trim().startsWith('/')
      ? value.trim()
      : '/${value.trim()}';
  if (route == '/' || RegExp(r'^/pengumuman/[a-zA-Z0-9_-]+$').hasMatch(route)) {
    return route;
  }
  return '/';
}

/// Menahan tujuan klik selama pemulihan sesi atau proses login.
class PendingNotificationRoute extends ChangeNotifier {
  String? _route;

  void open(String route) {
    _route = routeFromMessage({'route': route});
    notifyListeners();
  }

  // Router mengonsumsi tujuan sekali tanpa memicu redirect tambahan.
  String? take() {
    final route = _route;
    _route = null;
    return route;
  }
}
