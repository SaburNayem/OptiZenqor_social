import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/poll_model.dart';
import '../service/polls_surveys_service.dart';

class PollsSurveysPayload {
  const PollsSurveysPayload({
    required this.activeEntries,
    required this.draftEntries,
    required this.quickTemplates,
  });

  final List<PollModel> activeEntries;
  final List<PollModel> draftEntries;
  final List<String> quickTemplates;
}

class PollsSurveysRepository {
  PollsSurveysRepository({PollsSurveysService? service})
    : _service = service ?? PollsSurveysService();

  final PollsSurveysService _service;

  Future<PollsSurveysPayload> load() async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .getEndpoint('polls_surveys');
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to load polls and surveys.');
    }

    final Map<String, dynamic> payload =
        ApiPayloadReader.readMap(response.data['data']) ?? response.data;
    return PollsSurveysPayload(
      activeEntries:
          ApiPayloadReader.readMapList(
                payload,
                preferredKeys: const <String>['activeEntries'],
              )
              .map(_pollFromApiJson)
              .where((item) => item.id.isNotEmpty)
              .toList(growable: false),
      draftEntries:
          ApiPayloadReader.readMapList(
                payload,
                preferredKeys: const <String>['draftEntries'],
              )
              .map(_pollFromApiJson)
              .where((item) => item.id.isNotEmpty)
              .toList(growable: false),
      quickTemplates: ApiPayloadReader.readStringList(
        payload['quickTemplates'],
      ),
    );
  }

  Future<PollModel> vote(String id, int optionIndex) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .patch(
          _service.endpoints['vote']!.replaceFirst(':id', id),
          <String, dynamic>{'optionIndex': optionIndex},
        );
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to record your vote.');
    }

    final Map<String, dynamic>? payload =
        ApiPayloadReader.readMap(response.data['item']) ??
        ApiPayloadReader.readMap(response.data['poll']) ??
        ApiPayloadReader.readMap(response.data['data']);
    if (payload == null || payload.isEmpty) {
      throw Exception(
        'Vote was recorded but no updated poll payload was returned.',
      );
    }

    return _pollFromApiJson(payload);
  }

  PollModel _pollFromApiJson(Map<String, dynamic> json) {
    final String typeValue = ApiPayloadReader.readString(
      json['type'],
      fallback: 'poll',
    );
    return PollModel(
      id: ApiPayloadReader.readString(json['id']),
      title: ApiPayloadReader.readString(json['title'], fallback: 'Poll'),
      question: ApiPayloadReader.readString(
        json['question'],
        fallback: 'No question provided.',
      ),
      options: ApiPayloadReader.readStringList(json['options']),
      votes: _readVotes(json['votes']),
      type: typeValue.toLowerCase() == 'survey'
          ? PollEntryType.survey
          : PollEntryType.poll,
      statusLabel: ApiPayloadReader.readString(
        json['statusLabel'] ?? json['status'],
        fallback: 'Draft',
      ),
      audienceLabel: ApiPayloadReader.readString(
        json['audienceLabel'] ?? json['audience'],
        fallback: 'Public',
      ),
      endsInLabel: ApiPayloadReader.readString(
        json['endsInLabel'],
        fallback: 'Not scheduled',
      ),
      responseCount: ApiPayloadReader.readInt(json['responseCount']),
      accentHex: ApiPayloadReader.readInt(json['accentHex']),
    );
  }

  List<int> _readVotes(Object? value) {
    if (value is! List) {
      return const <int>[];
    }
    return value.map(ApiPayloadReader.readInt).toList(growable: false);
  }
}
