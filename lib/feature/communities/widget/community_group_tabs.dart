import 'package:flutter/material.dart';

import '../model/community_group_model.dart';
import '../bloc/community_group_cubit.dart';
import '../helper/community_group_actions.dart';
import '../helper/community_group_formatters.dart';
import 'community_group_common_widgets.dart';
import 'community_group_detail_widgets.dart';
import 'community_group_feed_widgets.dart';

class CommunityHomeTab extends StatelessWidget {
  const CommunityHomeTab({required this.controller, super.key});

  final CommunityGroupCubit controller;

  @override
  Widget build(BuildContext context) {
    final group = controller.group;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        CommunityComposerCard(
          avatarColor: group.avatarColor,
          onTap: () => CommunityGroupActions.showCreatePostSheet(context),
        ),
        const SizedBox(height: 16),
        CommunityQuickActions(onAction: (text) => _showSnack(context, text)),
        const SizedBox(height: 22),
        const CommunitySectionHeader('Pinned posts'),
        ...group.pinnedPosts.map(
          (post) => _buildPostCard(context, post, adminTools: true),
        ),
        const SizedBox(height: 18),
        const CommunitySectionHeader('Announcements'),
        ...group.announcements.map(
          (post) => _buildPostCard(
            context,
            post,
            highlighted: true,
            adminTools: true,
          ),
        ),
        const SizedBox(height: 18),
        const CommunitySectionHeader('Recent activity'),
        ...group.recentActivity.map(
          (item) => CommunityActivityTile(value: item),
        ),
        const SizedBox(height: 18),
        const CommunitySectionHeader('Trending posts'),
        ...group.trendingPosts.map((post) => _buildPostCard(context, post)),
        const SizedBox(height: 18),
        if (group.allowChatRoom)
          CommunityGroupChatCard(
            onOpenChat: () => CommunityGroupActions.showGroupChatRoom(context),
            onAdminControls: () => _showSnack(context, 'Admin chat controls'),
          ),
        const SizedBox(height: 18),
        const CommunitySectionHeader('Latest feed'),
        ...controller.posts
            .take(4)
            .map((post) => _buildPostCard(context, post)),
      ],
    );
  }

  Widget _buildPostCard(
    BuildContext context,
    CommunityPostModel post, {
    bool highlighted = false,
    bool adminTools = false,
  }) {
    return CommunityPostCard(
      controller: controller,
      post: post,
      highlighted: highlighted,
      adminTools: adminTools,
      onMediaTap: (label, isVideo) => CommunityGroupActions.showMediaViewer(
        context,
        label: label,
        isVideo: isVideo,
      ),
      onMessage: (text) => _showSnack(context, text),
    );
  }
}

class CommunityPostsTab extends StatelessWidget {
  const CommunityPostsTab({required this.controller, super.key});

  final CommunityGroupCubit controller;

  @override
  Widget build(BuildContext context) {
    const filters = ['Recent', 'Popular', 'Media only'];

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >
            notification.metrics.maxScrollExtent - 120) {
          controller.loadMorePosts();
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.posts.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...filters.map(
                    (label) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(label),
                        selected: controller.postFilter == label,
                        onSelected: (_) => controller.setPostFilter(label),
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: controller.setPostFilter,
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'Recent', child: Text('Recent')),
                      PopupMenuItem(value: 'Popular', child: Text('Popular')),
                      PopupMenuItem(
                        value: 'Media only',
                        child: Text('Media only'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
          if (index == 1) {
            return const SizedBox(height: 16);
          }

          final post = controller.posts[index - 2];
          return CommunityPostCard(
            controller: controller,
            post: post,
            adminTools: true,
            onMediaTap: (label, isVideo) =>
                CommunityGroupActions.showMediaViewer(
                  context,
                  label: label,
                  isVideo: isVideo,
                ),
            onMessage: (text) => _showSnack(context, text),
          );
        },
      ),
    );
  }
}

class CommunityMediaTab extends StatelessWidget {
  const CommunityMediaTab({required this.controller, super.key});

  final CommunityGroupCubit controller;

  @override
  Widget build(BuildContext context) {
    final items = controller.mediaItems;
    final photos = items.where((item) => !item.isVideo).toList(growable: false);
    final videos = items.where((item) => item.isVideo).toList(growable: false);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: CommunityMediaFilter.values
              .map(
                (filter) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(mediaFilterLabel(filter)),
                    selected: controller.mediaFilter == filter,
                    onSelected: (_) => controller.setMediaFilter(filter),
                  ),
                ),
              )
              .toList(growable: false),
        ),
        const SizedBox(height: 16),
        if (photos.isNotEmpty) ...[
          const CommunitySectionHeader('Photos grid'),
          CommunityMediaGrid(
            items: photos,
            onTap: (label, isVideo) => CommunityGroupActions.showMediaViewer(
              context,
              label: label,
              isVideo: isVideo,
            ),
          ),
          const SizedBox(height: 18),
        ],
        if (videos.isNotEmpty) ...[
          const CommunitySectionHeader('Videos grid'),
          CommunityMediaGrid(
            items: videos,
            onTap: (label, isVideo) => CommunityGroupActions.showMediaViewer(
              context,
              label: label,
              isVideo: isVideo,
            ),
          ),
          const SizedBox(height: 18),
        ],
        const CommunitySectionHeader('Albums'),
        const Row(
          children: [
            Expanded(child: CommunityAlbumCard(title: 'Highlights', count: 12)),
            SizedBox(width: 12),
            Expanded(child: CommunityAlbumCard(title: 'Events', count: 8)),
          ],
        ),
      ],
    );
  }
}

class CommunityEventsTab extends StatelessWidget {
  const CommunityEventsTab({required this.controller, super.key});

  final CommunityGroupCubit controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const CommunitySectionHeader('Upcoming events'),
        ...controller.upcomingEvents.map(
          (event) => CommunityEventCard(
            controller: controller,
            event: event,
            onInvite: () => CommunityGroupActions.showInviteOptions(context),
          ),
        ),
        const SizedBox(height: 18),
        const CommunitySectionHeader('Ongoing events'),
        ...controller.ongoingEvents.map(
          (event) => CommunityEventCard(
            controller: controller,
            event: event,
            onInvite: () => CommunityGroupActions.showInviteOptions(context),
          ),
        ),
        const SizedBox(height: 18),
        const CommunitySectionHeader('Past events'),
        ...controller.pastEvents.map(
          (event) => CommunityEventCard(
            controller: controller,
            event: event,
            onInvite: () => CommunityGroupActions.showInviteOptions(context),
          ),
        ),
      ],
    );
  }
}

class CommunityMembersTab extends StatelessWidget {
  const CommunityMembersTab({required this.controller, super.key});

  final CommunityGroupCubit controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          onChanged: controller.updateMemberQuery,
          decoration: InputDecoration(
            hintText: 'Search members',
            prefixIcon: const Icon(Icons.search_rounded),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 18),
        const CommunitySectionHeader('Admins & moderators'),
        ...[...controller.admins, ...controller.moderators].map(
          (member) => CommunityMemberTile(
            controller: controller,
            member: member,
            onMessage: (text) => _showSnack(context, text),
          ),
        ),
        const SizedBox(height: 18),
        const CommunitySectionHeader('Top contributors'),
        ...controller.topContributors.map(
          (member) => CommunityMemberTile(
            controller: controller,
            member: member,
            onMessage: (text) => _showSnack(context, text),
          ),
        ),
        const SizedBox(height: 18),
        const CommunitySectionHeader('All members'),
        ...controller.visibleMembers.map(
          (member) => CommunityMemberTile(
            controller: controller,
            member: member,
            onMessage: (text) => _showSnack(context, text),
          ),
        ),
      ],
    );
  }
}

class CommunityAboutTab extends StatelessWidget {
  const CommunityAboutTab({required this.controller, super.key});

  final CommunityGroupCubit controller;

  @override
  Widget build(BuildContext context) {
    final group = controller.group;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        CommunityAboutCard(
          title: 'Group description',
          value: group.description,
        ),
        CommunityAboutCard(
          title: 'Rules',
          value: group.rules.map((rule) => '• $rule').join('\n'),
        ),
        CommunityAboutCard(title: 'Created date', value: group.createdLabel),
        CommunityAboutCard(title: 'Category', value: group.category),
        CommunityAboutCard(title: 'Location', value: group.location),
        CommunityAboutCard(
          title: 'External links',
          value: group.links.join('\n'),
        ),
        CommunityAboutCard(title: 'Tags', value: group.tags.join(', ')),
        CommunityAboutCard(title: 'Contact info', value: group.contactInfo),
      ],
    );
  }
}

void _showSnack(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}
