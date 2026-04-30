import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/group_chat_model.dart';
import '../service/group_chat_service.dart';

class GroupChatRepository {
  GroupChatRepository({GroupChatService? service})
    : _service = service ?? GroupChatService();

  final GroupChatService _service;

  Future<List<GroupChatModel>> all() async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .getEndpoint('group_chat');
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to load group chat.');
    }

    return ApiPayloadReader.readMapList(
          response.data,
          preferredKeys: const <String>['groups', 'items', 'results', 'data'],
        )
        .map(_groupFromApiJson)
        .where((GroupChatModel item) => item.id.isNotEmpty)
        .toList(growable: false);
  }

  Future<GroupChatModel> createGroup(String name) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .postEndpoint(
          'group_chat_create',
          payload: <String, dynamic>{'name': name},
        );
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to create group chat.');
    }
    return _groupFromApiJson(_readGroupPayload(response.data));
  }

  Future<GroupChatModel> addMember(
    String groupId,
    String userIdOrUsername,
  ) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .postEndpoint(
          ApiEndPoints.groupChatMembers(groupId),
          payload: <String, dynamic>{'username': userIdOrUsername},
        );
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to add group member.');
    }
    return _groupFromApiJson(_readGroupPayload(response.data));
  }

  Future<GroupChatModel> removeMember(
    String groupId,
    String userIdOrUsername,
  ) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .deleteEndpoint(
          ApiEndPoints.groupChatMember(groupId, userIdOrUsername),
        );
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to remove group member.');
    }
    return _groupFromApiJson(_readGroupPayload(response.data));
  }

  Map<String, dynamic> _readGroupPayload(Map<String, dynamic> response) {
    return ApiPayloadReader.readMap(response['group']) ??
        ApiPayloadReader.readMap(response['data']) ??
        response;
  }

  GroupChatModel _groupFromApiJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? rolesMap = ApiPayloadReader.readMap(
      json['roles'],
    );
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
