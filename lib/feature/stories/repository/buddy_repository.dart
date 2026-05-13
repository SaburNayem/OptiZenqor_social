import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service/api_client_service.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/buddy_relationship_model.dart';

class BuddyRepository {
  BuddyRepository({ApiClientService? apiClient})
    : _apiClient = apiClient ?? _sharedApiClient;

  static final ApiClientService _sharedApiClient = ApiClientService();
  static const Duration _listFailureCooldown = Duration(seconds: 3);
  static final Map<String, Future<List<BuddyRelationshipModel>>>
  _inFlightListRequests = <String, Future<List<BuddyRelationshipModel>>>{};
  static final Map<String, _BuddyListFailure> _recentListFailures =
      <String, _BuddyListFailure>{};

  final ApiClientService _apiClient;

  Future<List<BuddyRelationshipModel>> fetchBuddies() {
    return _fetchList('/buddies');
  }

  Future<List<BuddyRelationshipModel>> fetchSentRequests() {
    return _fetchList('/buddies/requests/sent');
  }

  Future<List<BuddyRelationshipModel>> fetchReceivedRequests() {
    return _fetchList('/buddies/requests/received');
  }

  Future<BuddyRelationshipModel> createRequest(String targetUserId) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _apiClient
        .post('/buddies/requests', <String, dynamic>{
          'targetUserId': targetUserId.trim(),
        });
    _clearListState();
    return _readSingle(response, fallbackMessage: 'Unable to send buddy request.');
  }

  Future<BuddyRelationshipModel> acceptRequest(String requestId) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _apiClient
        .post('/buddies/requests/$requestId/accept', const <String, dynamic>{});
    _clearListState();
    return _readSingle(response, fallbackMessage: 'Unable to accept request.');
  }

  Future<BuddyRelationshipModel> rejectRequest(String requestId) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _apiClient
        .post('/buddies/requests/$requestId/reject', const <String, dynamic>{});
    _clearListState();
    return _readSingle(response, fallbackMessage: 'Unable to reject request.');
  }

  Future<void> cancelRequest(String requestId) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _apiClient
        .delete('/buddies/requests/$requestId');
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to cancel request.');
    }
    _clearListState();
  }

  Future<void> removeBuddy(String buddyUserId) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _apiClient
        .delete('/buddies/$buddyUserId');
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to remove buddy.');
    }
    _clearListState();
  }

  Future<List<BuddyRelationshipModel>> _fetchList(String endpoint) async {
    final _BuddyListFailure? recentFailure = _recentListFailures[endpoint];
    if (recentFailure != null &&
        DateTime.now().difference(recentFailure.failedAt) <
            _listFailureCooldown) {
      throw Exception(recentFailure.message);
    }

    final Future<List<BuddyRelationshipModel>>? inFlight =
        _inFlightListRequests[endpoint];
    if (inFlight != null) {
      return inFlight;
    }

    final Future<List<BuddyRelationshipModel>> request = _loadList(endpoint);
    _inFlightListRequests[endpoint] = request;
    try {
      return await request;
    } finally {
      if (identical(_inFlightListRequests[endpoint], request)) {
        _inFlightListRequests.remove(endpoint);
      }
    }
  }

  Future<List<BuddyRelationshipModel>> _loadList(String endpoint) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _apiClient
        .get(endpoint);
    if (!response.isSuccess || response.data['success'] == false) {
      final String message = response.message ?? 'Unable to load buddies.';
      _recentListFailures[endpoint] = _BuddyListFailure(
        message: message,
        failedAt: DateTime.now(),
      );
      throw Exception(message);
    }

    _recentListFailures.remove(endpoint);
    return ApiPayloadReader.readMapList(
      response.data,
      preferredKeys: const <String>['data', 'items', 'results'],
    ).map(BuddyRelationshipModel.fromApiJson).toList(growable: false);
  }

  void _clearListState() {
    _inFlightListRequests.clear();
    _recentListFailures.clear();
  }

  BuddyRelationshipModel _readSingle(
    ServiceResponseModel<Map<String, dynamic>> response, {
    required String fallbackMessage,
  }) {
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? fallbackMessage);
    }

    final List<Map<String, dynamic>> list = ApiPayloadReader.readMapList(
      response.data,
      preferredKeys: const <String>['data', 'items', 'results'],
    );
    if (list.isNotEmpty) {
      return BuddyRelationshipModel.fromApiJson(list.first);
    }

    return BuddyRelationshipModel.fromApiJson(response.data);
  }
}

class _BuddyListFailure {
  const _BuddyListFailure({required this.message, required this.failedAt});

  final String message;
  final DateTime failedAt;
}
