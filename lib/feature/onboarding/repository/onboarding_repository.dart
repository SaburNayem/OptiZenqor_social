import '../../../core/constants/storage_keys.dart';
import '../../../core/data/shared_preference/app_shared_preferences.dart';
import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/onboarding_slide_model.dart';
import '../service/onboarding_service.dart';

class OnboardingRepository {
  OnboardingRepository({
    AppSharedPreferences? storage,
    OnboardingService? service,
  }) : _storage = storage ?? AppSharedPreferences(),
       _service = service ?? OnboardingService();

  final AppSharedPreferences _storage;
  final OnboardingService _service;

  Future<bool> isCompleted() async {
    try {
      final ServiceResponseModel<Map<String, dynamic>> response = await _service
          .apiClient
          .get(_service.endpoints['state']!);
      if (response.isSuccess && response.data['success'] != false) {
        final Map<String, dynamic>? payload = _unwrapPayload(response.data);
        final bool completed =
            ApiPayloadReader.readBool(payload?['completed']) ?? false;
        if (completed) {
          await _storage.write(StorageKeys.onboardingDone, true);
        }
        return completed ||
            (await _storage.read<bool>(StorageKeys.onboardingDone) ?? false);
      }
    } catch (_) {}
    return await _storage.read<bool>(StorageKeys.onboardingDone) ?? false;
  }

  Future<List<OnboardingSlideModel>> loadSlides() async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .get(_service.endpoints['slides']!);
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to load onboarding slides.');
    }
    final Map<String, dynamic>? payload = _unwrapPayload(response.data);
    final List<Map<String, dynamic>> items =
        ApiPayloadReader.readMapListFromAny(
          payload?['slides'] ?? payload?['items'] ?? payload ?? response.data,
          preferredKeys: const <String>['slides', 'items'],
        );
    return items
        .map(OnboardingSlideModel.fromApiJson)
        .where((OnboardingSlideModel item) => item.title.isNotEmpty)
        .toList(growable: false);
  }

  Future<void> complete({
    List<String> selectedInterests = const <String>[],
  }) async {
    try {
      await _service.apiClient.post(
        _service.endpoints['complete']!,
        <String, dynamic>{'selectedInterests': selectedInterests},
      );
    } finally {
      await _storage.write(StorageKeys.onboardingDone, true);
    }
  }

  Map<String, dynamic>? _unwrapPayload(Map<String, dynamic> payload) {
    return ApiPayloadReader.readMap(payload['data']) ??
        ApiPayloadReader.readMap(payload['result']) ??
        payload;
  }
}
