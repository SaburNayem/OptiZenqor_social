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

  Future<List<CallItemModel>> load() async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .getEndpoint('calls');
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to load calls.');
    }

    return ApiPayloadReader.readMapList(
          response.data,
          preferredKeys: const <String>['calls', 'items', 'results', 'data'],
        )
        .map(_callFromApiJson)
        .where((CallItemModel item) => item.id.isNotEmpty)
        .toList(growable: false);
  }

  Future<void> startCall({required String user, required CallType type}) async {
    final currentUser = await _authRepository.currentUser();
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .post(_service.endpoints['sessions']!, <String, dynamic>{
          'initiatorId': currentUser?.id ?? '',
          'recipientIds': const <String>[],
          'mode': type == CallType.video ? 'video' : 'voice',
        });
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to start call.');
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
        json['user'] ?? json['username'] ?? json['name'],
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
}
