import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service/api_client_service.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/buddy_relationship_model.dart';

class BuddyRepository {
  BuddyRepository({ApiClientService? apiClient})
    : _apiClient = apiClient ?? ApiClientService();

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

  Future<BuddyRelationshipModel> acceptRequest(String requestId) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _apiClient
        .post('/buddies/requests/$requestId/accept', const <String, dynamic>{});
    return _readSingle(response, fallbackMessage: 'Unable to accept request.');
  }

  Future<BuddyRelationshipModel> rejectRequest(String requestId) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _apiClient
        .post('/buddies/requests/$requestId/reject', const <String, dynamic>{});
    return _readSingle(response, fallbackMessage: 'Unable to reject request.');
  }

  Future<void> cancelRequest(String requestId) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _apiClient
        .delete('/buddies/requests/$requestId');
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to cancel request.');
    }
  }

  Future<void> removeBuddy(String buddyUserId) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _apiClient
        .delete('/buddies/$buddyUserId');
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to remove buddy.');
    }
  }

  Future<List<BuddyRelationshipModel>> _fetchList(String endpoint) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _apiClient
        .get(endpoint);
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to load buddies.');
    }

    return ApiPayloadReader.readMapList(
      response.data,
      preferredKeys: const <String>['data', 'items', 'results'],
    ).map(BuddyRelationshipModel.fromApiJson).toList(growable: false);
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
