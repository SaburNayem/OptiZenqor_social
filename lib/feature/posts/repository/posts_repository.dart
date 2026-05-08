import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../service/posts_service.dart';

class PostsRepository {
  PostsRepository({PostsService? service})
    : _service = service ?? PostsService();

  final PostsService _service;

  Future<void> saveDraft(Map<String, dynamic> draft) async {
    final String id = (draft['id'] as String? ?? '').trim();
    final Map<String, dynamic> payload = <String, dynamic>{
      'title': (draft['title'] as String? ?? '').trim(),
      'type': (draft['type'] as String? ?? 'post').trim(),
      'payload': <String, dynamic>{
        if ((draft['caption'] as String?)?.trim().isNotEmpty == true)
          'caption': (draft['caption'] as String).trim(),
      },
      if (draft['scheduledAt'] != null) 'scheduledAt': draft['scheduledAt'],
    };

    final ServiceResponseModel<Map<String, dynamic>> response = id.isEmpty
        ? await _service.apiClient.post('/drafts', payload)
        : await _service.apiClient.patch('/drafts/$id', payload);
    _throwIfFailed(response, fallbackMessage: 'Unable to save this draft.');
  }

  Future<List<Map<String, dynamic>>> getDrafts() async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .get('/drafts');
    _throwIfFailed(response, fallbackMessage: 'Unable to load drafts.');
    final Map<String, dynamic> payload =
        ApiPayloadReader.readMap(response.data['data']) ?? response.data;
    final List<Map<String, dynamic>> items = ApiPayloadReader.readMapList(
      payload,
      preferredKeys: const <String>['drafts', 'items'],
    );
    return items
        .map(_toPostDraftMap)
        .where((Map<String, dynamic> item) => (item['id'] as String).isNotEmpty)
        .toList(growable: false);
  }

  Future<void> deleteDraft(String id) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .delete('/drafts/$id');
    _throwIfFailed(response, fallbackMessage: 'Unable to delete this draft.');
  }

  Map<String, dynamic> _toPostDraftMap(Map<String, dynamic> item) {
    final Map<String, dynamic>? nestedPayload = ApiPayloadReader.readMap(
      item['payload'],
    );
    return <String, dynamic>{
      'id': ApiPayloadReader.readString(item['id']),
      'title': ApiPayloadReader.readString(
        item['title'],
        fallback: 'Untitled draft',
      ),
      'createdAt': ApiPayloadReader.readString(
        item['updatedAt'] ?? item['createdAt'],
        fallback: DateTime.now().toIso8601String(),
      ),
      'caption': ApiPayloadReader.readString(
        nestedPayload?['caption'] ?? item['caption'],
      ),
      'type': ApiPayloadReader.readString(item['type'], fallback: 'post'),
      'scheduledAt': ApiPayloadReader.readString(item['scheduledAt']),
    };
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
