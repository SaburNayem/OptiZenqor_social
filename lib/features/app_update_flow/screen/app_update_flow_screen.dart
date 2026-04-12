import 'package:flutter/material.dart';

import '../controller/app_update_flow_controller.dart';

class AppUpdateFlowScreen extends StatelessWidget {
  AppUpdateFlowScreen({super.key});

  final AppUpdateFlowController _controller = AppUpdateFlowController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('App Update Flow')),
          body: ListTile(
            title: Text(_controller.update.type.name),
            subtitle: Text(_controller.update.message),
            trailing: FilledButton(
              onPressed: _controller.isUpdating
                  ? null
                  : () async {
                      await _controller.startUpdate();
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(content: Text('App is up to date.')),
                        );
                    },
              child: Text(_controller.isUpdating ? 'Updating...' : 'Update'),
            ),
          ),
        );
      },
    );
  }
}
