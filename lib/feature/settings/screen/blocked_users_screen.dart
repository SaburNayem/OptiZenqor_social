import 'package:flutter/material.dart';

import '../../../app_route/route_names.dart';
import '../../blocked_muted_accounts/controller/blocked_muted_accounts_controller.dart';

class BlockedUsersScreen extends StatelessWidget {
  BlockedUsersScreen({super.key}) {
    _controller.load();
  }

  final BlockedMutedAccountsController _controller =
      BlockedMutedAccountsController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Blocked Users')),
          body: _controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manage blocked, muted, and restricted accounts.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 12),
                      Text('Blocked: ${_controller.blocked.length}'),
                      Text('Muted: ${_controller.muted.length}'),
                      Text('Restricted: ${_controller.restricted.length}'),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => Navigator.of(
                          context,
                        ).pushNamed(RouteNames.blockedMutedAccounts),
                        child: const Text('Open Blocked & Muted Accounts'),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

