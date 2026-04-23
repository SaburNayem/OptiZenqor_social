import '../../../core/data/api/api_payload_reader.dart';

class WalletBalanceModel {
  const WalletBalanceModel({required this.available, required this.pending});

  final double available;
  final double pending;

  factory WalletBalanceModel.fromApiJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        ApiPayloadReader.readMap(json['data']) ?? json;
    return WalletBalanceModel(
      available: ApiPayloadReader.readDouble(
        data['available'] ?? data['balance'],
      ),
      pending: ApiPayloadReader.readDouble(data['pending']),
    );
  }
}
