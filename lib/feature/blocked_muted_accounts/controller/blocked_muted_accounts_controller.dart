import '../model/restricted_account_model.dart';

class BlockedMutedAccountsController {
  final List<RestrictedAccountModel> blocked = const [
    RestrictedAccountModel(
      name: 'Sample User',
      handle: '@sample.user',
      status: 'blocked',
    ),
  ];

  final List<RestrictedAccountModel> muted = const [
    RestrictedAccountModel(
      name: 'Muted Creator',
      handle: '@muted.creator',
      status: 'muted',
    ),
  ];

  final List<RestrictedAccountModel> restricted = const [
    RestrictedAccountModel(
      name: 'Restricted Account',
      handle: '@restricted.account',
      status: 'restricted',
    ),
  ];
}
