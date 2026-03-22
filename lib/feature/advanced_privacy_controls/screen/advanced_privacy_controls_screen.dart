import 'package:flutter/material.dart';

import '../controller/advanced_privacy_controls_controller.dart';

class AdvancedPrivacyControlsScreen extends StatefulWidget {
  const AdvancedPrivacyControlsScreen({super.key});

  @override
  State<AdvancedPrivacyControlsScreen> createState() =>
      _AdvancedPrivacyControlsScreenState();
}

class _AdvancedPrivacyControlsScreenState
    extends State<AdvancedPrivacyControlsScreen> {
  final AdvancedPrivacyControlsController _controller =
      AdvancedPrivacyControlsController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Advanced Privacy Controls')),
          body: ListView.builder(
            itemCount: _controller.settings.length,
            itemBuilder: (context, index) {
              final item = _controller.settings[index];
              return SwitchListTile(
                title: Text(item.title),
                value: item.value,
                onChanged: (_) => _controller.toggle(index),
              );
            },
          ),
        );
      },
    );
  }
}
