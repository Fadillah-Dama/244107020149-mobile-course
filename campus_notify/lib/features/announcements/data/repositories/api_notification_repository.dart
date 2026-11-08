import 'package:dio/dio.dart';

import '../../domain/entities/inbox_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../models/inbox_notification_model.dart';

import 'package:campus_notify/shared/data/network/guard_request.dart';

class ApiNotificationRepository implements NotificationRepository {
  ApiNotificationRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<InboxNotification>> fetchUnread() => guardRequest(() async {
    final response = await _dio.get<Map<String, dynamic>>('/notifications');
    final items = response.data?['data'];
    if (items is! List) {
      throw const FormatException('Respons daftar notifikasi tidak valid');
    }
    return items.map((item) {
      if (item is! Map) {
        throw const FormatException('Data notifikasi tidak valid');
      }
      return InboxNotificationModel.fromJson(Map<String, dynamic>.from(item))
          .toEntity();
    }).toList();
  });

  @override
  Future<InboxNotification> fetch(String id) => guardRequest(() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/notifications/${Uri.encodeComponent(id)}',
    );
    final item = response.data?['data'];
    if (item is! Map) {
      throw const FormatException('Detail notifikasi tidak valid');
    }
    return InboxNotificationModel.fromJson(Map<String, dynamic>.from(item))
        .toEntity();
  });

  @override
  Future<void> markAsRead(String id) => guardRequest(() async {
    await _dio.patch<void>('/notifications/${Uri.encodeComponent(id)}/read');
  });
}
