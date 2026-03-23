import '../../../core/constants/storage_keys.dart';
import '../../../core/services/local_storage_service.dart';
import '../model/verification_request_model.dart';

class VerificationRequestRepository {
  VerificationRequestRepository({LocalStorageService? storage})
    : _storage = storage ?? LocalStorageService();

  final LocalStorageService _storage;

  static const VerificationRequestModel _seed = VerificationRequestModel(
    status: VerificationStatus.notRequested,
    reason: 'Submit creator or business documents to start review.',
    selectedDocuments: <String>[],
  );

  Future<VerificationRequestModel> load() async {
    final raw = await _storage.readJson(StorageKeys.verificationRequest);
    if (raw == null) {
      return _seed;
    }
    return VerificationRequestModel.fromJson(raw);
  }

  Future<void> save(VerificationRequestModel model) {
    return _storage.writeJson(StorageKeys.verificationRequest, model.toJson());
  }
}
