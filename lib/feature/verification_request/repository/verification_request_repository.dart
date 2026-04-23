import '../../../core/constants/storage_keys.dart';
import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service/local_storage_service.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/verification_request_model.dart';
import '../service/verification_request_service.dart';

class VerificationRequestRepository {
  VerificationRequestRepository({
    LocalStorageService? storage,
    VerificationRequestService? service,
  }) : _storage = storage ?? LocalStorageService(),
       _service = service ?? VerificationRequestService();

  final LocalStorageService _storage;
  final VerificationRequestService _service;

  static const VerificationRequestModel _seed = VerificationRequestModel(
    status: VerificationStatus.notRequested,
    reason: 'Submit creator or business documents to start review.',
    selectedDocuments: <String>[],
  );

  Future<VerificationRequestModel> load() async {
    final VerificationRequestModel? remote = await _loadFromApi();
    if (remote != null) {
      await save(remote);
      return remote;
    }

    final raw = await _storage.readJson(StorageKeys.verificationRequest);
    if (raw == null) {
      return _seed;
    }
    return VerificationRequestModel.fromJson(raw);
  }

  Future<void> save(VerificationRequestModel model) {
    return _storage.writeJson(StorageKeys.verificationRequest, model.toJson());
  }

  Future<List<String>?> loadRequiredDocuments() async {
    try {
      final ServiceResponseModel<Map<String, dynamic>> response =
          await _service.getEndpoint('documents');
      if (!response.isSuccess || response.data['success'] == false) {
        return null;
      }
      final List<String> documents = ApiPayloadReader.readStringList(
        response.data['documents'] ??
            response.data['data'] ??
            response.data['items'],
      );
      return documents.isEmpty ? null : documents;
    } catch (_) {
      return null;
    }
  }

  Future<VerificationRequestModel> submit(
    VerificationRequestModel model,
  ) async {
    try {
      final ServiceResponseModel<Map<String, dynamic>> response =
          await _service.postEndpoint(
            'submit',
            payload: <String, dynamic>{
              'documents': model.selectedDocuments,
            },
          );
      if (response.isSuccess && response.data['success'] != false) {
        final VerificationRequestModel resolved =
            VerificationRequestModel.fromApiJson(response.data);
        await save(resolved);
        return resolved;
      }
    } catch (_) {}

    final VerificationRequestModel pendingModel = model.copyWith(
      status: VerificationStatus.pending,
      reason: 'Documents uploaded. Under review.',
      submittedAt: DateTime.now(),
    );
    await save(pendingModel);
    return pendingModel;
  }

  Future<VerificationRequestModel?> _loadFromApi() async {
    for (final String key in <String>['status', 'verification_request']) {
      try {
        final ServiceResponseModel<Map<String, dynamic>> response =
            await _service.getEndpoint(key);
        if (!response.isSuccess || response.data['success'] == false) {
          continue;
        }
        return VerificationRequestModel.fromApiJson(response.data);
      } catch (_) {}
    }
    return null;
  }
}
