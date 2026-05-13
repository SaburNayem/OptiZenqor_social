import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../../auth/repository/auth_repository.dart';
import '../model/call_item_model.dart';
import '../service/calls_service.dart';

class CallsRepository {
  CallsRepository({CallsService? service, AuthRepository? authRepository})
    : _service = service ?? CallsService(),
      _authRepository = authRepository ?? AuthRepository();

  final CallsService _service;
  final AuthRepository _authRepository;

  Future<Map<String, dynamic>> fetchRtcConfig() async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .get(_service.endpoints['rtc_config']!);
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to load RTC config.');
    }
    return ApiPayloadReader.requireDataMap(
      response.data,
      fallbackMessage: 'RTC config response did not include a data payload.',
    );
  }

  Future<List<CallItemModel>> load() async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .getEndpoint('calls');
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to load calls.');
    }

    final Map<String, dynamic> data = ApiPayloadReader.requireDataMap(
      response.data,
      fallbackMessage: 'Calls response did not include a data payload.',
    );
    return ApiPayloadReader.readMapList(
          data,
          preferredKeys: const <String>['calls'],
        )
        .map(_callFromApiJson)
        .where((CallItemModel item) => item.id.isNotEmpty)
        .toList(growable: false);
  }

  Future<void> startCall({required String user, required CallType type}) async {
    await startCallSession(recipientId: user, type: type);
  }

  Future<({String sessionId, DateTime? startedAt, String state})>
  startCallSession({
    required String recipientId,
    required CallType type,
  }) async {
    final currentUser = await _authRepository.currentUser();
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .post(_service.endpoints['sessions']!, <String, dynamic>{
          'initiatorId': currentUser?.id ?? '',
          'recipientIds': <String>[recipientId],
          'mode': type == CallType.video ? 'video' : 'voice',
        });
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to start call.');
    }
    final Map<String, dynamic> payload = _readPayload(
      response.data,
      fallbackMessage: 'Call session response was empty.',
    );
    return (
      sessionId: ApiPayloadReader.readString(
        payload['id'] ?? payload['sessionId'] ?? payload['_id'],
      ),
      startedAt: ApiPayloadReader.readDateTime(
        payload['startedAt'] ?? payload['createdAt'] ?? payload['time'],
      ),
      state: ApiPayloadReader.readString(
        payload['state'] ?? payload['status'],
        fallback: 'calling',
      ),
    );
  }

  Future<({String sessionId, DateTime? startedAt, String state})> getSession(
    String sessionId,
  ) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .get(_service.endpoints['session']!.replaceFirst(':id', sessionId));
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to load call session.');
    }
    final Map<String, dynamic> payload = _readPayload(
      response.data,
      fallbackMessage: 'Call session details were empty.',
    );
    return (
      sessionId: ApiPayloadReader.readString(
        payload['id'] ?? payload['sessionId'] ?? payload['_id'],
        fallback: sessionId,
      ),
      startedAt: ApiPayloadReader.readDateTime(
        payload['startedAt'] ?? payload['createdAt'] ?? payload['time'],
      ),
      state: ApiPayloadReader.readString(
        payload['state'] ?? payload['status'],
        fallback: 'calling',
      ),
    );
  }

  Future<void> endCallSession(String sessionId) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .post(
          _service.endpoints['end_session']!.replaceFirst(':id', sessionId),
          const <String, dynamic>{},
        );
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to end call.');
    }
  }

  Future<void> joinCallSession(String sessionId) async {
    final currentUser = await _authRepository.currentUser();
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .post(
          '${_service.endpoints['sessions']!}/$sessionId/join',
          <String, dynamic>{'userId': currentUser?.id ?? ''},
        );
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to join call.');
    }
  }

  Future<void> leaveCallSession(String sessionId) async {
    final currentUser = await _authRepository.currentUser();
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .post(
          '${_service.endpoints['sessions']!}/$sessionId/leave',
          <String, dynamic>{'userId': currentUser?.id ?? ''},
        );
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to leave call.');
    }
  }

  CallItemModel _callFromApiJson(Map<String, dynamic> json) {
    final String typeValue = ApiPayloadReader.readString(json['type']);
    final String stateValue = ApiPayloadReader.readString(
      json['state'] ?? json['status'],
    );
    final DateTime resolvedTime =
        ApiPayloadReader.readDateTime(
          json['time'] ?? json['startedAt'] ?? json['createdAt'],
        ) ??
        DateTime.now();

    return CallItemModel(
      id: ApiPayloadReader.readString(json['id'] ?? json['sessionId']),
      user: ApiPayloadReader.readString(
        json['userLabel'] ?? json['name'] ?? json['username'] ?? json['user'],
      ),
      type: typeValue == 'video' ? CallType.video : CallType.voice,
      state: _stateFromValue(stateValue),
      time: resolvedTime,
    );
  }

  CallState _stateFromValue(String value) {
    switch (value.toLowerCase()) {
      case 'incoming':
      case 'ringing':
        return CallState.incoming;
      case 'outgoing':
      case 'calling':
        return CallState.outgoing;
      case 'missed':
        return CallState.missed;
      case 'completed':
      case 'ended':
      default:
        return CallState.completed;
    }
  }

  Map<String, dynamic> _readPayload(
    Map<String, dynamic> responseData, {
    required String fallbackMessage,
  }) {
    final Map<String, dynamic>? data = ApiPayloadReader.readDataMap(
      responseData,
    );
    final Map<String, dynamic> payload =
        ApiPayloadReader.readMap(data?['session']) ??
        ApiPayloadReader.readMap(data?['call']) ??
        ApiPayloadReader.readMap(data) ??
        ApiPayloadReader.readMap(responseData['session']) ??
        ApiPayloadReader.readMap(responseData['data']) ??
        responseData;
    if (payload.isEmpty) {
      throw StateError(fallbackMessage);
    }
    return payload;
  }
}
