import '../entities/inbox_notification.dart';
import '../repositories/notification_repository.dart';

class OpenNotification {
  const OpenNotification(this._repository);
  final NotificationRepository _repository;

  Future<InboxNotification> call(String id, {bool Function()? isActive}) async {
    final notification = await _repository.fetch(id);
    // Jangan menandai dibaca jika halaman/sesi sudah ditinggalkan saat fetch.
    if (isActive == null || isActive()) await _repository.markAsRead(id);
    return notification;
  }
}
