class WebRtcService {
  const WebRtcService();

  Future<String> startPreview() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return 'Static WebRTC preview ready';
  }
}
