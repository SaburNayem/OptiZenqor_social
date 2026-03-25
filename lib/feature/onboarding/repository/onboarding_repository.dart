import '../../../core/constants/storage_keys.dart';
import '../../../core/data/shared_preference/app_shared_preferences.dart';

class OnboardingRepository {
  OnboardingRepository({AppSharedPreferences? storage})
    : _storage = storage ?? AppSharedPreferences();

  final AppSharedPreferences _storage;

  Future<bool> isCompleted() async {
    return await _storage.read<bool>(StorageKeys.onboardingDone) ?? false;
  }

  Future<void> complete() {
    return _storage.write(StorageKeys.onboardingDone, true);
  }
}
