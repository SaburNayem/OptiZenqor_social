import 'package:flutter/material.dart';

import '../controller/accessibility_support_controller.dart';

class AccessibilitySupportScreen extends StatelessWidget {
  AccessibilitySupportScreen({super.key});

  final AccessibilitySupportController _controller =
      AccessibilitySupportController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Accessibility Support')),
          body: _controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _controller.errorMessage != null && _controller.options.isEmpty
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
                    ...List<Widget>.generate(_controller.options.length, (
                      int index,
                    ) {
                      final option = _controller.options[index];
                      return SwitchListTile(
                        title: Text(option.title),
                        value: option.enabled,
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
