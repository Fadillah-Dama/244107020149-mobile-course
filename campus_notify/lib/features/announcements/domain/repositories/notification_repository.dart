import '../entities/inbox_notification.dart';

abstract class NotificationRepository {
  Future<List<InboxNotification>> fetchUnread();
  Future<InboxNotification> fetch(String id);
  Future<void> markAsRead(String id);
}
