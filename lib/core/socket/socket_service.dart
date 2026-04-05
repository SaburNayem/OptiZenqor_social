class SocketService {
  const SocketService();

  Future<bool> connect() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return true;
  }
}
