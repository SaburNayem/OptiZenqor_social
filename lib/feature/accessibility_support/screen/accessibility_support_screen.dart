import 'package:flutter/material.dart';

import '../controller/accessibility_support_controller.dart';

class AccessibilitySupportScreen extends StatefulWidget {
  const AccessibilitySupportScreen({super.key});

  @override
  State<AccessibilitySupportScreen> createState() =>
      _AccessibilitySupportScreenState();
}

class _AccessibilitySupportScreenState extends State<AccessibilitySupportScreen> {
  final AccessibilitySupportController _controller =
      AccessibilitySupportController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Accessibility Support')),
          body: ListView.builder(
            itemCount: _controller.options.length,
            itemBuilder: (context, index) {
              final option = _controller.options[index];
              return SwitchListTile(
                title: Text(option.title),
                value: option.enabled,
                onChanged: (_) => _controller.toggle(index),
              );
            },
          ),
        );
      },
    );
  }
}
