import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'pages/announcement_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'providers/auth_provider.dart';
import 'messaging/notification_route.dart';
import 'messaging/push_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  registerBackgroundHandler();
  final container = ProviderContainer();
  await container.read(pushServiceProvider);
  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}

final notificationRouteProvider = Provider<PendingNotificationRoute>((ref) {
  final pending = PendingNotificationRoute();
  ref.onDispose(pending.dispose);
  return pending;
});

final pushServiceProvider = Provider<Future<void>>((ref) {
  final pending = ref.read(notificationRouteProvider);
  ref.onDispose(() => unawaited(disposePushListeners()));
  return startPushService(pending.open);
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
        path: '/pengumuman/:id',
        builder: (_, state) =>
            AnnouncementPage(id: state.pathParameters['id'] ?? ''),
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Campus Notify',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
