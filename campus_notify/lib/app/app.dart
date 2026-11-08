import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'di/providers.dart';
import 'routing/app_router.dart';
import '../features/announcements/presentation/providers/notification_providers.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        ref.read(authStateProvider).asData?.value == true) {
      ref.invalidate(unreadNotificationsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(unreadNotificationsProvider, (_, next) {
      final items = next.asData?.value;
      if (items != null) {
        unawaited(
          ref
              .read(badgeServiceProvider)
              .sync(items.map((item) => item.id).toSet()),
        );
      }
    });
    return MaterialApp.router(
      title: 'Campus Notify',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
