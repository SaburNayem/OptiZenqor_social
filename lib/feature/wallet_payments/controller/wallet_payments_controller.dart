import 'package:flutter/foundation.dart';

import '../model/wallet_transaction_model.dart';
import '../repository/wallet_payments_repository.dart';

class WalletPaymentsController extends ChangeNotifier {
  WalletPaymentsController({WalletPaymentsRepository? repository})
    : _repository = repository ?? WalletPaymentsRepository();

  final WalletPaymentsRepository _repository;

  double balance = 0;
  List<WalletTransactionModel> history = <WalletTransactionModel>[];
  bool isLoading = false;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      balance = await _repository.balance();
      history = await _repository.history();
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      balance = 0;
      history = <WalletTransactionModel>[];
    } finally {
      isLoading = false;
    }
    notifyListeners();
  }
}
