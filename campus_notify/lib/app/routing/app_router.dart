import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../di/providers.dart';
import 'pending_notification_route.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/announcements/presentation/pages/home_page.dart';
import '../../features/announcements/presentation/pages/announcement_page.dart';
import '../../features/announcements/presentation/pages/notifications_page.dart';

final notificationRouteProvider = Provider<PendingNotificationRoute>((ref) {
  final pending = PendingNotificationRoute();
  ref.onDispose(pending.dispose);
  return pending;
});

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  final pending = ref.read(notificationRouteProvider);
  ref.listen(authStateProvider, (_, _) => refresh.value++);
  final router = GoRouter(
    initialLocation: '/login',
    refreshListenable: Listenable.merge([refresh, pending]),
    redirect: (context, state) {
      final loggedIn = ref.read(authStateProvider).asData?.value ?? false;
      final goingLogin = state.matchedLocation == '/login';
      if (!loggedIn && !goingLogin) return '/login';
      if (loggedIn) {
        final destination = pending.take();
        if (destination != null && destination != state.uri.toString()) {
          return destination;
        }
      }
      if (loggedIn && goingLogin) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
      GoRoute(path: '/', builder: (_, _) => const HomePage()),
      GoRoute(
        path: '/notifikasi',
        builder: (_, _) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/pengumuman/:id',
        builder: (_, state) => AnnouncementPage(
          id: state.pathParameters['id'] ?? '',
          notificationId: state.uri.queryParameters['notification_id'],
        ),
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
