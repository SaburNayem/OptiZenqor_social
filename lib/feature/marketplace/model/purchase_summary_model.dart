class PurchaseSummaryModel {
  const PurchaseSummaryModel({
    required this.itemId,
    required this.subtotal,
    required this.total,
  });

  final String itemId;
  final double subtotal;
  final double total;
}
