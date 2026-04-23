import 'package:flutter/material.dart';

import '../../../app_route/route_names.dart';
import '../../../core/helpers/format_helper.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../user_profile/repository/user_profile_repository.dart';
import '../../user_profile/screen/user_profile_screen.dart';
import '../../../core/data/models/user_model.dart';

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
  final UserProfileRepository _repository = UserProfileRepository();

  UserModel? _targetUser;
  UserModel? _currentUser;
  List<UserModel> _followers = <UserModel>[];
  List<UserModel> _following = <UserModel>[];
  List<UserModel> _sampleUsers = <UserModel>[];
  Set<String> _followingIds = <String>{};
  Set<String> _pendingRequestIds = <String>{};
  bool _isLoading = true;

  String get _currentUserId => _currentUser?.id ?? '';

  @override
  void initState() {
    super.initState();
    _loadConnections();
  }

  Future<void> _loadConnections() async {
    setState(() {
      _isLoading = true;
    });

    final String targetUserId = widget.userId?.trim() ?? '';
    final UserModel? currentUser = await _repository.getCurrentProfile();
    final UserModel? targetUser = targetUserId.isNotEmpty
        ? await _repository.getProfileById(targetUserId)
        : currentUser;

    if (targetUser == null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _targetUser = null;
        _isLoading = false;
      });
      return;
    }

    final List<Object> results = await Future.wait<Object>(<Future<Object>>[
      _repository.getFollowers(targetUser.id),
      _repository.getFollowing(targetUser.id),
      currentUser == null
          ? Future<List<UserModel>>.value(const <UserModel>[])
          : _repository.getFollowing(currentUser.id),
      _repository.suggestedContacts(excludeUserId: targetUser.id),
    ]);

    if (!mounted) {
      return;
    }

    final List<UserModel> currentFollowing = results[2] as List<UserModel>;
    setState(() {
      _targetUser = targetUser;
      _currentUser = currentUser;
      _followers = results[0] as List<UserModel>;
      _following = results[1] as List<UserModel>;
      _sampleUsers = results[3] as List<UserModel>;
      _followingIds = currentFollowing
          .map((UserModel item) => item.id)
          .toSet();
      _pendingRequestIds = <String>{};
      _isLoading = false;
    });
  }

  Future<void> _toggleFollow(UserModel user) async {
    final bool isFollowing = _followingIds.contains(user.id);
    final bool isPending = _pendingRequestIds.contains(user.id);
    final FollowToggleResult result = await _repository.toggleFollow(
      user,
      isCurrentlyFollowing: isFollowing,
      hasPendingRequest: isPending,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      if (result.isFollowing) {
        _followingIds.add(user.id);
        _pendingRequestIds.remove(user.id);
      } else if (result.hasPendingRequest) {
        _followingIds.remove(user.id);
        _pendingRequestIds.add(user.id);
      } else {
        _followingIds.remove(user.id);
        _pendingRequestIds.remove(user.id);
      }

      if (_targetUser?.id == _currentUserId) {
        if (result.isFollowing) {
          final bool alreadyPresent = _following.any(
            (UserModel item) => item.id == user.id,
          );
          if (!alreadyPresent) {
            _following = <UserModel>[user, ..._following];
          }
        } else if (!result.hasPendingRequest) {
          _following = _following
              .where((UserModel item) => item.id != user.id)
              .toList(growable: false);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final UserModel? targetUser = _targetUser;
    if (targetUser == null) {
      return const Scaffold(
        body: Center(child: Text('Profile not found')),
      );
    }

    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialTab == FollowListTab.followers ? 0 : 1,
      child: Scaffold(
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
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Followers'),
              Tab(text: 'Following'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ConnectionsTab(
              users: _followers,
              sampleUsers: _sampleUsers,
              emptyTitle: 'No followers yet',
              emptyMessage:
                  'When people follow this profile, they will appear here.',
              currentUserId: _currentUserId,
              followingIds: _followingIds,
              pendingRequestIds: _pendingRequestIds,
              onTapUser: _openUserProfile,
              onToggleFollow: _toggleFollow,
            ),
            _ConnectionsTab(
              users: _following,
              sampleUsers: _sampleUsers,
              emptyTitle: 'Not following anyone yet',
              emptyMessage:
                  'Accounts this profile follows will appear here.',
              currentUserId: _currentUserId,
              followingIds: _followingIds,
              pendingRequestIds: _pendingRequestIds,
              onTapUser: _openUserProfile,
              onToggleFollow: _toggleFollow,
            ),
          ],
        ),
      ),
    );
  }

  void _openUserProfile(UserModel user) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => UserProfileScreen(userId: user.id),
        settings: const RouteSettings(name: RouteNames.userProfile),
      ),
    );
  }
}

class _ConnectionsTab extends StatelessWidget {
  const _ConnectionsTab({
    required this.users,
    required this.sampleUsers,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.currentUserId,
    required this.followingIds,
    required this.pendingRequestIds,
    required this.onTapUser,
    required this.onToggleFollow,
  });

  final List<UserModel> users;
  final List<UserModel> sampleUsers;
  final String emptyTitle;
  final String emptyMessage;
  final String currentUserId;
  final Set<String> followingIds;
  final Set<String> pendingRequestIds;
  final ValueChanged<UserModel> onTapUser;
  final ValueChanged<UserModel> onToggleFollow;

  @override
  Widget build(BuildContext context) {
    final List<UserModel> displayUsers = users.isEmpty ? sampleUsers : users;
    final bool showingDummyCards = users.isEmpty;

    final List<Widget> items = <Widget>[
      if (showingDummyCards)
        _SampleConnectionsBanner(
          title: emptyTitle,
          message: '$emptyMessage Showing suggested people for now.',
        ),
      ...displayUsers.map(
        (UserModel user) => _ConnectionPersonCard(
          user: user,
          isCurrentUser: user.id == currentUserId,
          isFollowing: followingIds.contains(user.id),
          hasPendingRequest: pendingRequestIds.contains(user.id),
          showSampleBadge: showingDummyCards,
          actionLabel: 'Follow',
          onTap: () => onTapUser(user),
          onFollowTap: () => onToggleFollow(user),
        ),
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (BuildContext context, int index) {
        return items[index];
      },
    );
  }
}

class _ConnectionPersonCard extends StatelessWidget {
  const _ConnectionPersonCard({
    required this.user,
    required this.isCurrentUser,
    required this.isFollowing,
    required this.hasPendingRequest,
    required this.actionLabel,
    required this.onTap,
    required this.onFollowTap,
    this.showSampleBadge = false,
  });

  final UserModel user;
  final bool isCurrentUser;
  final bool isFollowing;
  final bool hasPendingRequest;
  final bool showSampleBadge;
  final String actionLabel;
  final VoidCallback onTap;
  final VoidCallback onFollowTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String preview = user.profilePreview.isNotEmpty ? user.profilePreview : user.bio;

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
                    isCurrentUser: isCurrentUser,
                    isFollowing: isFollowing,
                    hasPendingRequest: hasPendingRequest,
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
                      label: 'Suggested',
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
    required this.isCurrentUser,
    required this.isFollowing,
    required this.hasPendingRequest,
    required this.actionLabel,
    required this.onPressed,
  });

  final bool isCurrentUser;
  final bool isFollowing;
  final bool hasPendingRequest;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (isCurrentUser) {
      return const Chip(label: Text('You'));
    }
    if (hasPendingRequest) {
      return const Chip(label: Text('Requested'));
    }
    if (isFollowing) {
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
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
