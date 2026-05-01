import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/invite_referral_model.dart';
import '../service/invite_referral_service.dart';

class InviteReferralRepository {
  InviteReferralRepository({InviteReferralService? service})
    : _service = service ?? InviteReferralService();

  final InviteReferralService _service;

  Future<InviteReferralModel> load() async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .get(_service.endpoints['invite_referral']!);
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(
        response.message ?? 'Unable to load invite referral data.',
      );
    }
    final Map<String, dynamic> payload =
        ApiPayloadReader.readMap(response.data['data']) ?? response.data;
    return InviteReferralModel.fromApiJson(payload);
  }
}
