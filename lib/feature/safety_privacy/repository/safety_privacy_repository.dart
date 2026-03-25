import '../../../core/constants/storage_keys.dart';
import '../../../core/data/service/local_storage_service.dart';
import '../model/safety_privacy_model.dart';

class SafetyPrivacyRepository {
  SafetyPrivacyRepository({LocalStorageService? storage})
      : _storage = storage ?? LocalStorageService();

  final LocalStorageService _storage;

  Future<SafetyPrivacyModel> load() async {
    final raw = await _storage.readJson(StorageKeys.settingsState);
    if (raw == null) {
      return const SafetyPrivacyModel();
    }
    return SafetyPrivacyModel(
      isPrivate: raw['isPrivate'] as bool? ?? false,
      hideContentFromUnknown: raw['hideContentFromUnknown'] as bool? ?? false,
      allowMentions: raw['allowMentions'] as bool? ?? true,
    );
  }

  Future<void> save(SafetyPrivacyModel value) {
    return _storage.writeJson(StorageKeys.settingsState, <String, dynamic>{
      'isPrivate': value.isPrivate,
      'hideContentFromUnknown': value.hideContentFromUnknown,
      'allowMentions': value.allowMentions,
    });
  }
}
