import 'package:flutter/material.dart';

import '../controller/deep_link_handler_controller.dart';

class DeepLinkHandlerScreen extends StatefulWidget {
  const DeepLinkHandlerScreen({super.key});

  @override
  State<DeepLinkHandlerScreen> createState() => _DeepLinkHandlerScreenState();
}

class _DeepLinkHandlerScreenState extends State<DeepLinkHandlerScreen> {
  final DeepLinkHandlerController _controller = DeepLinkHandlerController();
  final TextEditingController _linkController = TextEditingController(
    text: 'https://optizenqor.app/post/p1',
  );
  String _resolved = 'No route resolved yet';

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deep Link Handler')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(_controller.explain('/post/p1')),
          const SizedBox(height: 12),
          TextField(
            controller: _linkController,
            decoration: const InputDecoration(
              labelText: 'Deep link URL',
              hintText: 'https://optizenqor.app/profile/u1',
            ),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () async {
              final resolved = await _controller.resolve(_linkController.text);
              if (!mounted) {
                return;
              }
              setState(() {
                _resolved = resolved ?? 'Unable to resolve route';
              });
            },
            child: const Text('Resolve link'),
          ),
          const SizedBox(height: 8),
          Text('Resolved route: $_resolved'),
        ],
      ),
    );
  }
}
