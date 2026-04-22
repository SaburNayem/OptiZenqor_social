import 'package:flutter/material.dart';

import '../../../core/data/mock/mock_data.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/helpers/format_helper.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../app_route/route_names.dart';
import '../../user_profile/screen/user_profile_screen.dart';
import '../controller/follow_controller.dart';
import '../model/follow_state_model.dart';

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
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
    final currentUser = controller.currentUser();
    final displayUsers = users.isEmpty
        ? MockData.users
            .where((user) => user.id != targetUserId)
            .take(4)
            .toList(growable: false)
        : users;
    final showingDummyCards = users.isEmpty;

    final items = <Widget>[
      if (showingDummyCards)
        _SampleConnectionsBanner(
          title: emptyTitle,
          message: '$emptyMessage Showing sample person cards for now.',
        ),
      ...displayUsers.map(
        (user) => _ConnectionPersonCard(
          user: user,
          relation: controller.stateFor(user),
          isCurrentUser: user.id == currentUser.id,
          showSampleBadge: showingDummyCards,
          actionLabel: targetUserId == currentUser.id ? 'Follow back' : 'Follow',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => UserProfileScreen(userId: user.id),
                settings: const RouteSettings(name: RouteNames.userProfile),
              ),
            );
          },
          onFollowTap: () => controller.toggleFollow(user),
        ),
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return items[index];
      },
    );
  }
}

class _ConnectionPersonCard extends StatelessWidget {
  const _ConnectionPersonCard({
    required this.user,
    required this.relation,
    required this.isCurrentUser,
    required this.actionLabel,
    required this.onTap,
    required this.onFollowTap,
    this.showSampleBadge = false,
  });

  final UserModel user;
  final FollowStateModel relation;
  final bool isCurrentUser;
  final bool showSampleBadge;
  final String actionLabel;
  final VoidCallback onTap;
  final VoidCallback onFollowTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final preview = user.profilePreview.isNotEmpty ? user.profilePreview : user.bio;

    return Material(
      color: colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppAvatar(
                    imageUrl: user.avatar,
                    verified: user.verified,
                    radius: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                user.name,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            if (user.isPrivate)
                              Icon(
                                Icons.lock_outline_rounded,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '@${user.username}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _FollowActionButton(
                    relation: relation,
                    isCurrentUser: isCurrentUser,
                    actionLabel: actionLabel,
                    onPressed: onFollowTap,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                preview,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ConnectionMetaChip(
                    icon: Icons.group_outlined,
                    label:
                        '${FormatHelper.formatCompactNumber(user.followers)} followers',
                  ),
                  _ConnectionMetaChip(
                    icon: Icons.person_add_alt_1_rounded,
                    label:
                        '${FormatHelper.formatCompactNumber(user.following)} following',
                  ),
                  _ConnectionMetaChip(
                    icon: Icons.verified_user_outlined,
                    label: _capitalize(user.role.name),
                  ),
                  if (showSampleBadge)
                    const _ConnectionMetaChip(
                      icon: Icons.auto_awesome_rounded,
                      label: 'Sample card',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }
    return value[0].toUpperCase() + value.substring(1);
  }
}

class _FollowActionButton extends StatelessWidget {
  const _FollowActionButton({
    required this.relation,
    required this.isCurrentUser,
    required this.actionLabel,
    required this.onPressed,
  });

  final FollowStateModel relation;
  final bool isCurrentUser;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (isCurrentUser) {
      return const Chip(label: Text('You'));
    }
    if (relation.hasPendingRequest) {
      return const Chip(label: Text('Requested'));
    }
    if (relation.isFollowing) {
      return OutlinedButton(
        onPressed: onPressed,
        child: const Text('Following'),
      );
    }
    return FilledButton.tonal(
      onPressed: onPressed,
      child: Text(actionLabel),
    );
  }
}

class _ConnectionMetaChip extends StatelessWidget {
  const _ConnectionMetaChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SampleConnectionsBanner extends StatelessWidget {
  const _SampleConnectionsBanner({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome_rounded, color: colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
