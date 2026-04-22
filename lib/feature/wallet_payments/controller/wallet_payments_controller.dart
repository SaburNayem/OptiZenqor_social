import 'package:flutter/foundation.dart';

import '../model/wallet_transaction_model.dart';
import '../repository/wallet_payments_repository.dart';

class WalletPaymentsController extends ChangeNotifier {
  WalletPaymentsController({WalletPaymentsRepository? repository})
      : _repository = repository ?? WalletPaymentsRepository();

  final WalletPaymentsRepository _repository;

  double balance = 0;
  List<WalletTransactionModel> history = <WalletTransactionModel>[];

  void load() {
    balance = _repository.balance();
    history = _repository.history();
    notifyListeners();
  }
}
