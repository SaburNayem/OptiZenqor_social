import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/draft_item_model.dart';
import '../service/drafts_and_scheduling_service.dart';

class DraftsAndSchedulingRepository {
  DraftsAndSchedulingRepository({DraftsAndSchedulingService? service})
    : _service = service ?? DraftsAndSchedulingService();

  final DraftsAndSchedulingService _service;

  Future<List<DraftItemModel>> read() async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .get(_service.endpoints['drafts']!);
    _throwIfFailed(
      response,
      fallbackMessage: 'Unable to load drafts and scheduling data.',
    );
    final Map<String, dynamic> payload =
        ApiPayloadReader.readMap(response.data['data']) ?? response.data;
    final List<Map<String, dynamic>> items = ApiPayloadReader.readMapList(
      payload,
      preferredKeys: const <String>['drafts', 'items'],
    );
    return items
        .map(_fromApiJson)
        .where((DraftItemModel item) => item.id.isNotEmpty)
        .toList(growable: false);
  }

  Future<void> write(List<DraftItemModel> drafts) {
    return Future.wait<void>(
      drafts.map((DraftItemModel item) => upsertDraft(item)),
    );
  }

  Future<DraftItemModel> upsertDraft(DraftItemModel draft) async {
    final Map<String, dynamic> payload = <String, dynamic>{
      'title': draft.title,
      'type': draft.type.name,
      'payload': <String, dynamic>{
        'audience': draft.audience,
        if (draft.location != null) 'location': draft.location,
        if (draft.taggedPeople.isNotEmpty) 'taggedPeople': draft.taggedPeople,
        if (draft.coAuthors.isNotEmpty) 'coAuthors': draft.coAuthors,
        if (draft.altText != null) 'altText': draft.altText,
        if (draft.versionHistory.isNotEmpty)
          'versionHistory': draft.versionHistory,
        if (draft.editHistory.isNotEmpty) 'editHistory': draft.editHistory,
      },
      'scheduledAt': draft.scheduledAt?.toIso8601String(),
    };

    final ServiceResponseModel<Map<String, dynamic>> response = draft.id.isEmpty
        ? await _service.apiClient.post(_service.endpoints['drafts']!, payload)
        : await _service.apiClient.patch('/drafts/${draft.id}', payload);
    _throwIfFailed(response, fallbackMessage: 'Unable to save this draft.');
    final Map<String, dynamic>? resolved = ApiPayloadReader.readMap(
      response.data['data'],
    );
    if (resolved == null || resolved.isEmpty) {
      throw StateError('Draft save response was empty.');
    }
    return _fromApiJson(resolved);
  }

  DraftItemModel _fromApiJson(Map<String, dynamic> item) {
    final Map<String, dynamic>? nestedPayload = ApiPayloadReader.readMap(
      item['payload'],
    );
    return DraftItemModel(
      id: ApiPayloadReader.readString(item['id']),
      title: ApiPayloadReader.readString(item['title']),
      type: PublishType.values.firstWhere(
        (PublishType value) =>
            value.name ==
            ApiPayloadReader.readString(item['type'], fallback: 'post'),
        orElse: () => PublishType.post,
      ),
      scheduledAt: ApiPayloadReader.readDateTime(item['scheduledAt']),
      audience: ApiPayloadReader.readString(
        nestedPayload?['audience'],
        fallback: 'Everyone',
      ),
      location: ApiPayloadReader.readString(nestedPayload?['location']),
      taggedPeople: ApiPayloadReader.readStringList(
        nestedPayload?['taggedPeople'],
      ),
      coAuthors: ApiPayloadReader.readStringList(nestedPayload?['coAuthors']),
      altText: ApiPayloadReader.readString(nestedPayload?['altText']),
      versionHistory: ApiPayloadReader.readStringList(
        nestedPayload?['versionHistory'],
      ),
      editHistory: ApiPayloadReader.readStringList(
        nestedPayload?['editHistory'],
      ),
    );
  }

  void _throwIfFailed(
    ServiceResponseModel<Map<String, dynamic>> response, {
    required String fallbackMessage,
  }) {
    if (response.isSuccess && response.data['success'] != false) {
      return;
    }
    throw StateError(
      response.data['message']?.toString().trim().isNotEmpty == true
          ? response.data['message'].toString()
          : fallbackMessage,
    );
  }
}
