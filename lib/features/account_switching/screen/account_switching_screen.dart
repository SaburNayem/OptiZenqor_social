import 'package:flutter/material.dart';

import '../controller/account_switching_controller.dart';

class AccountSwitchingScreen extends StatelessWidget {
  AccountSwitchingScreen({super.key}) {
    _controller.load();
  }

  final AccountSwitchingController _controller = AccountSwitchingController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Account Switching')),
          body: _controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person_rounded),
                        ),
                        title: Text(
                          _controller.activeAccount?.name ??
                              'No active account',
                        ),
                        subtitle: Text(
                          _controller.activeAccount == null
                              ? 'Link accounts to switch faster'
                              : '${_controller.activeAccount!.handle} • ${_controller.activeAccount!.roleLabel}',
                        ),
                        trailing: const Chip(label: Text('Active')),
                      ),
                    ),
                    if (_controller.quickSwitchAccounts.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Quick switch',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _controller.quickSwitchAccounts.map((
                          account,
                        ) {
                          final index = _controller.identities.indexOf(account);
                          return ActionChip(
                            avatar: Icon(
                              account.isVerified
                                  ? Icons.verified_rounded
                                  : Icons.person_outline,
                              size: 18,
                            ),
                            label: Text(account.handle),
                            onPressed: () async {
                              await _controller.switchTo(index);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Switched to ${account.handle}',
                                      ),
                                    ),
                                  );
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      'Linked accounts',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(_controller.identities.length, (index) {
                      final account = _controller.identities[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          child: Text(
                            account.name.isEmpty ? '?' : account.name[0],
                          ),
                        ),
                        title: Row(
                          children: [
                            Flexible(child: Text(account.name)),
                            if (account.isVerified) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.verified_rounded, size: 18),
                            ],
                          ],
                        ),
                        subtitle: Text(
                          '${account.handle} • ${account.roleLabel}',
                        ),
                        trailing: Icon(
                          _controller.current == index
                              ? Icons.check_circle
                              : Icons.swap_horiz_rounded,
                        ),
                        onTap: () => _controller.switchTo(index),
                      );
                    }),
                  ],
                ),
        );
      },
    );
  }
}
