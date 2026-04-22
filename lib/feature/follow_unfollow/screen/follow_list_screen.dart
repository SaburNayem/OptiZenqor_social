import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/data/mock/mock_data.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../app_route/route_names.dart';
import '../../user_profile/screen/user_profile_screen.dart';
import '../controller/follow_controller.dart';

enum FollowListTab { followers, following }

class FollowListScreen extends StatefulWidget {
  const FollowListScreen({
    super.key,
    this.userId,
    this.initialTab = FollowListTab.followers,
  });

  final String? userId;
  final FollowListTab initialTab;

  @override
  State<FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends State<FollowListScreen> {
  late final FollowController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FollowController()..init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final targetUser = MockData.users.firstWhere(
      (user) => user.id == widget.userId,
      orElse: () => MockData.users.first,
    );

    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialTab == FollowListTab.followers ? 0 : 1,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final followers = _controller.followers(targetUser.id);
          final following = _controller.following(targetUser.id);

          return Scaffold(
            backgroundColor: AppColors.white,
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(targetUser.name),
                  Text(
                    '@${targetUser.username}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              bottom: TabBar(
                tabs: const [
                  Tab(text: 'Followers'),
                  Tab(text: 'Following'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _ConnectionsTab(
                  users: followers,
                  emptyTitle: 'No followers yet',
                  emptyMessage:
                      'When people follow this profile, they will appear here.',
                  controller: _controller,
                  targetUserId: targetUser.id,
                ),
                _ConnectionsTab(
                  users: following,
                  emptyTitle: 'Not following anyone yet',
                  emptyMessage:
                      'Accounts this profile follows will appear here.',
                  controller: _controller,
                  targetUserId: targetUser.id,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ConnectionsTab extends StatelessWidget {
  const _ConnectionsTab({
    required this.users,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.controller,
    required this.targetUserId,
  });

  final List<UserModel> users;
  final String emptyTitle;
  final String emptyMessage;
  final FollowController controller;
  final String targetUserId;

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return EmptyStateView(
        title: emptyTitle,
        message: emptyMessage,
      );
    }

    final currentUser = controller.currentUser();

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final user = users[index];
        final relation = controller.stateFor(user);
        final isCurrentUser = user.id == currentUser.id;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          leading: CircleAvatar(backgroundImage: NetworkImage(user.avatar)),
          title: Text(user.name),
          subtitle: Text('@${user.username}'),
          trailing: isCurrentUser
              ? const Chip(label: Text('You'))
              : relation.hasPendingRequest
              ? const Chip(label: Text('Requested'))
              : relation.isFollowing
              ? OutlinedButton(
                  onPressed: () => controller.toggleFollow(user),
                  child: const Text('Following'),
                )
              : FilledButton.tonal(
                  onPressed: () => controller.toggleFollow(user),
                  child: Text(
                    targetUserId == currentUser.id
                        ? 'Follow back'
                        : 'Follow',
                  ),
                ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => UserProfileScreen(userId: user.id),
                settings: const RouteSettings(name: RouteNames.userProfile),
              ),
            );
          },
        );
      },
    );
  }
}
