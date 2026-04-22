import '../model/wallet_transaction_model.dart';

class WalletPaymentsRepository {
  double balance() => 245.75;

  List<WalletTransactionModel> history() {
    return <WalletTransactionModel>[
      WalletTransactionModel(
        title: 'Subscription payout',
        amount: 89.00,
        date: DateTime(2026, 3, 20),
      ),
      WalletTransactionModel(
        title: 'Marketplace sale',
        amount: 120.50,
        date: DateTime(2026, 3, 18),
      ),
      WalletTransactionModel(
        title: 'Boost campaign',
        amount: -35.25,
        date: DateTime(2026, 3, 16),
      ),
    ];
  }
}
