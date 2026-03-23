import 'package:flutter/material.dart';

import '../controller/wallet_payments_controller.dart';

class WalletPaymentsScreen extends StatelessWidget {
  WalletPaymentsScreen({super.key}) { _controller.load(); }
  final WalletPaymentsController _controller = WalletPaymentsController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(child: ListTile(title: const Text('Balance'), subtitle: Text('\$${_controller.balance.toStringAsFixed(2)}'))),
            const Card(child: ListTile(title: Tex            const Card(child: ListTile(title: Tex            const Card(child: ListTile(title: Tex            const Card(child: ListTile(title: Tex            const Card(child: ListTile(title:'\$${h.amount.toStringAsFixed(2)}')))),
          ],
        ),
      ),
    );
  }
}
