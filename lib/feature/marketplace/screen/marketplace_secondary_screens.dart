part of 'marketplace_screen.dart';

class MarketplaceFeaturedItemsScreen extends StatefulWidget {
  const MarketplaceFeaturedItemsScreen({super.key, required this.controller});

  final MarketplaceController controller;

  @override
  State<MarketplaceFeaturedItemsScreen> createState() =>
      _MarketplaceFeaturedItemsScreenState();
}

class _MarketplaceFeaturedItemsScreenState
    extends State<MarketplaceFeaturedItemsScreen> {
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final featuredItems = controller.featuredItems;

    return Scaffold(
      backgroundColor: AppColors.hexFFF8FAFC,
      appBar: AppBar(title: const Text('Featured items')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Container(
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
                  'Featured marketplace picks',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Browse highlighted listings selected for stronger visibility, demand, and freshness.',
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _FeaturedStatPill(label: '${featuredItems.length} items'),
                    _FeaturedStatPill(label: controller.selectedLocation),
                    _FeaturedStatPill(
                      label: _isGridView ? 'Grid view' : 'List view',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                'All featured listings',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment<bool>(
                    value: true,
                    icon: Icon(Icons.grid_view_rounded),
                    label: Text('Grid'),
                  ),
                  ButtonSegment<bool>(
                    value: false,
                    icon: Icon(Icons.view_agenda_outlined),
                    label: Text('List'),
                  ),
                ],
                selected: <bool>{_isGridView},
                onSelectionChanged: (selection) {
                  setState(() {
                    _isGridView = selection.first;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isGridView)
            GridView.builder(
              itemCount: featuredItems.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, index) {
                final item = featuredItems[index];
                return ProductCard(
                  product: item,
                  controller: controller,
                  onTap: () => _openDetails(context, item, controller),
                );
              },
            )
          else
            ListView.separated(
              itemCount: featuredItems.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = featuredItems[index];
                return ProductCard(
                  product: item,
                  compact: true,
                  controller: controller,
                  onTap: () => _openDetails(context, item, controller),
                );
              },
            ),
        ],
      ),
    );
  }

  void _openDetails(
    BuildContext context,
    ProductModel item,
    MarketplaceController controller,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            ProductDetailsScreen(controller: controller, productId: item.id),
      ),
    );
  }
}

class MarketplaceSearchScreen extends StatefulWidget {
  const MarketplaceSearchScreen({
    super.key,
    required this.controller,
    required this.initialQuery,
  });

  final MarketplaceController controller;
  final String initialQuery;

  @override
  State<MarketplaceSearchScreen> createState() =>
      _MarketplaceSearchScreenState();
}

class _MarketplaceSearchScreenState extends State<MarketplaceSearchScreen> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _applySearch(String value) {
    _controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    widget.controller.updateSearch(value);
  }

  List<String> get _liveSuggestions {
    final query = _controller.text.trim().toLowerCase();
    final source = <String>{
      ...widget.controller.recentSearches,
      ...widget.controller.savedSearches,
      ...widget.controller.trendingSearches,
      ...widget.controller.categories.map((item) => item.name),
    }.toList();

    if (query.isEmpty) {
      return source.take(6).toList();
    }

    return source
        .where((item) => item.toLowerCase().contains(query))
        .take(8)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.hexFFF8FAFC,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final suggestions = _liveSuggestions;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: <Color>[
                        AppColors.hexFF0F172A,
                        AppColors.hexFF1D4ED8,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.white.withValues(
                                alpha: 0.14,
                              ),
                            ),
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Search Marketplace',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(
                              context,
                            ).pop(_controller.text.trim()),
                            child: const Text(
                              'Done',
                              style: TextStyle(color: AppColors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          autofocus: true,
                          onChanged: (value) {
                            setState(() {});
                            widget.controller.updateSearch(value);
                          },
                          onSubmitted: (value) =>
                              Navigator.of(context).pop(value.trim()),
                          decoration: InputDecoration(
                            hintText: 'Search products, brands, categories',
                            border: InputBorder.none,
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: _controller.text.trim().isEmpty
                                ? null
                                : IconButton(
                                    onPressed: () {
                                      _controller.clear();
                                      setState(() {});
                                      widget.controller.updateSearch('');
                                      _focusNode.requestFocus();
                                    },
                                    icon: const Icon(Icons.close_rounded),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Suggestions update as you type, with quick access to recent and trending searches.',
                        style: TextStyle(
                          color: AppColors.white.withValues(alpha: 0.78),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                if (suggestions.isNotEmpty) ...[
                  _SearchSuggestionCard(
                    title: 'Suggestions',
                    subtitle: 'Tap a suggestion to search instantly',
                    children: suggestions
                        .map(
                          (item) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.north_west_rounded),
                            title: Text(item),
                            onTap: () => Navigator.of(context).pop(item),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                ],
                _SearchInsightsPanel(
                  controller: widget.controller,
                  onSearchSelected: _applySearch,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SearchInsightsPanel extends StatelessWidget {
  const _SearchInsightsPanel({
    required this.controller,
    required this.onSearchSelected,
  });

  final MarketplaceController controller;
  final ValueChanged<String> onSearchSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
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
          _SearchInsightSection(
            title: 'Recent searches',
            children: controller.recentSearches
                .map(
                  (search) => ActionChip(
                    label: Text(search),
                    onPressed: () => onSearchSelected(search),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Chip(
            avatar: const Icon(Icons.place_outlined, size: 18),
            label: Text(controller.selectedLocation),
          ),
          const SizedBox(height: 12),
          _SearchInsightSection(
            title: 'Suggested searches',
            children: controller.savedSearches
                .map(
                  (search) => ActionChip(
                    label: Text(search),
                    onPressed: () => onSearchSelected(search),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          _SearchInsightSection(
            title: 'Trending searches',
            children: controller.trendingSearches
                .map(
                  (search) => ActionChip(
                    label: Text(search),
                    onPressed: () => onSearchSelected(search),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SearchInsightSection extends StatelessWidget {
  const _SearchInsightSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: children),
      ],
    );
  }
}

class _SearchSuggestionCard extends StatelessWidget {
  const _SearchSuggestionCard({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.hexFF64748B),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _FeaturedStatPill extends StatelessWidget {
  const _FeaturedStatPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CategoriesTab extends StatelessWidget {
  const _CategoriesTab({required this.controller});

  final MarketplaceController controller;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Text(
            'Browse all categories',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          GridView.builder(
            itemCount: controller.categories.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, index) {
              final category = controller.categories[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      child: Icon(category.icon),
                    ),
                    const Spacer(),
                    Text(
                      category.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.subcategories.join(' • '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    FilledButton.tonal(
                      onPressed: () =>
                          controller.toggleFollowCategory(category.name),
                      child: Text(
                        category.isFollowed ? 'Following' : 'Follow category',
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text('Subcategories', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          ...controller.categories.map(
            (category) => ExpansionTile(
              leading: Icon(category.icon),
              title: Text(category.name),
              children: category.subcategories
                  .map(
                    (sub) => ListTile(
                      title: Text(sub),
                      onTap: () => controller.selectCategory(category.name),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.action, this.onActionTap});

  final String title;
  final String? action;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
            if (action != null)
              TextButton(onPressed: onActionTap, child: Text(action!)),
          ],
        ),
      ),
    );
  }
}
