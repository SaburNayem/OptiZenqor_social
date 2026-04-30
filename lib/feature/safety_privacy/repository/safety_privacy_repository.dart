import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/safety_privacy_model.dart';
import '../service/safety_privacy_service.dart';

class SafetyPrivacyRepository {
  SafetyPrivacyRepository({SafetyPrivacyService? service})
    : _service = service ?? SafetyPrivacyService();

  final SafetyPrivacyService _service;

  Future<SafetyPrivacyModel> load() async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .get(_service.endpoints['safety_privacy']!);
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to load safety settings.');
    }

    final Map<String, dynamic> payload =
        ApiPayloadReader.readMap(response.data['data']) ?? response.data;
    return SafetyPrivacyModel(
      isPrivate:
          ApiPayloadReader.readBool(
            payload['isPrivate'] ??
                payload['profilePrivate'] ??
                payload['profileVisibility'],
          ) ??
          false,
      hideContentFromUnknown:
          ApiPayloadReader.readBool(
            payload['hideContentFromUnknown'] ??
                payload['hideSensitive'] ??
                payload['sensitiveContentShield'],
          ) ??
          false,
      allowMentions:
          ApiPayloadReader.readBool(
            payload['allowMentions'] ?? payload['mentionPermissions'],
          ) ??
          true,
    );
  }

  Future<void> save(SafetyPrivacyModel value) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .patch(ApiEndPoints.settingsState, <String, dynamic>{
          'privacy.profile_private': value.isPrivate,
          'privacy.hide_sensitive': value.hideContentFromUnknown,
          'privacy.allow_mentions': value.allowMentions,
        });
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to update safety settings.');
    }
  }
}
