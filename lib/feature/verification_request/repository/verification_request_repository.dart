import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/verification_request_model.dart';
import '../service/verification_request_service.dart';

class VerificationRequestRepository {
  VerificationRequestRepository({VerificationRequestService? service})
    : _service = service ?? VerificationRequestService();

  final VerificationRequestService _service;

  Future<VerificationRequestModel> load() async {
    return _loadFromApi();
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
    final ServiceResponseModel<Map<String, dynamic>> response =
        await _service.postEndpoint(
      'submit',
      payload: <String, dynamic>{
        'documents': model.selectedDocuments,
      },
    );
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to submit verification.');
    }
    return VerificationRequestModel.fromApiJson(response.data);
  }

  Future<VerificationRequestModel> _loadFromApi() async {
    for (final String key in <String>['status', 'verification_request']) {
      final ServiceResponseModel<Map<String, dynamic>> response =
          await _service.getEndpoint(key);
      if (!response.isSuccess || response.data['success'] == false) {
        continue;
      }
      return VerificationRequestModel.fromApiJson(response.data);
    }
    return const VerificationRequestModel(
      status: VerificationStatus.notRequested,
      reason: '',
      selectedDocuments: <String>[],
      requiredDocuments: <String>[],
    );
  }
}
