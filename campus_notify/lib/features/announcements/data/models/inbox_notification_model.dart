import '../../domain/entities/inbox_notification.dart';

class InboxNotificationModel {
  const InboxNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.route,
  });
  final String id;
  final String title;
  final String body;
  final String route;

  factory InboxNotificationModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! String || id.isEmpty) {
      throw const FormatException('ID tidak valid');
    }
    return InboxNotificationModel(
      id: id,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      route: json['route'] as String? ?? '/',
    );
  }

  InboxNotification toEntity() =>
      InboxNotification(id: id, title: title, body: body, route: route);
}
