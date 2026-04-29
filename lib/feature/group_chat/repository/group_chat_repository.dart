import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/group_chat_model.dart';
import '../service/group_chat_service.dart';

class GroupChatRepository {
  GroupChatRepository({GroupChatService? service})
    : _service = service ?? GroupChatService();

  final GroupChatService _service;

  Future<List<GroupChatModel>> all() async {
    final ServiceResponseModel<Map<String, dynamic>> response =
        await _service.getEndpoint('group_chat');
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to load group chat.');
    }

    return ApiPayloadReader.readMapList(
      response.data,
      preferredKeys: const <String>['groups', 'items', 'results', 'data'],
    ).map(_groupFromApiJson).where((GroupChatModel item) => item.id.isNotEmpty).toList(
      growable: false,
    );
  }

  GroupChatModel _groupFromApiJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? rolesMap = ApiPayloadReader.readMap(json['roles']);
    return GroupChatModel(
      id: ApiPayloadReader.readString(json['id']),
      name: ApiPayloadReader.readString(json['name'], fallback: 'Group chat'),
      members: ApiPayloadReader.readStringList(json['members']),
      roles: rolesMap == null
          ? const <String, String>{}
          : rolesMap.map<String, String>(
              (String key, dynamic value) =>
                  MapEntry(key, value?.toString() ?? ''),
            ),
      media: ApiPayloadReader.readStringList(json['media']),
    );
  }
}
