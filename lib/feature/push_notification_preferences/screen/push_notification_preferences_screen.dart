import 'package:flutter/material.dart';

import '../../../core/widgets/error_state_view.dart';
import '../controller/push_notification_preferences_controller.dart';

class PushNotificationPreferencesScreen extends StatelessWidget {
  PushNotificationPreferencesScreen({super.key});

  final PushNotificationPreferencesController _controller =
      PushNotificationPreferencesController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Push Preferences')),
          body: Builder(
            builder: (BuildContext context) {
              if (_controller.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_controller.errorMessage != null &&
                  _controller.categories.isEmpty) {
                return ErrorStateView(
                  message:
                      'Unable to load push preferences.\n\n${_controller.errorMessage!}',
                  onRetry: _controller.load,
                );
              }

              return Column(
                children: <Widget>[
                  if (_controller.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _controller.errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _controller.categories.length,
                      itemBuilder: (context, index) {
                        final item = _controller.categories[index];
                        return SwitchListTile(
                          title: Text(item.title),
                          value: item.enabled,
                          onChanged: _controller.isSaving
                              ? null
                              : (_) => _controller.toggle(index),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
