import 'package:flutter/material.dart';

import '../controller/blocked_muted_accounts_controller.dart';

class BlockedMutedAccountsScreen extends StatelessWidget {
  const BlockedMutedAccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = BlockedMutedAccountsController();

    return Scaffold(
      appBar: AppBar(title: const Text('Blocked & Muted Accounts')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Blocked', style: TextStyle(fontWeight: FontWeight.w700)),
          ...controller.blocked.map(
            (item) => ListTile(
              title: Text(item.name),
              subtitle: Text(item.handle),
              trailing: TextButton(onPressed: () {}, child: const Text('Unblock')),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Muted', style: TextStyle(fontWeight: FontWeight.w700)),
          ...controller.muted.map(
            (item) => ListTile(
              title: Text(item.name),
              subtitle: Text(item.handle),
              trailing: TextButton(onPressed: () {}, child: const Text('Unmute')),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Restricted', style: TextStyle(fontWeight: FontWeight.w700)),
          ...controller.restricted.map(
            (item) => ListTile(
              title: Text(item.name),
              subtitle: Text(item.handle),
            ),
          ),
        ],
      ),
    );
  }
}
