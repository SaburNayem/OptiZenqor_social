import 'package:flutter/material.dart';

import '../controller/activity_sessions_controller.dart';

class ActivitySessionsScreen extends StatelessWidget {
  const ActivitySessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ActivitySessionsController();

    return Scaffold(
      appBar: AppBar(title: const Text('Activity & Sessions')),
      body: ListView(
        children: [
          const ListTile(
            title: Text('Recent devices'),
            subtitle: Text('MacBook Pro • iPhone 15 Pro • Pixel 8'),
          ),
          ...controller.activities.map((item) => ListTile(title: Text(item))),
        ],
      ),
    );
  }
}
