import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/business_profile_model.dart';
import '../service/business_profile_service.dart';

class BusinessProfileRepository {
  BusinessProfileRepository({BusinessProfileService? service})
    : _service = service ?? BusinessProfileService();

  final BusinessProfileService _service;

  Future<BusinessProfileModel> load() async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .getEndpoint('business_profile');
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to load business profile.');
    }

    final Map<String, dynamic> payload =
        ApiPayloadReader.readMap(response.data['data']) ?? response.data;
    final List<String> highlights = ApiPayloadReader.readStringList(
      payload['highlights'],
    );
    return BusinessProfileModel(
      name: ApiPayloadReader.readString(
        payload['companyName'] ?? payload['name'],
      ),
      info: ApiPayloadReader.readString(
        payload['about'] ?? payload['category'],
      ),
      analyticsSummary: highlights.join(' | '),
    );
  }
}
