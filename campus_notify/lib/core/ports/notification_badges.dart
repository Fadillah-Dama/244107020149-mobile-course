abstract class NotificationBadges {
  Future<void> sync(Set<String> unreadIds, {bool clearAll = false});
}
