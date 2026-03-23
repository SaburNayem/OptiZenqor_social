import 'package:flutter/material.dart';

import '../controller/blocked_muted_accounts_controller.dart';

class BlockedMutedAccountsScreen extends StatelessWidget {
  BlockedMutedAccountsScreen({super.key}) {
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
          appBar: AppBar(title: const Text('Blocked & Muted Accounts')),
          body: _controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(
                          label: Text('Blocked ${_controller.blocked.length}'),
                        ),
                        Chip(label: Text('Muted ${_controller.muted.length}')),
                        Chip(
                          label: Text(
                            'Restricted ${_controller.restricted.length}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Blocked',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    if (_controller.blocked.isEmpty)
                      const ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('No blocked users'),
                        subtitle: Text('Blocked accounts will appear here.'),
                      ),
                    ..._controller.blocked.map(
                      (item) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(item.name),
                        subtitle: Text(item.handle),
                        trailing: TextButton(
                          onPressed: () async {
                            await _controller.unblock(item.handle);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    content: Text('Unblocked ${item.handle}'),
                                  ),
                                );
                            }
                          },
                          child: const Text('Unblock'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Muted',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    if (_controller.muted.isEmpty)
                      const ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('No muted users'),
                        subtitle: Text('Muted accounts will appear here.'),
                      ),
                    ..._controller.muted.map(
                      (item) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(item.name),
                        subtitle: Text(item.handle),
                        trailing: TextButton(
                          onPressed: () async {
                            await _controller.unmute(item.handle);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    content: Text('Unmuted ${item.handle}'),
                                  ),
                                );
                            }
                          },
                          child: const Text('Unmute'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Restricted',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    ..._controller.restricted.map(
                      (item) => ListTile(
                        contentPadding: EdgeInsets.zero,
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
