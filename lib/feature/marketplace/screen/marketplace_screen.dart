import 'package:flutter/material.dart';

import '../controller/marketplace_controller.dart';
import '../model/marketplace_filter_model.dart';
import '../model/product_model.dart';
import '../widget/category_chip.dart';
import '../widget/product_card.dart';
import 'marketplace_filter_sheet.dart';
import 'my_listings_screen.dart';
import 'product_details_screen.dart';
import 'saved_items_screen.dart';
import 'sell_product_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  late final MarketplaceController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = MarketplaceController()..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return DefaultTabController(
          length: 5,
          child: Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (context, _) {
                return [
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: 300,
                    surfaceTintColor: Colors.transparent,
                    flexibleSpace: FlexibleSpaceBar(
                      background: _Header(
                        controller: _controller,
                        searchController: _searchController,
                        onFilterTap: _openFilters,
                      ),
                    ),
                  ),
                ];
              },
              body: Column(
                children: [
                  const Material(
                    color: Colors.white,
                    child: TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      tabs: [
                        Tab(text: 'Browse'),
                        Tab(text: 'Categories'),
                        Tab(text: 'Sell'),
                        Tab(text: 'My Listings'),
                        Tab(text: 'Saved'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _BrowseTab(controller: _controller),
                        _CategoriesTab(controller: _controller),
                        SellProductScreen(controller: _controller),
                        MyListingsScreen(controller: _controller),
                        SavedItemsScreen(controller: _controller),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openFilters() async {
    final result = await showModalBottomSheet<MarketplaceFilterModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => MarketplaceFilterSheet(
        initialFilter: _controller.filter,
        categories: _controller.categories.map((item) => item.name).toList(),
      ),
    );
    if (result != null) {
      _controller.updateFilter(result);
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.controller,
    required this.searchController,
    required this.onFilterTap,
  });

  final MarketplaceController controller;
  final TextEditingController searchController;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 36, 16, 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.surface,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Marketplace',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _showNotifications(context, controller),
                  icon: const Icon(Icons.notifications_none_rounded),
                ),
                Builder(
                  builder: (context) {
                    return IconButton(
                      onPressed: () =>
                          DefaultTabController.of(context).animateTo(4),
                      icon: const Icon(Icons.bookmark_border_rounded),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: searchController,
              onChanged: controller.updateSearch,
              decoration: const InputDecoration(
                hintText: 'Search products, brands, categories',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                CategoryChip(
                  label: controller.selectedLocation,
                  selected: true,
                  leading: const Icon(Icons.place_outlined, size: 18),
                  onTap: () => _showLocations(context, controller),
                ),
                CategoryChip(
                  label: controller.selectedCategory == 'All'
                      ? 'Categories'
                      : controller.selectedCategory,
                  selected: false,
                  leading: const Icon(Icons.grid_view_rounded, size: 18),
                  onTap: () => _showCategoryPicker(context, controller),
                ),
                CategoryChip(
                  label: 'Filters',
                  selected: false,
                  leading: const Icon(Icons.tune_rounded, size: 18),
                  onTap: onFilterTap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showLocations(BuildContext context, MarketplaceController controller) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              for (final location in const [
                'Dhaka, Bangladesh',
                'Chattogram, Bangladesh',
                'Remote / Nationwide',
              ])
                ListTile(
                  leading: const Icon(Icons.place_outlined),
                  title: Text(location),
                  onTap: () {
                    controller.selectLocation(location);
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showCategoryPicker(
    BuildContext context,
    MarketplaceController controller,
  ) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: const Text('All'),
                onTap: () {
                  controller.selectCategory('All');
                  Navigator.of(context).pop();
                },
              ),
              ...controller.categories.map(
                (category) => ListTile(
                  leading: Icon(category.icon),
                  title: Text(category.name),
                  onTap: () {
                    controller.selectCategory(category.name);
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNotifications(
    BuildContext context,
    MarketplaceController controller,
  ) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Marketplace notifications',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ...controller.notifications.map(
                (item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.notifications_active_outlined),
                  title: Text(item),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BrowseTab extends StatelessWidget {
  const _BrowseTab({required this.controller});

  final MarketplaceController controller;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.extentAfter < 300) {
          controller.loadMoreBrowse();
        }
        return false;
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _browseSearchCard(context),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _quickFilters(),
            ),
          ),
          _SectionTitle(title: 'Featured items', action: 'View all'),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 280,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: controller.featuredItems.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final item = controller.featuredItems[index];
                  return SizedBox(
                    width: 240,
                    child: ProductCard(
                      product: item,
                      controller: controller,
                      onTap: () => _openDetails(context, item),
                    ),
                  );
                },
              ),
            ),
          ),
          _SectionTitle(
            title: 'Recommended items',
            action: controller.isGridMode ? 'List view' : 'Grid view',
            onActionTap: controller.toggleGridMode,
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: controller.isGridMode
                ? SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final item = controller.recommendedItems[index];
                      return ProductCard(
                        product: item,
                        controller: controller,
                        onTap: () => _openDetails(context, item),
                      );
                    }, childCount: controller.recommendedItems.length),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.72,
                        ),
                  )
                : SliverList.separated(
                    itemCount: controller.recommendedItems.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = controller.recommendedItems[index];
                      return ProductCard(
                        product: item,
                        compact: true,
                        controller: controller,
                        onTap: () => _openDetails(context, item),
                      );
                    },
                  ),
          ),
          _SectionTitle(title: 'Trending categories'),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 54,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: controller.categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final category = controller.categories[index];
                  return CategoryChip(
                    label: category.name,
                    selected: category.isFollowed,
                    leading: Icon(category.icon, size: 18),
                    onTap: () => controller.toggleFollowCategory(category.name),
                  );
                },
              ),
            ),
          ),
          _SectionTitle(title: 'Recently viewed items'),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 160,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: controller.recentlyViewedItems.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final item = controller.recentlyViewedItems[index];
                  return SizedBox(
                    width: 260,
                    child: ProductCard(
                      product: item,
                      compact: true,
                      controller: controller,
                      onTap: () => _openDetails(context, item),
                    ),
                  );
                },
              ),
            ),
          ),
          _SectionTitle(title: 'Main product feed'),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList.separated(
              itemCount: controller.filteredProducts.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == controller.filteredProducts.length) {
                  return Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(
                      child: Text('Pulling more listings...'),
                    ),
                  );
                }
                final item = controller.filteredProducts[index];
                return ProductCard(
                  product: item,
                  compact: true,
                  controller: controller,
                  onTap: () => _openDetails(context, item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _browseSearchCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search bar with insights',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(
            'Recent searches',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.recentSearches
                .map(
                  (search) => ActionChip(
                    label: Text(search),
                    onPressed: () => controller.updateSearch(search),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 14),
          Chip(
            avatar: const Icon(Icons.place_outlined, size: 18),
            label: Text(controller.selectedLocation),
          ),
          const SizedBox(height: 14),
          Text(
            'Suggested searches',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.savedSearches
                .map(
                  (search) => ActionChip(
                    label: Text(search),
                    onPressed: () => controller.updateSearch(search),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 14),
          Text(
            'Trending searches',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.trendingSearches
                .map(
                  (search) => ActionChip(
                    label: Text(search),
                    onPressed: () => controller.updateSearch(search),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _quickFilters() {
    const filters = [
      'Nearby',
      'New today',
      'Price low to high',
      'Price high to low',
      'Delivery',
      'Negotiable',
    ];
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = filters[index];
          return CategoryChip(
            label: item,
            selected: controller.selectedQuickFilter == item,
            onTap: () => controller.selectQuickFilter(item),
          );
        },
      ),
    );
  }

  void _openDetails(BuildContext context, ProductModel item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            ProductDetailsScreen(controller: controller, productId: item.id),
      ),
    );
  }
}

class _CategoriesTab extends StatelessWidget {
  const _CategoriesTab({required this.controller});

  final MarketplaceController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
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
