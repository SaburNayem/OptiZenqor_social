import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../route/route_names.dart';

enum NotificationFilter { all, social, commerce, security }

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const List<_NotificationItem> _items = <_NotificationItem>[
    _NotificationItem(
      id: 'n1',
      title: 'New follower',
      body: 'Nexa Studio followed your profile.',
      category: NotificationFilter.social,
      routeName: RouteNames.searchDiscovery,
      createdAtLabel: '2m ago',
      unread: true,
    ),
    _NotificationItem(
      id: 'n2',
      title: 'Order update',
      body: 'Your marketplace order is ready for review.',
      category: NotificationFilter.commerce,
      routeName: RouteNames.marketplace,
      createdAtLabel: '1h ago',
      unread: true,
    ),
    _NotificationItem(
      id: 'n4',
      title: 'Mentioned in comments',
      body: 'mayaquinn mentioned you in a post discussion.',
      category: NotificationFilter.social,
      routeName: RouteNames.postDetail,
      createdAtLabel: '3h ago',
      unread: true,
    ),
    _NotificationItem(
      id: 'n5',
      title: 'Tagged in media',
      body: 'Nexa Studio tagged you in a launch recap.',
      category: NotificationFilter.social,
      routeName: RouteNames.userProfile,
      createdAtLabel: 'Today',
      unread: false,
    ),
    _NotificationItem(
      id: 'n6',
      title: 'Follow request',
      body: 'Luna Crafts sent a follow request.',
      category: NotificationFilter.social,
      routeName: RouteNames.userProfile,
      createdAtLabel: 'Today',
      unread: true,
    ),
    _NotificationItem(
      id: 'n3',
      title: 'Security reminder',
      body: 'Review your password and device settings.',
      category: NotificationFilter.security,
      routeName: RouteNames.passwordSecurity,
      createdAtLabel: 'Today',
      unread: false,
    ),
  ];

  NotificationFilter _activeFilter = NotificationFilter.all;
  final Set<String> _readIds = <String>{};

  List<_NotificationItem> get _visibleItems {
    if (_activeFilter == NotificationFilter.all) {
      return _items;
    }
    return _items.where((item) => item.category == _activeFilter).toList();
  }

  bool _isUnread(_NotificationItem item) => item.unread && !_readIds.contains(item.id);

  int get _unreadCount => _items.where((item) => _isUnread(item)).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar ? AppBar(title: const Text('Notifications')) : null,
      body: Column(
        children: [
          const SizedBox(height: 10),
          _NotificationFilterBar(
            activeFilter: _activeFilter,
            onChanged: (filter) => setState(() => _activeFilter = filter),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    Chip(label: Text('Who viewed profile')),
                    Chip(label: Text('Who mentioned me')),
                    Chip(label: Text('Who tagged me')),
                    Chip(label: Text('Who reacted to comment')),
                    Chip(label: Text('Birthday reminder')),
                    Chip(label: Text('Event reminder')),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Unread: $_unreadCount'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Column(
                children: const [
                  ListTile(
                    leading: Icon(Icons.volume_off_outlined),
                    title: Text('Per-user mute'),
                    subtitle: Text('Mute noisy accounts from activity'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.groups_outlined),
                    title: Text('Per-group mute'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.summarize_outlined),
                    title: Text('Digest/summary placeholder'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.auto_awesome_outlined),
                    title: Text('Smart priority notification placeholder'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _visibleItems.length,
              itemBuilder: (context, index) {
                final item = _visibleItems[index];
                return Card(
                  child: ListTile(
                    onTap: () {
                      setState(() => _readIds.add(item.id));
                      Get.toNamed(item.routeName);
                    },
                    leading: Icon(
                      _isUnread(item)
                          ? Icons.notifications_active
                          : Icons.notifications,
                    ),
                    title: Text(item.title),
                    subtitle: Text(item.body),
                    trailing: Text(item.createdAtLabel),
                  ),
                );
              },
            ),
          ),
        ],
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
  final ValueChanged<NotificationFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: NotificationFilter.values.map((NotificationFilter filter) {
        return ChoiceChip(
          label: Text(_label(filter)),
          selected: filter == activeFilter,
          onSelected: (_) => onChanged(filter),
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

class _NotificationItem {
  const _NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.routeName,
    required this.createdAtLabel,
    required this.unread,
  });

  final String id;
  final String title;
  final String body;
  final NotificationFilter category;
  final String routeName;
  final String createdAtLabel;
  final bool unread;
}
