import 'package:flutter/material.dart';

import '../controller/deep_link_handler_controller.dart';

class DeepLinkHandlerScreen extends StatelessWidget {
  const DeepLinkHandlerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = DeepLinkHandlerController();

    return Scaffold(
      appBar: AppBar(title: const Text('Deep Link Handler')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(controller.explain('/post/p1')),
          const SizedBox(height: 12),
          const Text('Invite and referral link placeholders are ready.'),
        ],
      ),
    );
  }
}
