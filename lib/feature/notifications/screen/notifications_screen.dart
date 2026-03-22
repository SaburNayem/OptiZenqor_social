import 'package:flutter/material.dart';

import '../../../core/helpers/format_helper.dart';
import '../../../core/widgets/error_state_view.dart';
import '../controller/notifications_controller.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

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
    return Scaffold(
      appBar: widget.showAppBar ? AppBar(title: const Text('Notifications')) : null,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          if (_controller.state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_controller.state.hasError) {
            return ErrorStateView(
              message:
                  _controller.state.errorMessage ?? 'Unable to load notifications',
              onRetry: _controller.load,
            );
          }
          if (_controller.visibleNotifications.isEmpty) {
            return const Center(child: Text('No notifications in this category'));
          }
          return Column(
            children: [
              const SizedBox(height: 10),
              _NotificationFilterBar(
                activeFilter: _controller.activeFilter,
                onChanged: _controller.setFilter,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Unread: ${_controller.unreadCount}'),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _controller.visibleNotifications.length,
                  itemBuilder: (context, index) {
                    final item = _controller.visibleNotifications[index];
                    return Card(
                      child: ListTile(
                        onTap: () async {
                          final route = await _controller.handleTap(item);
                          if (!mounted || route == null) {
                            return;
                          }
                          Navigator.of(context).pushNamed(route);
                        },
                        leading: Icon(
                          _controller.isUnread(item)
                              ? Icons.notifications_active
                              : Icons.notifications,
                        ),
                        title: Text(item.title),
                        subtitle: Text(item.body),
                        trailing: Text(FormatHelper.timeAgo(item.createdAt)),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NotificationFilterBar extends StatelessWidget {
  const _NotificationFilterBar({
    required this.activeFilter,
    required this.onChanged,
  });

  final NotificationFilter activeFilter;
  final Future<void> Function(NotificationFilter) onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: NotificationFilter.values.map((NotificationFilter filter) {
        return ChoiceChip(
          label: Text(_label(filter)),
          selected: filter == activeFilter,
          onSelected: (_) {
            onChanged(filter);
          },
        );
      }).toList(),
    );
  }

  String _label(NotificationFilter filter) {
    switch (filter) {
      case NotificationFilter.all:
        return 'All';
      case NotificationFilter.social:
        return 'Social';
      case NotificationFilter.commerce:
        return 'Commerce';
      case NotificationFilter.security:
        return 'Security';
    }
  }
}
