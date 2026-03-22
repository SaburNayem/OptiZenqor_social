import 'package:flutter/material.dart';

import '../../../route/route_names.dart';

class BlockedUsersScreen extends StatelessWidget {
  const BlockedUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blocked Users')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Manage blocked, muted, and restricted accounts.'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.of(context).pushNamed(RouteNames.blockedMutedAccounts),
              child: const Text('Open Blocked & Muted Accounts'),
            ),
          ],
        ),
      ),
    );
  }
}
