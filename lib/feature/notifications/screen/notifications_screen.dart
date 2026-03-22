import 'package:flutter/material.dart';

import '../../../core/helpers/format_helper.dart';
import '../controller/notifications_controller.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationsController _controller = NotificationsController();

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_controller.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _controller.notifications.length,
          itemBuilder: (_, index) {
            final item = _controller.notifications[index];
            return Card(
              child: ListTile(
                leading: Icon(
                  item.unread ? Icons.notifications_active : Icons.notifications,
                ),
                title: Text(item.title),
                subtitle: Text(item.body),
                trailing: Text(FormatHelper.timeAgo(item.createdAt)),
              ),
            );
          },
        );
      },
    );
  }
}
