import 'package:flutter/material.dart';

import '../controller/advanced_privacy_controls_controller.dart';

class AdvancedPrivacyControlsScreen extends StatelessWidget {
  AdvancedPrivacyControlsScreen({super.key});

  final AdvancedPrivacyControlsController _controller =
      AdvancedPrivacyControlsController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Advanced Privacy Controls')),
          body: _controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _controller.errorMessage != null && _controller.settings.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_controller.errorMessage!),
                  ),
                )
              : ListView(
                  children: <Widget>[
                    if (_controller.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(_controller.errorMessage!),
                      ),
                    ...List<Widget>.generate(_controller.settings.length, (
                      int index,
                    ) {
                      final item = _controller.settings[index];
                      return SwitchListTile(
                        title: Text(item.title),
                        value: item.value,
                        onChanged: (_) => _controller.toggle(index),
                      );
                    }),
                  ],
                ),
        );
      },
    );
  }
}
