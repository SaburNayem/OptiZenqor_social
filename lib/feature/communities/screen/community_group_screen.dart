import 'package:flutter/material.dart';

import '../controller/community_group_controller.dart';
import '../model/community_group_model.dart';

class CommunityGroupScreen extends StatefulWidget {
  const CommunityGroupScreen({required this.group, super.key});

  final CommunityGroupModel group;

  @override
  State<CommunityGroupScreen> createState() => _CommunityGroupScreenState();
}

class _CommunityGroupScreenState extends State<CommunityGroupScreen> {
  late final CommunityGroupController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CommunityGroupController(group: widget.group);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return WillPopScope(
            onWillPop: () async {
              Navigator.of(context).pop(_controller.group);
              return false;
            },
            child: Scaffold(
              body: Stack(
                children: [
                  NestedScrollView(
                    headerSliverBuilder: (context, innerScrolled) {
                      return [
                        SliverAppBar(
                          pinned: true,
                          expandedHeight: 336,
                          title: Text(_controller.group.name),
                          actions: [
                            IconButton(
                              onPressed: _showSearchInsideGroup,
                              icon: const Icon(Icons.search_rounded),
                            ),
                            IconButton(
                              onPressed: _showMoreMenu,
                              icon: const Icon(Icons.more_horiz_rounded),
                            ),
                          ],
                          flexibleSpace: FlexibleSpaceBar(
                            background: _buildHeader(context),
                          ),
                          bottom: const TabBar(
                            isScrollable: true,
                            tabs: [
                              Tab(text: 'Home'),
                              Tab(text: 'Posts'),
                              Tab(text: 'Media'),
                              Tab(text: 'Events'),
                              Tab(text: 'Members'),
                              Tab(text: 'About'),
                            ],
                          ),
                        ),
                      ];
                    },
                    body: Padding(
                      padding: const EdgeInsets.only(bottom: 98),
                      child: TabBarView(
                        children: [
                          _buildHomeTab(),
                          _buildPostsTab(),
                          _buildMediaTab(),
                          _buildEventsTab(),
                          _buildMembersTab(),
                          _buildAboutTab(),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 18,
                    child: _buildBottomBar(context),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final group = _controller.group;
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: group.coverColors.map(Color.new).toList(growable: false),
            ),
          ),
        ),
        Container(color: Colors.black.withValues(alpha: 0.24)),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 68, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(group.avatarColor),
                  child: Text(
                    group.name.characters.first,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  group.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_privacyLabel(group.privacy)} • ${group.memberCount} members',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 6),
                Text(
                  group.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: _controller.toggleJoin,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(group.joined ? 'Joined' : 'Join'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _showInviteOptions,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                        ),
                        child: const Text('Invite'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: IconButton(
                        style: IconButton.styleFrom(
                          minimumSize: const Size(44, 44),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: _showMoreMenu,
                        color: Colors.white,
                        icon: const Icon(Icons.more_horiz_rounded),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHomeTab() {
    final group = _controller.group;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _composerCard(),
        const SizedBox(height: 16),
        _quickActions(),
        const SizedBox(height: 22),
        _sectionHeader('Pinned posts'),
        ...group.pinnedPosts.map((post) => _postCard(post, adminTools: true)),
        const SizedBox(height: 18),
        _sectionHeader('Announcements'),
        ...group.announcements.map(
          (post) => _postCard(post, highlighted: true, adminTools: true),
        ),
        const SizedBox(height: 18),
        _sectionHeader('Recent activity'),
        ...group.recentActivity.map((item) => _activityTile(item)),
        const SizedBox(height: 18),
        _sectionHeader('Trending posts'),
        ...group.trendingPosts.map((post) => _postCard(post)),
        const SizedBox(height: 18),
        if (group.allowChatRoom) _groupChatCard(),
        const SizedBox(height: 18),
        _sectionHeader('Latest feed'),
        ..._controller.posts.take(4).map((post) => _postCard(post)),
      ],
    );
  }

  Widget _buildPostsTab() {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >
            notification.metrics.maxScrollExtent - 120) {
          _controller.loadMorePosts();
        }
        return false;
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Wrap(
                spacing: 8,
                children: ['Recent', 'Popular', 'Media only']
                    .map(
                      (label) => ChoiceChip(
                        label: Text(label),
                        selected: _controller.postFilter == label,
                        onSelected: (_) => _controller.setPostFilter(label),
                      ),
                    )
                    .toList(growable: false),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                onSelected: _controller.setPostFilter,
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'Recent', child: Text('Recent')),
                  PopupMenuItem(value: 'Popular', child: Text('Popular')),
                  PopupMenuItem(value: 'Media only', child: Text('Media only')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._controller.posts.map((post) => _postCard(post, adminTools: true)),
        ],
      ),
    );
  }

  Widget _buildMediaTab() {
    final items = _controller.mediaItems;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: CommunityMediaFilter.values
              .map(
                (filter) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_mediaFilterLabel(filter)),
                    selected: _controller.mediaFilter == filter,
                    onSelected: (_) => _controller.setMediaFilter(filter),
                  ),
                ),
              )
              .toList(growable: false),
        ),
        const SizedBox(height: 16),
        if (items.any((item) => !item.isVideo)) ...[
          _sectionHeader('Photos grid'),
          _mediaGrid(
            items.where((item) => !item.isVideo).toList(growable: false),
          ),
          const SizedBox(height: 18),
        ],
        if (items.any((item) => item.isVideo)) ...[
          _sectionHeader('Videos grid'),
          _mediaGrid(
            items.where((item) => item.isVideo).toList(growable: false),
          ),
          const SizedBox(height: 18),
        ],
        _sectionHeader('Albums'),
        const Row(
          children: [
            Expanded(child: _AlbumCard(title: 'Highlights', count: 12)),
            SizedBox(width: 12),
            Expanded(child: _AlbumCard(title: 'Events', count: 8)),
          ],
        ),
      ],
    );
  }

  Widget _buildEventsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionHeader('Upcoming events'),
        ..._controller.upcomingEvents.map(_eventCard),
        const SizedBox(height: 18),
        _sectionHeader('Ongoing events'),
        ..._controller.ongoingEvents.map(_eventCard),
        const SizedBox(height: 18),
        _sectionHeader('Past events'),
        ..._controller.pastEvents.map(_eventCard),
      ],
    );
  }

  Widget _buildMembersTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          onChanged: _controller.updateMemberQuery,
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
        _sectionHeader('Admins & moderators'),
        ...[..._controller.admins, ..._controller.moderators].map(_memberTile),
        const SizedBox(height: 18),
        _sectionHeader('Top contributors'),
        ..._controller.topContributors.map(_memberTile),
        const SizedBox(height: 18),
        _sectionHeader('All members'),
        ..._controller.visibleMembers.map(_memberTile),
      ],
    );
  }

  Widget _buildAboutTab() {
    final group = _controller.group;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _aboutCard('Group description', group.description),
        _aboutCard('Rules', group.rules.map((rule) => '• $rule').join('\n')),
        _aboutCard('Created date', group.createdLabel),
        _aboutCard('Category', group.category),
        _aboutCard('Location', group.location),
        _aboutCard('External links', group.links.join('\n')),
        _aboutCard('Tags', group.tags.join(', ')),
        _aboutCard('Contact info', group.contactInfo),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: _bottomAction(
                icon: Icons.edit_note_rounded,
                label: 'Create',
                onTap: _showCreatePostSheet,
              ),
            ),
            Expanded(
              child: _bottomAction(
                icon: Icons.person_add_alt_1_rounded,
                label: 'Invite',
                onTap: _showInviteOptions,
              ),
            ),
            Expanded(
              child: _bottomAction(
                icon: _controller.notificationsEnabled
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_off_rounded,
                label: 'Notify',
                onTap: _controller.toggleNotificationBell,
              ),
            ),
            Expanded(
              child: _bottomAction(
                icon: Icons.tune_rounded,
                label: 'Customize',
                onTap: _showCustomizeSheet,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _composerCard() {
    return _panel(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Color(_controller.group.avatarColor),
            child: const Icon(Icons.group_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              readOnly: true,
              onTap: _showCreatePostSheet,
              decoration: InputDecoration(
                hintText: 'Write something...',
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActions() {
    final actions = <Map<String, dynamic>>[
      {'label': 'Post', 'icon': Icons.edit_note_rounded},
      {'label': 'Photo', 'icon': Icons.photo_library_outlined},
      {'label': 'Live', 'icon': Icons.videocam_outlined},
      {'label': 'Poll', 'icon': Icons.poll_outlined},
      {'label': 'Event', 'icon': Icons.event_outlined},
    ];
    return Row(
      children: actions
          .map(
            (item) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _panel(
                  onTap: () => _showSnack('${item['label']} action'),
                  child: Column(
                    children: [
                      Icon(item['icon'] as IconData),
                      const SizedBox(height: 8),
                      Text(item['label'] as String),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }

  Widget _postCard(
    CommunityPostModel post, {
    bool highlighted = false,
    bool adminTools = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(post.authorAccent),
                  child: Text(
                    post.authorName.characters.first,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              post.authorName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          _roleBadge(post.authorRole),
                        ],
                      ),
                      Text(
                        post.timeLabel,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'save') {
                      _controller.toggleSavePost(post.id);
                    } else if (value == 'pin') {
                      _controller.togglePinPost(post.id);
                    } else {
                      _showSnack('Reported locally');
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'save',
                      child: Text(post.saved ? 'Unsave' : 'Save'),
                    ),
                    const PopupMenuItem(value: 'report', child: Text('Report')),
                    if (adminTools)
                      PopupMenuItem(
                        value: 'pin',
                        child: Text(post.pinned ? 'Unpin' : 'Pin'),
                      ),
                  ],
                ),
              ],
            ),
            if (highlighted || post.highlight) ...[
              const SizedBox(height: 10),
              const Wrap(spacing: 8, children: [_MiniPill('Announcement')]),
            ],
            const SizedBox(height: 10),
            Text(post.content),
            if (post.mediaLabel != null) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _showMediaViewer(
                  post.mediaLabel!,
                  post.type == CommunityPostType.video,
                ),
                child: Container(
                  height: 164,
                  decoration: BoxDecoration(
                    color: Color(post.authorAccent).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          post.type == CommunityPostType.video
                              ? Icons.play_circle_fill_rounded
                              : Icons.photo_outlined,
                          size: 42,
                        ),
                        const SizedBox(height: 8),
                        Text(post.mediaLabel!),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            if (post.type == CommunityPostType.poll &&
                post.pollOptions.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...post.pollOptions.map(
                (option) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: LinearProgressIndicator(
                    value: 0.2 + (post.pollOptions.indexOf(option) * 0.2),
                    borderRadius: BorderRadius.circular(999),
                    minHeight: 34,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(post.authorAccent).withValues(alpha: 0.72),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Text('${post.likes} likes'),
                const SizedBox(width: 12),
                Text('${post.comments} comments'),
                const SizedBox(width: 12),
                Text('${post.shares} shares'),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _postAction(Icons.thumb_up_alt_outlined, 'Like'),
                ),
                Expanded(
                  child: _postAction(Icons.mode_comment_outlined, 'Comment'),
                ),
                Expanded(child: _postAction(Icons.share_outlined, 'Share')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _eventCard(CommunityEventModel event) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 132,
              decoration: BoxDecoration(
                color: Color(event.coverColor).withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Icon(
                  event.locationLabel == 'Online'
                      ? Icons.wifi_tethering_rounded
                      : Icons.location_on_outlined,
                  size: 42,
                  color: Color(event.coverColor),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              event.title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(event.dateLabel),
            const SizedBox(height: 4),
            Text(event.locationLabel),
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton(
                  onPressed: () => _controller.toggleGoing(event.id),
                  child: Text(event.going ? 'Going' : 'Interested'),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: _showInviteOptions,
                  child: const Text('Invite'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _memberTile(CommunityMemberModel member) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _panel(
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(member.accentColor),
              child: Text(member.name.characters.first),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          member.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _roleBadge(member.role),
                    ],
                  ),
                  if (member.topContributor)
                    Text(
                      'Top contributor',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => _showSnack('Message ${member.name}'),
              child: const Text('Message'),
            ),
            FilledButton(
              onPressed: () => _controller.toggleFollowMember(member.id),
              child: Text(member.following ? 'Following' : 'Follow'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _aboutCard(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(value),
          ],
        ),
      ),
    );
  }

  Widget _activityTile(String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _panel(
        child: Row(
          children: [
            const Icon(Icons.bolt_rounded),
            const SizedBox(width: 10),
            Expanded(child: Text(value)),
          ],
        ),
      ),
    );
  }

  Widget _groupChatCard() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Group chat room',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Real-time group chat with reactions, media sharing, and admin controls.',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              FilledButton(
                onPressed: _showGroupChatRoom,
                child: const Text('Open chat'),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () => _showSnack('Admin chat controls'),
                child: const Text('Admin controls'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mediaGrid(List<CommunityMediaItem> items) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.12,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          onTap: () => _showMediaViewer(item.label, item.isVideo),
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Color(item.color).withValues(alpha: 0.15),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    item.isVideo
                        ? Icons.videocam_outlined
                        : Icons.photo_outlined,
                    size: 40,
                    color: Color(item.color),
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _roleBadge(CommunityRole role) {
    final label = switch (role) {
      CommunityRole.admin => 'Admin',
      CommunityRole.moderator => 'Moderator',
      CommunityRole.member => 'Member',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _postAction(IconData icon, String label) {
    return TextButton.icon(
      onPressed: () => _showSnack(label),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }

  Widget _bottomAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return TextButton(
      onPressed: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _panel({required Widget child, VoidCallback? onTap}) {
    final body = Padding(padding: const EdgeInsets.all(16), child: child);
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(22),
      child: onTap == null
          ? body
          : InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(22),
              child: body,
            ),
    );
  }

  Future<void> _showCreatePostSheet() async {
    final controller = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Create post',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Share something with the group',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showSnack('Post created locally');
                  },
                  child: const Text('Post'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showCustomizeSheet() async {
    final nameController = TextEditingController(text: _controller.group.name);
    final descriptionController = TextEditingController(
      text: _controller.group.description,
    );
    final categoryController = TextEditingController(
      text: _controller.group.category,
    );
    var privacy = _controller.group.privacy;
    var approvalRequired = _controller.group.approvalRequired;
    var allowEvents = _controller.group.allowEvents;
    var allowLive = _controller.group.allowLive;
    var allowPolls = _controller.group.allowPolls;
    var allowMarketplace = _controller.group.allowMarketplace;
    var allowChatRoom = _controller.group.allowChatRoom;
    var notifyLevel = _controller.group.notificationLevel;
    var paidMembership = false;
    var donations = true;
    var subscriptions = false;
    var contentRestrictions = true;
    var ageRestriction = false;
    var regionRestriction = 'Global';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customize group',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _sheetHeader('General'),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Edit group name',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Edit description',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Category selection',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _showSnack('Change cover locally'),
                            child: const Text('Change cover'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                _showSnack('Change avatar locally'),
                            child: const Text('Change avatar'),
                          ),
                        ),
                      ],
                    ),
                    _sheetHeader('Privacy'),
                    Wrap(
                      spacing: 8,
                      children: CommunityPrivacy.values
                          .map((item) {
                            return ChoiceChip(
                              label: Text(_privacyLabel(item)),
                              selected: privacy == item,
                              onSelected: (_) =>
                                  setModalState(() => privacy = item),
                            );
                          })
                          .toList(growable: false),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Approval required'),
                      value: approvalRequired,
                      onChanged: (value) =>
                          setModalState(() => approvalRequired = value),
                    ),
                    _sheetHeader('Posting permissions'),
                    ...[
                      'Who can post',
                      'Who can comment',
                      'Post approval toggle',
                      'Allow anonymous posts',
                    ].map(
                      (item) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(item),
                        trailing: const Icon(Icons.chevron_right_rounded),
                      ),
                    ),
                    _sheetHeader('Moderation'),
                    ...[
                      'Keyword filter',
                      'Reported posts list',
                      'Blocked users',
                      'Muted users',
                    ].map(
                      (item) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(item),
                        trailing: const Icon(Icons.chevron_right_rounded),
                      ),
                    ),
                    _sheetHeader('Notifications'),
                    Wrap(
                      spacing: 8,
                      children: CommunityNotificationLevel.values
                          .map((item) {
                            return ChoiceChip(
                              label: Text(_notificationLabel(item)),
                              selected: notifyLevel == item,
                              onSelected: (_) =>
                                  setModalState(() => notifyLevel = item),
                            );
                          })
                          .toList(growable: false),
                    ),
                    _sheetHeader('Features toggle'),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Enable events'),
                      value: allowEvents,
                      onChanged: (value) =>
                          setModalState(() => allowEvents = value),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Enable live'),
                      value: allowLive,
                      onChanged: (value) =>
                          setModalState(() => allowLive = value),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Enable polls'),
                      value: allowPolls,
                      onChanged: (value) =>
                          setModalState(() => allowPolls = value),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Enable marketplace inside group'),
                      value: allowMarketplace,
                      onChanged: (value) =>
                          setModalState(() => allowMarketplace = value),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Enable chat room'),
                      value: allowChatRoom,
                      onChanged: (value) =>
                          setModalState(() => allowChatRoom = value),
                    ),
                    _sheetHeader('Monetization'),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Paid membership'),
                      value: paidMembership,
                      onChanged: (value) =>
                          setModalState(() => paidMembership = value),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Donations'),
                      value: donations,
                      onChanged: (value) =>
                          setModalState(() => donations = value),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Subscriptions'),
                      value: subscriptions,
                      onChanged: (value) =>
                          setModalState(() => subscriptions = value),
                    ),
                    _sheetHeader('Safety'),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Content restrictions'),
                      value: contentRestrictions,
                      onChanged: (value) =>
                          setModalState(() => contentRestrictions = value),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Age restriction'),
                      value: ageRestriction,
                      onChanged: (value) =>
                          setModalState(() => ageRestriction = value),
                    ),
                    DropdownButtonFormField<String>(
                      value: regionRestriction,
                      items: const [
                        DropdownMenuItem(
                          value: 'Global',
                          child: Text('Global'),
                        ),
                        DropdownMenuItem(value: 'Asia', child: Text('Asia')),
                        DropdownMenuItem(
                          value: 'Europe',
                          child: Text('Europe'),
                        ),
                      ],
                      onChanged: (value) => setModalState(
                        () => regionRestriction = value ?? 'Global',
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Region restriction',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          _controller.updateGeneral(
                            name: nameController.text,
                            description: descriptionController.text,
                            category: categoryController.text,
                          );
                          _controller.updatePrivacy(
                            privacy: privacy,
                            approvalRequired: approvalRequired,
                          );
                          _controller.updateFeatures(
                            events: allowEvents,
                            live: allowLive,
                            polls: allowPolls,
                            marketplace: allowMarketplace,
                            chatRoom: allowChatRoom,
                          );
                          _controller.setNotificationLevel(notifyLevel);
                          Navigator.of(context).pop();
                        },
                        child: const Text('Save settings'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _sheetHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
    );
  }

  Future<void> _showInviteOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return const SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.link_rounded),
                title: Text('Invite via link'),
              ),
              ListTile(
                leading: Icon(Icons.qr_code_rounded),
                title: Text('QR invite'),
              ),
              ListTile(
                leading: Icon(Icons.person_add_alt_1_rounded),
                title: Text('Invite members'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showGroupChatRoom() async {
    final inputController = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Group chat room',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              const _ChatBubble(
                sender: 'Sadia',
                message: 'Welcome everyone to the room.',
              ),
              const _ChatBubble(
                sender: 'Riyad',
                message: 'Sharing the event deck soon.',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: inputController,
                      decoration: const InputDecoration(
                        hintText: 'Message the room',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: () => _showSnack('Message sent locally'),
                    child: const Text('Send'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showSearchInsideGroup() async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search inside group'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Search posts, events, hashtags',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showSnack('Search: ${controller.text.trim()}');
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showMoreMenu() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return const SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.push_pin_outlined),
                title: Text('Pinned posts'),
              ),
              ListTile(
                leading: Icon(Icons.schedule_outlined),
                title: Text('Scheduled posts'),
              ),
              ListTile(
                leading: Icon(Icons.drafts_outlined),
                title: Text('Draft posts'),
              ),
              ListTile(
                leading: Icon(Icons.tag_rounded),
                title: Text('Hashtags inside group'),
              ),
              ListTile(
                leading: Icon(Icons.fact_check_outlined),
                title: Text('Member requests approval'),
              ),
              ListTile(
                leading: Icon(Icons.manage_history_outlined),
                title: Text('Activity log'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showMediaViewer(String label, bool isVideo) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(18),
            height: 320,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isVideo ? Icons.videocam_rounded : Icons.photo_rounded,
                  size: 58,
                ),
                const SizedBox(height: 14),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isVideo
                      ? 'Full video viewer preview'
                      : 'Full photo viewer preview',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _privacyLabel(CommunityPrivacy privacy) {
    switch (privacy) {
      case CommunityPrivacy.public:
        return 'Public';
      case CommunityPrivacy.private:
        return 'Private';
      case CommunityPrivacy.hidden:
        return 'Hidden';
    }
  }

  String _notificationLabel(CommunityNotificationLevel level) {
    switch (level) {
      case CommunityNotificationLevel.all:
        return 'All posts';
      case CommunityNotificationLevel.highlights:
        return 'Highlights only';
      case CommunityNotificationLevel.off:
        return 'Off';
    }
  }

  String _mediaFilterLabel(CommunityMediaFilter filter) {
    switch (filter) {
      case CommunityMediaFilter.all:
        return 'All';
      case CommunityMediaFilter.photos:
        return 'Photos';
      case CommunityMediaFilter.videos:
        return 'Videos';
    }
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _AlbumCard extends StatelessWidget {
  const _AlbumCard({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context).colorScheme.surfaceContainerLow,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.collections_outlined),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text('$count items'),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.sender, required this.message});

  final String sender;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(sender, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(message),
        ],
      ),
    );
  }
}
