import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:campus_notify/core/format.dart';

final _local = FlutterLocalNotificationsPlugin();
const campusTopic = 'pengumuman-kampus';
const _channel = AndroidNotificationChannel(
  'pengumuman',
  'Pengumuman Kampus',
  description: 'Informasi dan pengumuman untuk mahasiswa',
  importance: Importance.high,
  playSound: true,
  showBadge: true,
);

StreamSubscription<RemoteMessage>? _foregroundSubscription;
StreamSubscription<RemoteMessage>? _openedSubscription;
void Function(String route)? _navigate;
void Function()? _onInboxChanged;

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Isolate terpisah: jangan akses BuildContext, router, atau Riverpod.
  // Banner background ditampilkan Android; jangan tampilkan ulang di sini.
  debugPrint('[FCM][background] Pesan diterima');
}

void registerBackgroundHandler() {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

void _openNotification(String? payload) {
  _onInboxChanged?.call();
  final route = routeFromMessage({'route': payload});
  final navigate = _navigate;
  if (navigate == null) {
    pendingDeepLink = route;
  } else {
    navigate(route);
  }
}

Future<bool> requestNotificationPermission() async {
  final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    announcement: false,
    carPlay: false,
    criticalAlert: false,
  );
  return settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional;
}

Future<void> initLocalNotifications() async {
  const android = AndroidInitializationSettings('ic_stat_notification');
  // Izin diminta secara eksplisit melalui tombol persiapan notifikasi.
  const ios = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );
  await _local.initialize(
    settings: const InitializationSettings(android: android, iOS: ios),
    onDidReceiveNotificationResponse: (response) {
      // Klik local notification -> langsung teruskan ke router.
      _openNotification(response.payload);
    },
  );
  await _local
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(_channel);
}

Future<void> listenForeground(void Function(String route) go) async {
  // Hindari listener ganda bila service diinisialisasi ulang.
  await _foregroundSubscription?.cancel();
  await _openedSubscription?.cancel();
  _navigate = go;
  _foregroundSubscription = FirebaseMessaging.onMessage.listen((message) async {
    debugPrint('[FCM][foreground] Pesan diterima');
    _onInboxChanged?.call();
    try {
      await _local.show(
        id: message.hashCode & 0x7fffffff,
        title: message.notification?.title ?? 'Pengumuman',
        body: message.notification?.body ?? '',
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'pengumuman',
            'Pengumuman Kampus',
            channelDescription: 'Informasi dan pengumuman untuk mahasiswa',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            icon: 'ic_stat_notification',
            tag: message.data['notification_id'] is String
                ? 'campus-notification:${message.data['notification_id']}'
                : null,
            number: 1,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: routeFromMessage(message.data),
      );
    } catch (_) {
      debugPrint('[FCM][foreground] Gagal menampilkan local notification');
    }
  });
  _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen((message) {
    debugPrint('[FCM][background-click] Membuka halaman tujuan');
    _onInboxChanged?.call();
    go(routeFromMessage(message.data));
  });
}

Future<void> handleTerminated(void Function(String route) go) async {
  final initial = await FirebaseMessaging.instance.getInitialMessage();
  final localLaunch = await _local.getNotificationAppLaunchDetails();
  if (initial != null) {
    debugPrint('[FCM][terminated-click] Membuka halaman tujuan');
    go(routeFromMessage(initial.data));
  } else if (localLaunch?.didNotificationLaunchApp ?? false) {
    go(routeFromMessage({'route': localLaunch?.notificationResponse?.payload}));
  } else if (pendingDeepLink != null) {
    go(pendingDeepLink!);
  }
  pendingDeepLink = null;
}

Future<void> startPushService(
  void Function(String route) go, {
  void Function()? onInboxChanged,
}) async {
  _onInboxChanged = onInboxChanged;
  await initLocalNotifications();
  // iOS: banner foreground ditangani local notifications agar tidak ganda.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: false,
    badge: false,
    sound: false,
  );
  await listenForeground(go);
  await handleTerminated(go);
}

Future<void> disposePushListeners() async {
  await _foregroundSubscription?.cancel();
  await _openedSubscription?.cancel();
  _foregroundSubscription = null;
  _openedSubscription = null;
  _navigate = null;
  _onInboxChanged = null;
}

Future<void> subscribeCampusTopic() =>
    FirebaseMessaging.instance.subscribeToTopic(campusTopic);

Future<void> unsubscribeCampusTopic() =>
    FirebaseMessaging.instance.unsubscribeFromTopic(campusTopic);

Future<void> initFcmToken({
  required Future<void> Function(String token) onToken,
}) async {
  // 1. Ambil token saat ini dan kirim ke backend.
  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) await onToken(token);

  // 2. Token bisa berubah (reinstall, clear data, rotasi keamanan).
  //    Listener ini WAJIB ada, jika tidak backend menyimpan token basi.
  FirebaseMessaging.instance.onTokenRefresh.listen(onToken);

  // 3. Langganan topik kampus (mis. semua mahasiswa angkatan).
  await subscribeCampusTopic();
}

String? pendingDeepLink;
