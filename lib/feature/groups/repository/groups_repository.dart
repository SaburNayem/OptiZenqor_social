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

    return ApiPayloadReader.readMapList(
          response.data,
          preferredKeys: const <String>['groups', 'items', 'results', 'data'],
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
    final Map<String, dynamic>? payload =
        ApiPayloadReader.readMap(response.data['data']) ??
        ApiPayloadReader.readMap(response.data['community']) ??
        ApiPayloadReader.readMap(response.data['group']) ??
        ApiPayloadReader.readMap(response.data);
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
    final Map<String, dynamic>? payload =
        ApiPayloadReader.readMap(response.data['data']) ??
        ApiPayloadReader.readMap(response.data['community']) ??
        ApiPayloadReader.readMap(response.data['group']) ??
        ApiPayloadReader.readMap(response.data);
    return payload == null ? null : _groupFromApiJson(payload);
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
