import 'package:flutter/material.dart';

import '../controller/share_repost_system_controller.dart';

class ShareRepostSystemScreen extends StatelessWidget {
  const ShareRepostSystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ShareRepostSystemController();

    return Scaffold(
      appBar: AppBar(title: const Text('Share & Repost')),
      body: ListView(
        children: controller.options
            .map(
              (option) => ListTile(
                title: Text(option),
                trailing: const Icon(Icons.chevron_right),
              ),
            )
            .toList(),
      ),
    );
  }
}
