import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../domain/repositories/device_repository.dart';

import 'package:campus_notify/core/ports/device_session.dart';

class DeviceSyncService implements DeviceSession {
  DeviceSyncService(this._repository);

  final DeviceRepository _repository;
  StreamSubscription<String>? _subscription;
  Future<void> _pending = Future<void>.value();
  bool _active = false;
  int _generation = 0;
  String? _lastToken;

  @override
  Future<void> start() async {
    if (_active) return;

    _active = true;
    final generation = ++_generation;

    try {
      _subscription = FirebaseMessaging.instance.onTokenRefresh.listen(
        (token) {
          unawaited(
            _register(token, generation).catchError((Object _) {
              debugPrint('[FCM] Pembaruan perangkat belum berhasil.');
            }),
          );
        },
        onError: (Object _) {
          debugPrint('[FCM] Gagal memantau perubahan token.');
        },
      );

      final token = await _currentToken();
      if (token != null && token.isNotEmpty) {
        await _register(token, generation);
      }
    } catch (_) {
      debugPrint('[FCM] Pendaftaran perangkat belum berhasil.');
    }
  }

  Future<void> _register(String token, int generation) {
    final task = _pending.then((_) async {
      if (!_active || generation != _generation) return;
      final previousToken = _lastToken;

      await _repository.register(token);
      _lastToken = token;

      if (previousToken != null && previousToken != token) {
        await _repository.unregister(previousToken);
      }

      debugPrint('[FCM] Perangkat berhasil disinkronkan.');
    });

    // Pertahankan antrean setelah kegagalan, sementara pemanggil menangani error.
    _pending = task.catchError((Object _) {});
    return task;
  }

  @override
  Future<void> stop() async {
    _active = false;
    _generation++;

    final subscription = _subscription;
    _subscription = null;
    await subscription?.cancel();
    // Jangan menunggu _pending di sini: interceptor 401 dapat memanggil stop()
    // dari dalam request pendaftaran yang sedang berlangsung.
  }

  @override
  Future<bool> unregister() async {
    await stop();
    await _pending;

    final tokens = <String>{?_lastToken};
    try {
      final current = await _currentToken();
      if (current != null && current.isNotEmpty) tokens.add(current);
    } catch (_) {
      // Token terakhir tetap bisa dilepas jika pembacaan token Firebase gagal.
    }

    if (tokens.isEmpty) return false;

    var allRemoved = true;
    for (final token in tokens) {
      try {
        await _repository.unregister(token);
      } catch (_) {
        allRemoved = false;
      }
    }

    if (allRemoved) {
      _lastToken = null;
    } else {
      debugPrint('[FCM] Pelepasan perangkat belum terkonfirmasi.');
    }
    return allRemoved;
  }

  Future<String?> _currentToken() => FirebaseMessaging.instance
      .getToken()
      .timeout(const Duration(seconds: 10));
}
