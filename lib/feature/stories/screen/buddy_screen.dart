import 'package:flutter/material.dart';

import '../../../core/common_widget/empty_state_view.dart';
import '../../../core/common_widget/error_state_view.dart';
import '../../../core/data/models/message_model.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/functions/app_feedback.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../chat/repository/chat_repository.dart';
import '../../chat/screen/chat_detail_screen.dart';
import '../model/buddy_relationship_model.dart';
import '../repository/buddy_repository.dart';

enum _BuddyCardType { sent, received, buddy }

class BuddyScreen extends StatefulWidget {
  const BuddyScreen({super.key});

  @override
  State<BuddyScreen> createState() => _BuddyScreenState();
}

class _BuddyScreenState extends State<BuddyScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final BuddyRepository _repository = BuddyRepository();
  final ChatRepository _chatRepository = ChatRepository();
  List<_BuddyCardModel> _sentRequests = <_BuddyCardModel>[];
  List<_BuddyCardModel> _receivedRequests = <_BuddyCardModel>[];
  List<_BuddyCardModel> _buddies = <_BuddyCardModel>[];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBuddies();
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return ErrorStateView(message: _errorMessage!, onRetry: _loadBuddies);
    }
    return TabBarView(
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
    );
  }

  Future<void> _loadBuddies() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final List<dynamic> results =
          await Future.wait<dynamic>(<Future<dynamic>>[
            _repository.fetchSentRequests(),
            _repository.fetchReceivedRequests(),
            _repository.fetchBuddies(),
          ]);
      if (!mounted) {
        return;
      }
      setState(() {
        _sentRequests = (results[0] as List<BuddyRelationshipModel>)
            .map(
              (BuddyRelationshipModel item) =>
                  _mapItem(item, _BuddyCardType.sent),
            )
            .toList(growable: false);
        _receivedRequests = (results[1] as List<BuddyRelationshipModel>)
            .map(
              (BuddyRelationshipModel item) =>
                  _mapItem(item, _BuddyCardType.received),
            )
            .toList(growable: false);
        _buddies = (results[2] as List<BuddyRelationshipModel>)
            .map(
              (BuddyRelationshipModel item) =>
                  _mapItem(item, _BuddyCardType.buddy),
            )
            .toList(growable: false);
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
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

  Future<void> _acceptRequest(_BuddyCardModel item) async {
    try {
      final BuddyRelationshipModel accepted = await _repository.acceptRequest(
        item.id,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _receivedRequests.removeWhere((entry) => entry.id == item.id);
        _buddies = <_BuddyCardModel>[
          _mapItem(accepted, _BuddyCardType.buddy),
          ..._buddies,
        ];
      });
      AppFeedback.showSnackbar(title: 'Buddy', message: 'Request accepted');
    } catch (error) {
      AppFeedback.showSnackbar(
        title: 'Buddy',
        message: error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _cancelRequest(_BuddyCardModel item) async {
    try {
      await _repository.cancelRequest(item.id);
      if (!mounted) {
        return;
      }
      setState(() {
        _sentRequests.removeWhere((entry) => entry.id == item.id);
        _receivedRequests.removeWhere((entry) => entry.id == item.id);
      });
      AppFeedback.showSnackbar(title: 'Buddy', message: 'Request cancelled');
    } catch (error) {
      AppFeedback.showSnackbar(
        title: 'Buddy',
        message: error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _removeBuddy(_BuddyCardModel item) async {
    try {
      await _repository.removeBuddy(item.user.id);
      if (!mounted) {
        return;
      }
      setState(() {
        _buddies.removeWhere((entry) => entry.user.id == item.user.id);
      });
      AppFeedback.showSnackbar(
        title: 'Buddy',
        message: 'Removed from buddy list',
      );
    } catch (error) {
      AppFeedback.showSnackbar(
        title: 'Buddy',
        message: error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _messageBuddy(_BuddyCardModel item) async {
    try {
      final thread = await _chatRepository.createThread(item.user.id);
      if (!mounted) {
        return;
      }
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ChatDetailScreen(
            user: thread.user.id.isNotEmpty ? thread.user : item.user,
            initialMessage:
                thread.lastMessageModel ??
                MessageModel(
                  id: 'buddy_msg_${DateTime.now().microsecondsSinceEpoch}',
                  chatId: thread.chatId,
                  senderId: item.user.id,
                  text: 'Say hi to your buddy',
                  timestamp: DateTime.now(),
                  read: true,
                ),
          ),
        ),
      );
    } catch (error) {
      AppFeedback.showSnackbar(
        title: 'Chat',
        message: error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  _BuddyCardModel _mapItem(BuddyRelationshipModel item, _BuddyCardType type) {
    return _BuddyCardModel(
      id: item.id,
      user: item.user,
      type: type,
      mutualBuddyText:
          '${item.mutualCount} mutual ${item.mutualCount == 1 ? 'buddy' : 'buddies'}',
      responseText: switch (type) {
        _BuddyCardType.sent => 'Request sent',
        _BuddyCardType.received => 'Sent you a buddy request',
        _BuddyCardType.buddy => 'Buddy connected',
      },
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
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            item.mutualBuddyText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          Row(children: _buildActions()),
        ],
      ),
    );
  }

  List<Widget> _buildActions() {
    switch (item.type) {
      case _BuddyCardType.buddy:
        return <Widget>[
          Expanded(
            child: FilledButton(onPressed: onMessage, child: const Text('Msg')),
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
    required this.id,
    required this.user,
    required this.type,
    required this.mutualBuddyText,
    required this.responseText,
  });

  final String id;
  final UserModel user;
  final _BuddyCardType type;
  final String mutualBuddyText;
  final String responseText;
}
