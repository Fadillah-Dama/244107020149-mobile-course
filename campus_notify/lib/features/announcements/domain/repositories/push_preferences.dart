abstract class PushPreferences {
  Future<bool> prepareAndCopyToken();
  Future<void> setTopicSubscription(bool subscribe);
}
