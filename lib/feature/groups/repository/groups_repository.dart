import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/group_model.dart';
import '../service/groups_service.dart';

class GroupsRepository {
  GroupsRepository({GroupsService? service})
    : _service = service ?? GroupsService();

  final GroupsService _service;

  Future<List<GroupModel>> load() async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .getEndpoint('groups');
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to load groups.');
    }

    final Map<String, dynamic> data = ApiPayloadReader.requireDataMap(
      response.data,
      fallbackMessage: 'Groups response did not include a data payload.',
    );
    return ApiPayloadReader.readMapList(
          data,
          preferredKeys: const <String>['groups'],
        )
        .map(_groupFromApiJson)
        .where((GroupModel item) => item.id.isNotEmpty)
        .toList(growable: false);
  }

  Future<GroupModel?> createGroup(String name) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .post('/communities', <String, dynamic>{
          'name': name.trim(),
          'description': 'Group created from the mobile communities flow.',
        });
    if (!response.isSuccess || response.data['success'] == false) {
      return null;
    }
    final Map<String, dynamic>? payload = _readGroupPayload(response.data);
    return payload == null ? null : _groupFromApiJson(payload);
  }

  Future<GroupModel?> setJoined({
    required String id,
    required bool joined,
  }) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .post(
          joined ? '/communities/$id/join' : '/communities/$id/leave',
          const <String, dynamic>{},
        );
    if (!response.isSuccess || response.data['success'] == false) {
      return null;
    }
    final Map<String, dynamic>? payload = _readGroupPayload(response.data);
    return payload == null ? null : _groupFromApiJson(payload);
  }

  Map<String, dynamic>? _readGroupPayload(Map<String, dynamic> response) {
    final Map<String, dynamic>? data = ApiPayloadReader.readDataMap(response);
    return ApiPayloadReader.readMap(data?['group']) ??
        ApiPayloadReader.readMap(data?['community']) ??
        ApiPayloadReader.readMap(data) ??
        ApiPayloadReader.readMap(response['group']) ??
        ApiPayloadReader.readMap(response['community']);
  }

  GroupModel _groupFromApiJson(Map<String, dynamic> json) {
    return GroupModel(
      id: ApiPayloadReader.readString(json['id']),
      name: ApiPayloadReader.readString(json['name'], fallback: 'Group'),
      members: ApiPayloadReader.readInt(
        json['memberCount'] ?? json['members'] ?? json['memberTotal'],
      ),
      joined: ApiPayloadReader.readBool(json['joined']) ?? false,
    );
  }
}
