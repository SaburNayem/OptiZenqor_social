part of 'pages_screen.dart';

class _PageDetailScreen extends StatelessWidget {
  const _PageDetailScreen({required this.controller, required this.pageId});

  final PagesController controller;
  final String pageId;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final page = controller.pageById(pageId);
        final isManaged = controller.isManagedPage(page);

        return Scaffold(
          appBar: AppBar(
            title: Text(page.name),
            actions: [
              IconButton(
                onPressed: () => _copyPageLink(page),
                icon: const Icon(Icons.share_outlined),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _PageCoverImage(
                    imageUrl: page.coverUrl,
                    title: page.name,
                    height: 220,
                  ),
                  Positioned(
                    left: 20,
                    bottom: -34,
                    child: CircleAvatar(
                      radius: 38,
                      backgroundColor: AppColors.white,
                      child: _PageAvatar(page: page, radius: 34),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 44),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            page.name,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        if (page.verified)
                          const Icon(
                            Icons.verified_rounded,
                            color: AppColors.hexFF2563EB,
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (_pageMetaLine(page).isNotEmpty)
                      Text(
                        _pageMetaLine(page),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    const SizedBox(height: 14),
                    Text(
                      page.about,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(height: 1.4),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _PagesStatCard(
                            label: 'Followers',
                            value: _formatCount(page.followersCount),
                            icon: Icons.groups_rounded,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _PagesStatCard(
                            label: 'Likes',
                            value: _formatCount(page.likesCount),
                            icon: Icons.thumb_up_alt_outlined,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _PagesStatCard(
                            label: 'Updates',
                            value: '${page.posts.length}',
                            icon: Icons.campaign_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    if (page.highlights.isNotEmpty) ...[
                      const _SectionTitle(
                        title: 'Highlights',
                        subtitle: 'Key topics and recurring audience interests',
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: page.highlights
                            .map((item) => _MiniPill(label: item))
                            .toList(),
                      ),
                      const SizedBox(height: 22),
                    ],
                    const _SectionTitle(
                      title: 'Latest updates',
                      subtitle: 'Recent posts and announcements from this page',
                    ),
                    const SizedBox(height: 10),
                    ...page.posts.map(
                      (post) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(post),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const _SectionTitle(
                      title: 'Page tools',
                      subtitle: 'Reviews, visitor posts, and audience health',
                    ),
                    const SizedBox(height: 10),
                    _InfoCard(title: 'Reviews', body: page.reviewSummary),
                    const SizedBox(height: 10),
                    _InfoCard(
                      title: 'Visitor posts',
                      body: page.visitorPostsSummary,
                    ),
                    const SizedBox(height: 10),
                    _InfoCard(
                      title: 'Follower insights',
                      body: page.followersInsight,
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: isManaged
                        ? () => AppGet.snackbar('Pages', 'Manage tools opened')
                        : () => controller.toggleFollow(page.id),
                    child: Text(
                      isManaged
                          ? 'Manage page'
                          : page.following
                          ? 'Following'
                          : 'Follow page',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => AppGet.snackbar(
                      'Pages',
                      isManaged
                          ? 'Insights opened'
                          : '${_pageContactLabel(page)} action opened',
                    ),
                    child: Text(
                      isManaged ? 'Insights' : _pageContactLabel(page),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _copyPageLink(PageModel page) async {
    final link = page.shareUrl.trim();
    if (link.isEmpty) {
      AppGet.snackbar(
        'Pages',
        'This page does not have a backend share link yet.',
      );
      return;
    }
    await Clipboard.setData(ClipboardData(text: link));
    AppGet.snackbar('Pages', 'Page link copied');
  }
}

class _PageCoverImage extends StatelessWidget {
  const _PageCoverImage({
    required this.imageUrl,
    required this.title,
    required this.height,
  });

  final String imageUrl;
  final String title;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.trim().isEmpty) {
      return Container(
        height: height,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[AppColors.hexFF0F172A, AppColors.hexFF2563EB],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.all(16),
        child: Text(
          title.trim().isEmpty ? 'Page' : title.trim(),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    return Image.network(
      imageUrl,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          _PageCoverImage(imageUrl: '', title: title, height: height),
    );
  }
}

class _PageAvatar extends StatelessWidget {
  const _PageAvatar({required this.page, required this.radius});

  final PageModel page;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final String initials = _pageInitials(page.name);
    if (page.avatarUrl.trim().isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.hexFF2563EB.withValues(alpha: 0.14),
        child: Text(
          initials,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.hexFF2563EB,
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundImage: NetworkImage(page.avatarUrl),
      onBackgroundImageError: (error, stackTrace) {},
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(body),
        ],
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label),
    );
  }
}

String _formatCount(int value) {
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}M';
  }
  if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(1)}K';
  }
  return '$value';
}

String _pageFollowLabel(PageModel page) {
  if (page.actionButtonLabel.trim().isNotEmpty) {
    return page.actionButtonLabel.trim();
  }
  return page.following ? 'Following' : 'Follow page';
}

String _pageMetaLine(PageModel page) {
  final List<String> parts = <String>[
    if (page.category.trim().isNotEmpty) page.category.trim(),
    if (page.location.trim().isNotEmpty) page.location.trim(),
  ];
  return parts.join(' • ');
}

String _pageContactLabel(PageModel page) {
  return page.contactLabel.trim().isEmpty
      ? 'Contact'
      : page.contactLabel.trim();
}

String _pageInitials(String name) {
  final List<String> parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList(growable: false);
  if (parts.isEmpty) {
    return 'P';
  }
  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }
  return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
}
