import '../../../core/data/api/api_payload_reader.dart';

class SubscriptionPlanModel {
  const SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.price,
  });
  final String id;
  final String name;
  final double price;

  factory SubscriptionPlanModel.fromApiJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: ApiPayloadReader.readString(json['id']),
      name: ApiPayloadReader.readString(json['name'], fallback: 'Plan'),
      price: ApiPayloadReader.readDouble(
        json['price'] ?? json['amount'] ?? json['monthlyPrice'],
      ),
    );
  }
}
