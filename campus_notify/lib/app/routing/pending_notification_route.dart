import 'package:flutter/foundation.dart';

import '../../core/format.dart';

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
