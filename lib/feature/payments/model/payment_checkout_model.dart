class PaymentCheckoutModel {
  const PaymentCheckoutModel({
    required this.paymentId,
    required this.orderId,
    required this.gateway,
    required this.status,
    required this.amount,
    required this.currency,
    required this.checkoutUrl,
  });

  final String paymentId;
  final String orderId;
  final String gateway;
  final String status;
  final double amount;
  final String currency;
  final String checkoutUrl;

  factory PaymentCheckoutModel.fromJson(Map<String, dynamic> json) {
    return PaymentCheckoutModel(
      paymentId: json['paymentId']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? '',
      gateway: json['gateway']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      amount: (num.tryParse(json['amount']?.toString() ?? '') ?? 0).toDouble(),
      currency: json['currency']?.toString() ?? '',
      checkoutUrl: json['checkoutUrl']?.toString() ?? '',
    );
  }
}
