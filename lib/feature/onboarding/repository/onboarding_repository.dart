import '../../../core/constants/storage_keys.dart';
import '../../../core/services/local_storage_service.dart';

class OnboardingRepository {
  OnboardingRepository({LocalStorageService? storage})
    : _storage = storage ?? LocalStorageService();

  final LocalStorageService _storage;

  Future<bool> isCompleted() async {
    return await _storage.read<bool>(StorageKeys.onboardingDone) ?? false;
  }

  Future<void> complete() {
    return _storage.write(StorageKeys.onboardingDone, true);
  }
}
