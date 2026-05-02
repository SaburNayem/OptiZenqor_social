import '../../../core/data/api/api_payload_reader.dart';

class PremiumPlanModel {
  const PremiumPlanModel({
    required this.id,
    required this.code,
    required this.name,
    required this.price,
    required this.currency,
    required this.billingInterval,
    required this.description,
    required this.features,
    this.isActive = true,
  });

  final String id;
  final String code;
  final String name;
  final double price;
  final String currency;
  final String billingInterval;
  final String description;
  final List<String> features;
  final bool isActive;

  String get priceLabel =>
      '$currency ${price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 2)}';

  String get billingLabel {
    switch (billingInterval.toLowerCase()) {
      case 'yearly':
      case 'annual':
        return 'per year';
      case 'weekly':
        return 'per week';
      case 'daily':
        return 'per day';
      case 'lifetime':
        return 'one-time';
      case 'monthly':
      default:
        return 'per month';
    }
  }

  factory PremiumPlanModel.fromApiJson(Map<String, dynamic> json) {
    return PremiumPlanModel(
      id: ApiPayloadReader.readString(json['id']),
      code: ApiPayloadReader.readString(
        json['code'],
        fallback: ApiPayloadReader.readString(json['name']),
      ),
      name: ApiPayloadReader.readString(json['name'], fallback: 'Plan'),
      price: ApiPayloadReader.readDouble(
        json['price'] ?? json['amount'] ?? json['monthlyPrice'],
      ),
      currency: ApiPayloadReader.readString(json['currency'], fallback: 'BDT'),
      billingInterval: ApiPayloadReader.readString(
        json['billingInterval'],
        fallback: 'monthly',
      ),
      description: ApiPayloadReader.readString(
        json['description'],
        fallback: 'Subscription plan',
      ),
      features: ApiPayloadReader.readStringList(json['features']),
      isActive: ApiPayloadReader.readBool(json['isActive']) ?? true,
    );
  }
}
