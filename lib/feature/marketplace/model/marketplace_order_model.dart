enum MarketplaceOrderStatus {
  pending,
  confirmed,
  shipped,
  delivered,
  cancelled,
  returned,
}

extension MarketplaceOrderStatusLabel on MarketplaceOrderStatus {
  String get label {
    switch (this) {
      case MarketplaceOrderStatus.pending:
        return 'Pending';
      case MarketplaceOrderStatus.confirmed:
        return 'Confirmed';
      case MarketplaceOrderStatus.shipped:
        return 'Shipped';
      case MarketplaceOrderStatus.delivered:
        return 'Delivered';
      case MarketplaceOrderStatus.cancelled:
        return 'Cancelled';
      case MarketplaceOrderStatus.returned:
        return 'Returned';
    }
  }
}

class MarketplaceOrderModel {
  const MarketplaceOrderModel({
    required this.id,
    required this.productId,
    required this.productTitle,
    required this.amount,
    required this.status,
    required this.address,
    required this.deliveryMethod,
    required this.paymentMethod,
    required this.createdAt,
  });

  final String id;
  final String productId;
  final String productTitle;
  final double amount;
  final MarketplaceOrderStatus status;
  final String address;
  final String deliveryMethod;
  final String paymentMethod;
  final DateTime createdAt;
}
