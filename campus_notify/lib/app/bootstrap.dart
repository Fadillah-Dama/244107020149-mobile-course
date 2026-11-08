import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/announcements/data/services/firebase_push_service.dart';
import '../features/announcements/presentation/providers/notification_providers.dart';
import 'routing/app_router.dart';

final pushServiceProvider = Provider<Future<void>>((ref) {
  final pending = ref.read(notificationRouteProvider);
  ref.onDispose(() => unawaited(disposePushListeners()));
  return startPushService(
    pending.open,
    onInboxChanged: () => ref.invalidate(unreadNotificationsProvider),
  );
});
