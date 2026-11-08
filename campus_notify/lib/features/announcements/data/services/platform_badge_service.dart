import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:campus_notify/core/ports/notification_badges.dart';

/// Jumlah berasal dari API, bukan menambah/mengurangi angka secara lokal.
class BadgeService implements NotificationBadges {
  final _notifications = FlutterLocalNotificationsPlugin();
  Future<void> _pending = Future<void>.value();

  @override
  Future<void> sync(Set<String> unreadIds, {bool clearAll = false}) {
    final ids = Set<String>.of(unreadIds);
    _pending = _pending.then((_) async {
      try {
        if (clearAll) {
          await _notifications.cancelAll();
        } else {
          final active = await _notifications.getActiveNotifications();
          for (final notification in active) {
            final tag = notification.tag;
            if (tag != null &&
                tag.startsWith('campus-notification:') &&
                !ids.contains(tag.substring('campus-notification:'.length)) &&
                notification.id != null) {
              await _notifications.cancel(id: notification.id!, tag: tag);
            }
          }
        }
      } catch (_) {
        debugPrint('[Badge] Gagal membersihkan banner yang sudah dibaca');
      }
      try {
        if (await AppBadgePlus.isSupported()) {
          await AppBadgePlus.updateBadge(ids.length);
        }
      } catch (_) {
        // Dukungan badge berbeda antar-launcher; jangan gagalkan login/baca.
        debugPrint('[Badge] Launcher tidak dapat memperbarui angka ikon');
      }
    });
    return _pending;
  }
}
