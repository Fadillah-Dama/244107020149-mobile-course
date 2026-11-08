import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_notify/app/di/providers.dart';
import 'package:campus_notify/core/failures.dart';

import '../../domain/entities/inbox_notification.dart';

final unreadNotificationsProvider =
    FutureProvider.autoDispose<List<InboxNotification>>((ref) async {
      final loggedIn = await ref.watch(authStateProvider.future);
      if (!ref.mounted || !loggedIn) return [];
      // CRUD sederhana: repository domain cukup, tidak perlu use case pembungkus.
      return ref.watch(notificationRepositoryProvider).fetchUnread();
    });

final notificationDetailsProvider = FutureProvider.autoDispose
    .family<InboxNotification, String>((ref, id) async {
      final loggedIn = ref.watch(authStateProvider).asData?.value ?? false;
      if (!loggedIn) {
        throw const AuthenticationFailure('Silakan login kembali.');
      }
      final notification = await ref.watch(openNotificationProvider)(
        id,
        isActive: () => ref.mounted,
      );
      if (ref.mounted) ref.invalidate(unreadNotificationsProvider);
      return notification;
    });
