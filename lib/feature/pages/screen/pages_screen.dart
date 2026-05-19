import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/navigation/app_get.dart';
import '../../auth/repository/auth_repository.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../controller/pages_controller.dart';
import '../model/page_model.dart';

part 'pages_detail_sections.dart';

class PagesScreen extends StatefulWidget {
  const PagesScreen({super.key});

  @override
  State<PagesScreen> createState() => _PagesScreenState();
}

class _PagesScreenState extends State<PagesScreen> {
  late final PagesController _controller;
  bool _canCreatePage = false;

  @override
  void initState() {
    super.initState();
    _controller = PagesController()..load();
    _loadPermissions();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadPermissions() async {
    final user = await AuthRepository().currentUser();
    if (!mounted) {
      return;
    }
    setState(() {
      _canCreatePage =
          user?.role == UserRole.creator || user?.role == UserRole.admin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final visiblePages = _controller.visiblePages;
        return Scaffold(
          appBar: AppBar(title: const Text('Pages')),
          floatingActionButton: _canCreatePage
              ? FloatingActionButton.extended(
                  onPressed: _showCreatePageSheet,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Create page'),
                )
              : null,
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            children: [
              _PagesHeroCard(
                canCreatePage: _canCreatePage,
                onCreateTap: _showCreatePageSheet,
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: _controller.updateQuery,
                decoration: InputDecoration(
                  hintText: 'Search pages',
                  prefixIcon: const Icon(Icons.search_rounded),
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
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ChoiceChip(
                    label: const Text('Discover'),
                    selected:
                        _controller.selectedFilter == PagesViewFilter.discover,
                    onSelected: (_) =>
                        _controller.selectFilter(PagesViewFilter.discover),
                  ),
                  ChoiceChip(
                    label: Text(
                      'Following ${_controller.followingPages.length}',
                    ),
                    selected:
                        _controller.selectedFilter == PagesViewFilter.following,
                    onSelected: (_) =>
                        _controller.selectFilter(PagesViewFilter.following),
                  ),
                  ChoiceChip(
                    label: Text('Managed ${_controller.managedPages.length}'),
                    selected:
                        _controller.selectedFilter == PagesViewFilter.managed,
                    onSelected: (_) =>
                        _controller.selectFilter(PagesViewFilter.managed),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _PagesStatCard(
                      label: 'Managed',
                      value: '${_controller.managedPages.length}',
                      icon: Icons.badge_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _PagesStatCard(
                      label: 'Following',
                      value: '${_controller.followingPages.length}',
                      icon: Icons.favorite_outline_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _PagesStatCard(
                      label: 'Posts',
                      value: '${_controller.totalPosts}',
                      icon: Icons.article_outlined,
                    ),
                  ),
                ],
              ),
              if (_controller.selectedFilter == PagesViewFilter.discover &&
                  _controller.featuredPages.isNotEmpty) ...[
                const SizedBox(height: 24),
                _SectionTitle(
                  title: 'Featured pages',
                  subtitle: 'Discover pages with strong audience activity',
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 240,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _controller.featuredPages.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final page = _controller.featuredPages[index];
                      return SizedBox(
                        width: 250,
                        child: _FeaturedPageCard(
                          page: page,
                          isManaged: _controller.isManagedPage(page),
                          onTap: () => _openPageDetail(page.id),
                          onFollowTap: () => _controller.toggleFollow(page.id),
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 24),
              _SectionTitle(
                title: _sectionTitleForFilter(_controller.selectedFilter),
                subtitle: _sectionSubtitleForFilter(_controller.selectedFilter),
              ),
              const SizedBox(height: 12),
              if (visiblePages.isEmpty)
                EmptyStateView(
                  title: 'No pages found',
                  message: _controller.selectedFilter == PagesViewFilter.managed
                      ? 'Create your first page to start posting updates, building followers, and growing your public presence.'
                      : 'Try a different search or switch filters to browse more pages.',
                  actionLabel:
                      _controller.selectedFilter == PagesViewFilter.managed
                      ? (_canCreatePage ? 'Create page' : null)
                      : null,
                  onAction:
                      _controller.selectedFilter == PagesViewFilter.managed &&
                          _canCreatePage
                      ? _showCreatePageSheet
                      : null,
                )
              else
                ...visiblePages.map(
                  (page) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _PageListCard(
                      page: page,
                      isManaged: _controller.isManagedPage(page),
                      onTap: () => _openPageDetail(page.id),
                      onFollowTap: () => _controller.toggleFollow(page.id),
                      onShareTap: () => _copyPageLink(page),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _sectionTitleForFilter(PagesViewFilter filter) {
    switch (filter) {
      case PagesViewFilter.discover:
        return 'Browse all pages';
      case PagesViewFilter.following:
        return 'Pages you follow';
      case PagesViewFilter.managed:
        return 'Pages you manage';
    }
  }

  String _sectionSubtitleForFilter(PagesViewFilter filter) {
    switch (filter) {
      case PagesViewFilter.discover:
        return 'Official brands, creator hubs, communities, and public updates';
      case PagesViewFilter.following:
        return 'Quick access to the pages already in your feed';
      case PagesViewFilter.managed:
        return 'Open, update, and grow the pages connected to your account';
    }
  }

  Future<void> _showCreatePageSheet() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _CreatePageSheet(controller: _controller),
    );
    if (created == true) {
      AppGet.snackbar('Pages', 'Page created successfully');
    }
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

  Future<void> _openPageDetail(String pageId) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            _PageDetailScreen(controller: _controller, pageId: pageId),
      ),
    );
  }
}

class _PagesHeroCard extends StatelessWidget {
  const _PagesHeroCard({
    required this.canCreatePage,
    required this.onCreateTap,
  });

  final bool canCreatePage;
  final VoidCallback onCreateTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[AppColors.hexFF0F172A, AppColors.hexFF1D4ED8],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Build your public presence with Pages',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a page for your brand, community, shop, or creator identity and manage updates from one place.',
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.82),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          if (canCreatePage)
            FilledButton.icon(
              onPressed: onCreateTap,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.hexFF0F172A,
              ),
              icon: const Icon(Icons.add_business_outlined),
              label: const Text('Create your page'),
            ),
        ],
      ),
    );
  }
}

class _CreatePageSheet extends StatefulWidget {
  const _CreatePageSheet({required this.controller});

  final PagesController controller;

  @override
  State<_CreatePageSheet> createState() => _CreatePageSheetState();
}

class _CreatePageSheetState extends State<_CreatePageSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _aboutController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _categoryController = TextEditingController();
    _aboutController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final category = _categoryController.text.trim();
    final about = _aboutController.text.trim();
    if (name.isEmpty || category.isEmpty || about.isEmpty) {
      AppGet.snackbar('Pages', 'Fill in page name, category, and about');
      return;
    }
    widget.controller.createPage(name: name, about: about, category: category);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Create page',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Page name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _categoryController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _aboutController,
                minLines: 3,
                maxLines: 4,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(labelText: 'About this page'),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submit,
                  child: const Text('Create page'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PagesStatCard extends StatelessWidget {
  const _PagesStatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.hexFF1D4ED8),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(label),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(subtitle),
      ],
    );
  }
}

class _FeaturedPageCard extends StatelessWidget {
  const _FeaturedPageCard({
    required this.page,
    required this.isManaged,
    required this.onTap,
    required this.onFollowTap,
  });

  final PageModel page;
  final bool isManaged;
  final VoidCallback onTap;
  final VoidCallback onFollowTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.hex12000000,
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: _PageCoverImage(
                imageUrl: page.coverUrl,
                title: page.name,
                height: 108,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _PageAvatar(page: page, radius: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    page.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                if (page.verified) ...[
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.verified_rounded,
                                    size: 18,
                                    color: AppColors.hexFF2563EB,
                                  ),
                                ],
                              ],
                            ),
                            if (page.category.trim().isNotEmpty)
                              Text(
                                page.category,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (page.about.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      page.about,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MiniPill(label: _formatCount(page.followersCount)),
                      _MiniPill(label: '${page.posts.length} updates'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonal(
                      onPressed: isManaged ? onTap : onFollowTap,
                      child: Text(
                        isManaged ? 'Manage page' : _pageFollowLabel(page),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageListCard extends StatelessWidget {
  const _PageListCard({
    required this.page,
    required this.isManaged,
    required this.onTap,
    required this.onFollowTap,
    required this.onShareTap,
  });

  final PageModel page;
  final bool isManaged;
  final VoidCallback onTap;
  final VoidCallback onFollowTap;
  final VoidCallback onShareTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: _PageCoverImage(
                imageUrl: page.coverUrl,
                title: page.name,
                height: 140,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _PageAvatar(page: page, radius: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    page.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                ),
                                if (page.verified) ...[
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.verified_rounded,
                                    size: 18,
                                    color: AppColors.hexFF2563EB,
                                  ),
                                ],
                              ],
                            ),
                            if (_pageMetaLine(page).isNotEmpty)
                              Text(
                                _pageMetaLine(page),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: onShareTap,
                        icon: const Icon(Icons.share_outlined),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    page.about,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MiniPill(
                        label: '${_formatCount(page.followersCount)} followers',
                      ),
                      _MiniPill(
                        label: '${_formatCount(page.likesCount)} likes',
                      ),
                      _MiniPill(label: '${page.posts.length} updates'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: isManaged ? onTap : onFollowTap,
                          child: Text(
                            isManaged
                                ? 'Manage'
                                : page.following
                                ? 'Following'
                                : 'Follow',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onTap,
                          child: Text(isManaged ? 'Open page' : 'View page'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
