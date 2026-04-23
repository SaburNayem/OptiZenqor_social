import 'package:flutter/foundation.dart';

import '../model/restricted_account_model.dart';
import '../repository/blocked_muted_accounts_repository.dart';

class BlockedMutedAccountsController extends ChangeNotifier {
  BlockedMutedAccountsController({BlockedMutedAccountsRepository? repository})
    : _repository = repository ?? BlockedMutedAccountsRepository();

  final BlockedMutedAccountsRepository _repository;
  bool isLoading = true;
  List<RestrictedAccountModel> blocked = <RestrictedAccountModel>[];
  List<RestrictedAccountModel> muted = <RestrictedAccountModel>[];

  final List<RestrictedAccountModel> restricted = const [
    RestrictedAccountModel(
      id: 'r1',
      name: 'Restricted Account',
      handle: '@restricted.account',
      status: 'restricted',
    ),
  ];

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    blocked = await _repository.loadBlocked();
    muted = await _repository.loadMuted();
    isLoading = false;
    notifyListeners();
  }

  Future<void> unblock(String handle) async {
    final RestrictedAccountModel? account = blocked
        .where((RestrictedAccountModel item) => item.handle == handle)
        .cast<RestrictedAccountModel?>()
        .firstOrNull;
    if (account != null) {
      await _repository.unblockAccount(account.id);
    }
    blocked = blocked.where((item) => item.handle != handle).toList();
    await _repository.saveBlocked(blocked);
    notifyListeners();
  }

  Future<void> unmute(String handle) async {
    muted = muted.where((item) => item.handle != handle).toList();
    await _repository.saveMuted(muted);
    notifyListeners();
  }
}
