class ApiClientService {
  Future<Map<String, dynamic>> get(String endpoint) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return {'endpoint': endpoint, 'status': 'stubbed'};
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> payload,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return {'endpoint': endpoint, 'payload': payload, 'status': 'stubbed'};
  }
}
