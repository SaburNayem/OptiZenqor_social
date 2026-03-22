class UploadService {
  Future<String> uploadFile(String localPath) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return 'remote://uploaded/$localPath';
  }
}
