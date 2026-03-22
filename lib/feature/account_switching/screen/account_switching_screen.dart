import 'package:flutter/material.dart';

import '../controller/account_switching_controller.dart';

class AccountSwitchingScreen extends StatefulWidget {
  const AccountSwitchingScreen({super.key});

  @override
  State<AccountSwitchingScreen> createState() => _AccountSwitchingScreenState();
}

class _AccountSwitchingScreenState extends State<AccountSwitchingScreen> {
  final AccountSwitchingController _controller = AccountSwitchingController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Account Switching')),
          body: ListView.builder(
            itemCount: _controller.identities.length,
            itemBuilder: (context, index) {
              final account = _controller.identities[index];
              return ListTile(
                title: Text(account.name),
                subtitle: Text(account.handle),
                trailing: Icon(
                  _controller.current == index
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                ),
                onTap: () => _controller.switchTo(index),
              );
            },
          ),
        );
      },
    );
  }
}
