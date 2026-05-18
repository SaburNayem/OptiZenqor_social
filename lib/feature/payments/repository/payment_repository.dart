import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/api_client_service.dart';
import '../model/payment_checkout_model.dart';

class PaymentRepository {
  PaymentRepository({ApiClientService? apiClient})
    : _apiClient = apiClient ?? ApiClientService();

  final ApiClientService _apiClient;

  Future<PaymentCheckoutModel> createPayment({
    required String itemType,
    required String title,
    required double amount,
    required String currency,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    String? itemId,
    String? region,
    String? description,
    String? city,
    String? country,
    Map<String, dynamic>? metadata,
  }) async {
    final response = await _apiClient.post(ApiEndPoints.paymentsCreate, {
      'itemType': itemType,
      if (itemId != null && itemId.trim().isNotEmpty) 'itemId': itemId,
      'title': title,
      if (description != null && description.trim().isNotEmpty)
        'description': description,
      'amount': amount,
      'currency': currency,
      if (region != null && region.trim().isNotEmpty) 'region': region,
      'customer': {
        'name': customerName,
        'email': customerEmail,
        'phone': customerPhone,
        if (city != null && city.trim().isNotEmpty) 'city': city,
        if (country != null && country.trim().isNotEmpty) 'country': country,
      },
      ...?(metadata == null ? null : <String, dynamic>{'metadata': metadata}),
    });

    final data = response.data['data'];
    if (!response.isSuccess || data is! Map<String, dynamic>) {
      throw StateError(response.message ?? 'Unable to create payment.');
    }
    return PaymentCheckoutModel.fromJson(data);
  }

  Future<Map<String, dynamic>> getStatus(String paymentId) async {
    final response = await _apiClient.get(ApiEndPoints.paymentStatus(paymentId));
    final data = response.data['data'];
    if (!response.isSuccess || data is! Map<String, dynamic>) {
      throw StateError(response.message ?? 'Unable to fetch payment status.');
    }
    return data;
  }
}
