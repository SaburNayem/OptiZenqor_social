import 'package:flutter/foundation.dart';

import '../model/account_identity_model.dart';
import '../repository/account_switching_repository.dart';

class AccountSwitchingController extends ChangeNotifier {
  AccountSwitchingController({AccountSwitchingRepository? repository})
    : _repository = repository ?? AccountSwitchingRepository();

  final AccountSwitchingRepository _repository;
  List<AccountIdentityModel> identities = <AccountIdentityModel>[];
  bool isLoading = true;

  int current = 0;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    identities = await _repository.fetchAccounts();
    final activeId = await _repository.readActiveAccountId();
    current = activeId == null
        ? 0
        : identities.indexWhere((account) => account.id == activeId);
    if (current < 0) {
      current = 0;
    }
    if (identities.isNotEmpty) {
      await _repository.setActiveAccount(identities[current].id);
    }
    isLoading = false;
    notifyListeners();
  }

  AccountIdentityModel? get activeAccount {
    if (identities.isEmpty) {
      return null;
    }
    return identities[current];
  }

  List<AccountIdentityModel> get quickSwitchAccounts {
    if (identities.length <= 1) {
      return const <AccountIdentityModel>[];
    }
    return identities
        .where((account) => account.id != activeAccount?.id)
        .take(2)
        .toList();
  }

  Future<void> switchTo(int index) async {
    if (index < 0 || index >= identities.length) {
      return;
    }
    current = index;
    await _repository.setActiveAccount(identities[index].id);
    notifyListeners();
  }
}
