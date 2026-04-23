import '../../../core/data/api/api_payload_reader.dart';

class WalletTransactionModel {
  const WalletTransactionModel({required this.title, required this.amount, required this.date});
  final String title;
  final double amount;
  final DateTime date;

  factory WalletTransactionModel.fromApiJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      title: ApiPayloadReader.readString(
        json['title'] ?? json['description'] ?? json['type'],
        fallback: 'Transaction',
      ),
      amount: ApiPayloadReader.readDouble(json['amount']),
      date:
          ApiPayloadReader.readDateTime(
            json['date'] ?? json['createdAt'] ?? json['timestamp'],
          ) ??
          DateTime.now(),
    );
  }
}
