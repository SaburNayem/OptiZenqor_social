import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/group_model.dart';
import '../service/groups_service.dart';

class GroupsRepository {
  GroupsRepository({GroupsService? service})
    : _service = service ?? GroupsService();

  final GroupsService _service;

  Future<List<GroupModel>> load() async {
    final ServiceResponseModel<Map<String, dynamic>> response =
        await _service.getEndpoint('groups');
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to load groups.');
    }

    return ApiPayloadReader.readMapList(
      response.data,
      preferredKeys: const <String>['groups', 'items', 'results', 'data'],
    ).map(_groupFromApiJson).where((GroupModel item) => item.id.isNotEmpty).toList(
      growable: false,
    );
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
