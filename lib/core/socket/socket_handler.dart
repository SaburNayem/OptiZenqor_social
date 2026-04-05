class SocketHandler {
  const SocketHandler();

  Future<String> handle(String event) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return 'Handled socket event: $event';
  }
}
