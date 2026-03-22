import 'package:flutter/material.dart';

import '../controller/blocked_muted_accounts_controller.dart';

class BlockedMutedAccountsScreen extends StatelessWidget {
  BlockedMutedAccountsScreen({super.key});

  final BlockedMutedAccountsController _controller =
      BlockedMutedAccountsController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Blocked & Muted Accounts')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Blocked', style: TextStyle(fontWeight: FontWeight.w700)),
              ..._controller.blocked.map(
                (item) => ListTile(
                  title: Text(item.name),
                  subtitle: Text(item.handle),
                  trailing: TextButton(
                    onPressed: () {
                      _controller.unblock(item.handle);
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(content: Text('Unblocked ${item.handle}')),
                        );
                    },
                    child: const Text('Unblock'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Muted', style: TextStyle(fontWeight: FontWeight.w700)),
              ..._controller.muted.map(
                (item) => ListTile(
                  title: Text(item.name),
                  subtitle: Text(item.handle),
                  trailing: TextButton(
                    onPressed: () {
                      _controller.unmute(item.handle);
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(content: Text('Unmuted ${item.handle}')),
                        );
                    },
                    child: const Text('Unmute'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Restricted', style: TextStyle(fontWeight: FontWeight.w700)),
              ..._controller.restricted.map(
                (item) => ListTile(
                  title: Text(item.name),
                  subtitle: Text(item.handle),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
