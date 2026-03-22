class NotificationService {
  Future<void> initialize() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }

  Future<void> subscribe(String topic) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    // Push provider subscription stub.
    topic;
  }
}
