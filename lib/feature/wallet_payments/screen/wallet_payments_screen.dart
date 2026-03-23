import 'package:flutter/material.dart';

import '../controller/wallet_payments_controller.dart';

class WalletPaymentsScreen extends StatelessWidget {
  WalletPaymentsScreen({super.key}) {
    _controller.load();
  }

  final WalletPaymentsController _controller = WalletPaymentsController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Card(
              child: ListTile(
                title: const Text('Balance'),
                subtitle: Text('\$${_controller.balance.toStringAsFixed(2)}'),
              ),
            ),
            const SizedBox(height: 8),
            ..._controller.history.map(
              (transaction) => Card(
                child: ListTile(
                  title: Text(transaction.title),
                  subtitle: Text(transaction.date.toIso8601String().split('T').first),
                  trailing: Text(
                    '${transaction.amount < 0 ? '-' : '+'}\$${transaction.amount.abs().toStringAsFixed(2)}',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
