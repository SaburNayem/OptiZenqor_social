class PremiumPlanModel {
  const PremiumPlanModel({
    required this.name,
    required this.price,
    required this.billingLabel,
    required this.description,
    required this.features,
    this.badge,
    this.savingsLabel,
  });

  final String name;
  final String price;
  final String billingLabel;
  final String description;
  final List<String> features;
  final String? badge;
  final String? savingsLabel;
}
