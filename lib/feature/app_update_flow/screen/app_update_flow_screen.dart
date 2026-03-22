import 'package:flutter/material.dart';

import '../controller/app_update_flow_controller.dart';

class AppUpdateFlowScreen extends StatelessWidget {
  const AppUpdateFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppUpdateFlowController();

    return Scaffold(
      appBar: AppBar(title: const Text('App Update Flow')),
      body: ListTile(
        title: Text(controller.update.type.name),
        subtitle: Text(controller.update.message),
        trailing: FilledButton(onPressed: () {}, child: const Text('Update')),
      ),
    );
  }
}
