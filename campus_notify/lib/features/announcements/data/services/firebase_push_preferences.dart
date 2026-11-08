import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';

import 'package:campus_notify/core/failures.dart';

import '../../domain/repositories/push_preferences.dart';
import 'firebase_push_service.dart';

class FirebasePushPreferences implements PushPreferences {
  @override
  Future<bool> prepareAndCopyToken() async {
    try {
      if (!await requestNotificationPermission()) return false;
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) {
        throw const UnexpectedFailure(
          'Token FCM belum tersedia. Silakan coba lagi.',
        );
      }
      await Clipboard.setData(ClipboardData(text: token));
      return true;
    } on Failure {
      rethrow;
    } on FirebaseException catch (error) {
      throw _failure(error.code, error.message ?? '');
    } on PlatformException catch (error) {
      throw _failure(error.code, error.message ?? '');
    } catch (_) {
      throw const UnexpectedFailure(
        'Gagal menyiapkan notifikasi. Silakan coba lagi.',
      );
    }
  }

  @override
  Future<void> setTopicSubscription(bool subscribe) async {
    try {
      if (subscribe) {
        await subscribeCampusTopic();
      } else {
        await unsubscribeCampusTopic();
      }
    } catch (_) {
      throw const NetworkFailure(
        'Gagal mengubah langganan. Periksa koneksi lalu coba lagi.',
      );
    }
  }

  Failure _failure(String code, String details) {
    final reason = '$code $details'.toUpperCase();
    if (reason.contains('SERVICE_NOT_AVAILABLE') ||
        reason.contains('NETWORK') ||
        reason.contains('TIMEOUT')) {
      return const NetworkFailure(
        'Layanan Firebase belum dapat dijangkau. Periksa Wi-Fi/data seluler lalu coba lagi.',
      );
    }
    if (reason.contains('FIS_AUTH_ERROR') ||
        reason.contains('API_KEY') ||
        reason.contains('AUTHENTICATION_FAILED') ||
        reason.contains('BAD_CONFIG')) {
      return const UnexpectedFailure(
        'Periksa konfigurasi Firebase dan google-services.json untuk aplikasi Android ini.',
      );
    }
    if (reason.contains('MISSING_INSTANCEID_SERVICE')) {
      return const UnexpectedFailure(
        'Periksa apakah Google Play services aktif dan sudah diperbarui.',
      );
    }
    if (reason.contains('TOO_MANY_REGISTRATIONS')) {
      return const UnexpectedFailure(
        'Terlalu banyak registrasi FCM. Coba perangkat lain untuk pengujian.',
      );
    }
    return const UnexpectedFailure(
      'Persiapan notifikasi belum berhasil. Periksa izin dan koneksi lalu coba lagi.',
    );
  }
}
