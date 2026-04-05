import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/data/models/notification_model.dart';
import '../controller/notifications_controller.dart';
import '../model/notification_payload_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final NotificationsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = NotificationsController()..load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Notifications'),
              actions: [
                TextButton(
                  onPressed: () {
                    _controller.markAllAsRead();
                    Get.snackbar(
                      'Notifications',
                      'All notifications marked as read',
                    );
                  },
                  child: const Text('Mark all read'),
                ),
              ],
            )
          : null,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = _controller.visibleNotifications;
          if (items.isEmpty) {
            return const Center(child: Text('No notifications available'));
          }

          return Column(
            children: [
              const SizedBox(height: 10),
              _NotificationFilterBar(
                activeFilter: _controller.activeFilter,
                onChanged: _controller.setFilter,
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      'Unread: ${_controller.unreadCount}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final unread = _controller.isUnread(item);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Dismissible(
                        key: ValueKey(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete_outline, color: Colors.white),
                              SizedBox(height: 4),
                              Text(
                                'Delete',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        confirmDismiss: (_) =>
                            _confirmNotificationDelete(context, item),
                        onDismissed: (_) {
                          _controller.removeNotification(item.id);
                          Get.snackbar(
                            'Notification Deleted',
                            '${item.title} was removed',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () async {
                            await _controller.handleTap(item);
                          },
                          onLongPress: () {
                            Get.bottomSheet(
                              _NotificationActionSheet(
                                onMute: () {
                                  Get.back();
                                  Get.snackbar(
                                    'Notification',
                                    'User muted from notifications',
                                  );
                                },
                                onTurnOff: () {
                                  Get.back();
                                  Get.snackbar(
                                    'Notification',
                                    'Similar notifications turned off',
                                  );
                                },
                              ),
                              backgroundColor: Colors.white,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: unread
                                  ? const Color(0xFFF2F7FF)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFFE9EEF5),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundColor: unread
                                      ? const Color(0xFFDCEBFF)
                                      : const Color(0xFFF1F3F5),
                                  child: Icon(
                                    _iconFor(item),
                                    color: unread
                                        ? const Color(0xFF1877F2)
                                        : Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 14,
                                            height: 1.4,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: '${item.title} ',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            TextSpan(text: item.body),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Text(
                                            _timeLabel(item),
                                            style: TextStyle(
                                              color: unread
                                                  ? const Color(0xFF1877F2)
                                                  : Colors.grey.shade600,
                                              fontSize: 12,
                                              fontWeight: unread
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          if (unread)
                                            Container(
                                              width: 10,
                                              height: 10,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF1877F2),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    Get.bottomSheet(
                                      _NotificationActionSheet(
                                        onMute: () {
                                          Get.back();
                                          Get.snackbar(
                                            'Notification',
                                            'User muted from notifications',
                                          );
                                        },
                                        onTurnOff: () {
                                          Get.back();
                                          Get.snackbar(
                                            'Notification',
                                            'Similar notifications turned off',
                                          );
                                        },
                                      ),
                                      backgroundColor: Colors.white,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(24),
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.more_horiz),
                                ),
                              ],
                            ),
                          ),
                        ),
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

  Future<bool?> _confirmNotificationDelete(
    BuildContext context,
    NotificationModel item,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete notification?'),
          content: Text('Are you sure you want to remove "${item.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  String _timeLabel(NotificationModel item) {
    final difference = DateTime.now().difference(item.createdAt);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours}h';
    }
    return '${difference.inDays}d';
  }

  IconData _iconFor(NotificationModel item) {
    switch (item.payload.type) {
      case NotificationType.social:
        return Icons.person_add_alt_1;
      case NotificationType.commerce:
        return Icons.shopping_bag_outlined;
      case NotificationType.security:
        return Icons.security;
      case NotificationType.system:
        return Icons.info_outline;
    }
  }
}

class _NotificationFilterBar extends StatelessWidget {
  const _NotificationFilterBar({
    required this.activeFilter,
    required this.onChanged,
  });

  final NotificationFilter activeFilter;
  final ValueChanged<NotificationFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: NotificationFilter.values.map((filter) {
          final selected = filter == activeFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(_label(filter)),
              selected: selected,
              onSelected: (_) => onChanged(filter),
            ),
          );
        }).toList(),
      ),
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

class _NotificationActionSheet extends StatelessWidget {
  const _NotificationActionSheet({
    required this.onMute,
    required this.onTurnOff,
  });

  final VoidCallback onMute;
  final VoidCallback onTurnOff;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.volume_off_outlined),
              title: const Text('Mute this person'),
              onTap: onMute,
            ),
            ListTile(
              leading: const Icon(Icons.notifications_off_outlined),
              title: const Text('Turn off similar notifications'),
              onTap: onTurnOff,
            ),
            ListTile(
              leading: const Icon(Icons.cancel_outlined),
              title: const Text('Close'),
              onTap: Get.back,
            ),
          ],
        ),
      ),
    );
  }
}
