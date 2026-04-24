import 'package:flutter/material.dart';

import '../../../core/common_widget/empty_state_view.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/functions/app_feedback.dart';
import '../../../core/widgets/app_avatar.dart';

enum _BuddyCardType { sent, received, buddy }

class BuddyScreen extends StatefulWidget {
  const BuddyScreen({super.key});

  @override
  State<BuddyScreen> createState() => _BuddyScreenState();
}

class _BuddyScreenState extends State<BuddyScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late List<_BuddyCardModel> _sentRequests;
  late List<_BuddyCardModel> _receivedRequests;
  late List<_BuddyCardModel> _buddies;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _sentRequests = <_BuddyCardModel>[
      _BuddyCardModel(
        user: _mockUser(
          id: 'sent_1',
          name: 'Maya Quinn',
          username: 'mayaquinn',
          avatar: 'https://placehold.co/120x120/png',
          verified: true,
        ),
        type: _BuddyCardType.sent,
        mutualBuddyText: '8 mutual buddies',
        responseText: 'Request sent 2 days ago',
      ),
      _BuddyCardModel(
        user: _mockUser(
          id: 'sent_2',
          name: 'Rafi Ahmed',
          username: 'rafiahmed',
          avatar: 'https://placehold.co/120x120/png',
        ),
        type: _BuddyCardType.sent,
        mutualBuddyText: '3 mutual buddies',
        responseText: 'Waiting for response',
      ),
    ];
    _receivedRequests = <_BuddyCardModel>[
      _BuddyCardModel(
        user: _mockUser(
          id: 'receive_1',
          name: 'Luna Crafts',
          username: 'luna.crafts',
          avatar: 'https://placehold.co/120x120/png',
        ),
        type: _BuddyCardType.received,
        mutualBuddyText: '6 mutual buddies',
        responseText: 'Requested you today',
      ),
      _BuddyCardModel(
        user: _mockUser(
          id: 'receive_2',
          name: 'Tariq Notes',
          username: 'tariqnotes',
          avatar: 'https://placehold.co/120x120/png',
        ),
        type: _BuddyCardType.received,
        mutualBuddyText: '2 mutual buddies',
        responseText: 'Wants to join your buddies',
      ),
    ];
    _buddies = <_BuddyCardModel>[
      _BuddyCardModel(
        user: _mockUser(
          id: 'buddy_1',
          name: 'Nayem Hasan',
          username: 'nayem',
          avatar: 'https://placehold.co/120x120/png',
          verified: true,
        ),
        type: _BuddyCardType.buddy,
        mutualBuddyText: '12 mutual buddies',
        responseText: 'Buddy since last month',
      ),
      _BuddyCardModel(
        user: _mockUser(
          id: 'buddy_2',
          name: 'Sadia Noor',
          username: 'sadia.noor',
          avatar: 'https://placehold.co/120x120/png',
        ),
        type: _BuddyCardType.buddy,
        mutualBuddyText: '5 mutual buddies',
        responseText: 'Usually replies to your stories',
      ),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buddies'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Tab>[
            Tab(text: 'Sent Request'),
            Tab(text: 'Receive Request'),
            Tab(text: 'Buddy'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          _buildBuddyList(
            items: _sentRequests,
            emptyTitle: 'No sent requests',
            emptyMessage: 'Buddy requests you send will show here.',
          ),
          _buildBuddyList(
            items: _receivedRequests,
            emptyTitle: 'No received requests',
            emptyMessage: 'Incoming buddy requests will show here.',
          ),
          _buildBuddyList(
            items: _buddies,
            emptyTitle: 'No buddies yet',
            emptyMessage: 'Accepted buddies will show here.',
          ),
        ],
      ),
    );
  }

  Widget _buildBuddyList({
    required List<_BuddyCardModel> items,
    required String emptyTitle,
    required String emptyMessage,
  }) {
    if (items.isEmpty) {
      return EmptyStateView(title: emptyTitle, message: emptyMessage);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (BuildContext context, int index) {
        final _BuddyCardModel item = items[index];
        return _BuddyCard(
          item: item,
          onAccept: () => _acceptRequest(item),
          onCancel: () => _cancelRequest(item),
          onRemoveBuddy: () => _removeBuddy(item),
          onMessage: () => _messageBuddy(item),
        );
      },
    );
  }

  void _acceptRequest(_BuddyCardModel item) {
    setState(() {
      _receivedRequests.removeWhere((entry) => entry.user.id == item.user.id);
      _buddies = <_BuddyCardModel>[
        _BuddyCardModel(
          user: item.user,
          type: _BuddyCardType.buddy,
          mutualBuddyText: item.mutualBuddyText,
          responseText: 'You are now buddies',
        ),
        ..._buddies,
      ];
    });
    AppFeedback.showSnackbar(
      title: 'Buddy',
      message: 'Request accepted',
    );
  }

  void _cancelRequest(_BuddyCardModel item) {
    setState(() {
      _sentRequests.removeWhere((entry) => entry.user.id == item.user.id);
      _receivedRequests.removeWhere((entry) => entry.user.id == item.user.id);
    });
    AppFeedback.showSnackbar(
      title: 'Buddy',
      message: 'Request cancelled',
    );
  }

  void _removeBuddy(_BuddyCardModel item) {
    setState(() {
      _buddies.removeWhere((entry) => entry.user.id == item.user.id);
    });
    AppFeedback.showSnackbar(
      title: 'Buddy',
      message: 'Removed from buddy list',
    );
  }

  void _messageBuddy(_BuddyCardModel item) {
    AppFeedback.showSnackbar(
      title: 'Message',
      message: 'Open chat with ${item.user.name}',
    );
  }

  UserModel _mockUser({
    required String id,
    required String name,
    required String username,
    required String avatar,
    bool verified = false,
  }) {
    return UserModel(
      id: id,
      name: name,
      username: username,
      avatar: avatar,
      bio: '',
      role: UserRole.user,
      followers: 0,
      following: 0,
      verified: verified,
    );
  }
}

class _BuddyCard extends StatelessWidget {
  const _BuddyCard({
    required this.item,
    required this.onAccept,
    required this.onCancel,
    required this.onRemoveBuddy,
    required this.onMessage,
  });

  final _BuddyCardModel item;
  final VoidCallback onAccept;
  final VoidCallback onCancel;
  final VoidCallback onRemoveBuddy;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              AppAvatar(
                imageUrl: item.user.avatar,
                radius: 28,
                verified: item.user.verified,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.user.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@${item.user.username}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.responseText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.mutualBuddyText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: _buildActions(context),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    switch (item.type) {
      case _BuddyCardType.buddy:
        return <Widget>[
          Expanded(
            child: FilledButton(
              onPressed: onMessage,
              child: const Text('Msg'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton(
              onPressed: onRemoveBuddy,
              child: const Text('Remove Buddy'),
            ),
          ),
        ];
      case _BuddyCardType.received:
        return <Widget>[
          Expanded(
            child: FilledButton(
              onPressed: onAccept,
              child: const Text('Accept'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton(
              onPressed: onCancel,
              child: const Text('Cancel'),
            ),
          ),
        ];
      case _BuddyCardType.sent:
        return <Widget>[
          Expanded(
            child: OutlinedButton(
              onPressed: onCancel,
              child: const Text('Cancel'),
            ),
          ),
        ];
    }
  }
}

class _BuddyCardModel {
  const _BuddyCardModel({
    required this.user,
    required this.type,
    required this.mutualBuddyText,
    required this.responseText,
  });

  final UserModel user;
  final _BuddyCardType type;
  final String mutualBuddyText;
  final String responseText;
}
