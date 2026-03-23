import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/helpers/format_helper.dart';
import '../../../core/common_models/post_model.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/error_state_view.dart';
import '../controller/user_profile_controller.dart';

class UserProfileScreen extends StatelessWidget {
  UserProfileScreen({super.key, this.userId}) {
    _controller.load(userId: userId);
  }

  final String? userId;

  final UserProfileController _controller = UserProfileController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final user = _controller.user;
        if (_controller.state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_controller.state.hasError) {
          return ErrorStateView(
            message: _controller.state.errorMessage ?? 'Unable to load profile',
            onRetry: _controller.load,
          );
        }
        if (user == null) {
          return const Center(child: Text('Profile not available'));
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppAvatar(imageUrl: user.avatar, radius: 42, verified: user.verified),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          if (user.verified)
                            Icon(
                              Icons.verified_rounded,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                        ],
                      ),
                      Text('@${user.username}'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          _RoleBadge(label: user.role.name.toUpperCase()),
                          _RoleBadge(
                            label: '${_controller.postCount} POSTS',
                          ),
                          _RoleBadge(
                            label: '${_controller.reelCount} REELS',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(user.bio),
            const SizedBox(height: 14),
            Row(
              children: [
                if (_controller.isOwnProfile) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            const SnackBar(content: Text('Profile edit flow opened')),
                          );
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit Profile'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            const SnackBar(content: Text('Insights opened')),
                          );
                      },
                      icon: const Icon(Icons.insights_outlined),
                      label: const Text('Insights'),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        await _controller.toggleFollow();
                        if (!context.mounted) {
                          return;
                        }
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Text(
                                _controller.followRequestPending
                                    ? 'Follow request sent'
                                    : (_controller.isFollowing ? 'Following user' : 'Unfollowed user'),
                              ),
                            ),
                          );
                      },
                      icon: Icon(
                        _controller.isFollowing ? Icons.person_remove_alt_1_outlined : Icons.person_add_alt_1_outlined,
                      ),
                      label: Text(
                        _controller.followRequestPending
                            ? 'Requested'
                            : (_controller.isFollowing ? 'Following' : 'Follow'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            const SnackBar(content: Text('Message opened')),
                          );
                      },
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Message'),
                    ),
                  ),
                ],
                const SizedBox(width: 10),
                PopupMenuButton<String>(
                  tooltip: 'More profile actions',
                  icon: const Icon(Icons.more_horiz_rounded),
                  onSelected: (value) async {
                    if (value == 'copy_link') {
                      await Clipboard.setData(
                        ClipboardData(text: 'https://optizenqor.app/@${user.username}'),
                      );
                      if (!context.mounted) {
                        return;
                      }
                    }
                    if (!context.mounted) {
                      return;
                    }
                    final message = switch (value) {
                      'copy_link' => 'Profile link copied',
                      'archive' => 'Archive opened',
                      'qr' => 'Profile QR opened',
                      'report' => 'Report submitted',
                      'block' => 'User blocked',
                      'mute' => 'User muted',
                      _ => 'Action completed',
                    };
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(content: Text(message)));
                  },
                  itemBuilder: (_) {
                    if (_controller.isOwnProfile) {
                      return const [
                        PopupMenuItem(value: 'copy_link', child: Text('Copy profile link')),
                        PopupMenuItem(value: 'archive', child: Text('Archive profile content')),
                        PopupMenuItem(value: 'qr', child: Text('Show profile QR')),
                      ];
                    }
                    return const [
                      PopupMenuItem(value: 'copy_link', child: Text('Copy profile link')),
                      PopupMenuItem(value: 'mute', child: Text('Mute user')),
                      PopupMenuItem(value: 'block', child: Text('Block user')),
                      PopupMenuItem(value: 'report', child: Text('Report profile')),
                    ];
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _StatTile(label: 'Posts', value: _controller.postCount.toString()),
                const SizedBox(width: 12),
                _StatTile(
                  label: 'Followers',
                  value: FormatHelper.formatCompactNumber(_controller.followersList.isEmpty ? user.followers : _controller.followersList.length),
                ),
                const SizedBox(width: 12),
                _StatTile(
                  label: 'Following',
                  value: FormatHelper.formatCompactNumber(_controller.followingList.isEmpty ? user.following : _controller.followingList.length),
                ),
              ],
            ),
            if (_controller.mutualConnections.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Mutual connections', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _controller.mutualConnections.map((item) {
                  return Chip(
                    avatar: CircleAvatar(backgroundImage: NetworkImage(item.avatar)),
                    label: Text(item.name),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 20),
            Text('Highlights', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SizedBox(
              height: 92,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _controller.highlights.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (_, index) {
                  final title = _controller.highlights[index];
                  return _HighlightItem(title: title);
                },
              ),
            ),
            const SizedBox(height: 16),
            Text('Quick Tools', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _controller.quickActions().map((item) {
                return ActionChip(
                  label: Text(item),
                  onPressed: () {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(content: Text('$item opened')));
                  },
                );
              }).toList(),
            ),
            if (!_controller.isOwnProfile) ...[
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.mark_chat_unread_outlined),
                  title: const Text('Message section'),
                  subtitle: const Text('Start a direct chat with this profile.'),
                  trailing: FilledButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(content: Text('Direct message started')),
                        );
                    },
                    child: const Text('Message'),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _controller.profileTabs.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, index) {
                  final selected = index == _controller.selectedTabIndex;
                  return ChoiceChip(
                    label: Text(_controller.profileTabs[index]),
                    selected: selected,
                    onSelected: (_) => _controller.selectTab(index),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            _ProfileTabContent(
              tabLabel: _controller.profileTabs[_controller.selectedTabIndex],
              posts: _controller.posts,
              reelCount: _controller.reelCount,
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                title: const Text('Safety actions'),
                subtitle: const Text('Block • Report • Mute options ready for policy integration'),
                trailing: Icon(
                  Icons.shield_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(value, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

class _HighlightItem extends StatelessWidget {
  const _HighlightItem({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
            child: Icon(
              Icons.auto_stories_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _ProfileTabContent extends StatelessWidget {
  const _ProfileTabContent({
    required this.tabLabel,
    required this.posts,
    required this.reelCount,
  });

  final String tabLabel;
  final List<PostModel> posts;
  final int reelCount;

  @override
  Widget build(BuildContext context) {
    final normalized = tabLabel.toLowerCase();
    if (normalized == 'posts') {
      if (posts.isEmpty) {
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('No posts yet.'),
          ),
        );
      }
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: posts.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
        ),
        itemBuilder: (_, index) {
          final media = posts[index].media;
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: media.isEmpty
                ? Container(color: Theme.of(context).colorScheme.surfaceContainer)
                : Image.network(media.first, fit: BoxFit.cover),
          );
        },
      );
    }

    if (normalized == 'reels') {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.play_circle_outline),
          title: Text('Reels uploaded: $reelCount'),
          subtitle: const Text('Tap reels tab in shell to manage short videos.'),
        ),
      );
    }

    return Card(
      child: ListTile(
        title: Text(tabLabel),
        subtitle: const Text('Detailed content for this section will appear here.'),
      ),
    );
  }
}
