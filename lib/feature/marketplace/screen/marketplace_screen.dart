import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app_route/route_names.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/enums/user_role.dart';
import '../../auth/repository/auth_repository.dart';
import '../../account_switching/repository/account_switching_repository.dart';
import '../../home_feed/controller/main_shell_controller.dart';
import '../../verification_request/model/verification_request_model.dart';
import '../../verification_request/repository/verification_request_repository.dart';
import '../../verification_request/screen/verification_request_screen.dart';
import '../controller/marketplace_controller.dart';
import '../model/marketplace_filter_model.dart';
import '../model/product_model.dart';
import '../widget/category_chip.dart';
import '../widget/product_card.dart';
import 'marketplace_create_listing_screen.dart';
import 'marketplace_filter_sheet.dart';
import 'my_listings_screen.dart';
import 'product_details_screen.dart';
import 'saved_items_screen.dart';
import '../../../core/constants/app_colors.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  late final MarketplaceController _controller;
  final TextEditingController _searchController = TextEditingController();
  bool _isCheckingCreateAccess = false;

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
        if (_controller.errorMessage != null &&
            _controller.allProducts.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              surfaceTintColor: AppColors.transparent,
              leading: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              title: const Text('Marketplace'),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      _controller.errorMessage!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _controller.load,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(
              surfaceTintColor: AppColors.transparent,
              leading: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              title: const Text('Marketplace'),
              actions: [
                IconButton(
                  tooltip: 'Add product',
                  onPressed: _isCheckingCreateAccess
                      ? null
                      : _handleCreateListingTap,
                  icon: _isCheckingCreateAccess
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add_rounded),
                ),
              ],
            ),
            body: Column(
              children: [
                _Header(
                  controller: _controller,
                  searchController: _searchController,
                  onFilterTap: _openFilters,
                ),
                const Material(
                  color: AppColors.white,
                  child: TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    tabs: [
                      Tab(text: 'Browse'),
                      Tab(text: 'Categories'),
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
                      MyListingsScreen(controller: _controller),
                      SavedItemsScreen(controller: _controller),
                    ],
                  ),
                ),
              ],
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

  Future<void> _handleCreateListingTap() async {
    if (_isCheckingCreateAccess) {
      return;
    }
    final returnRouteName =
        ModalRoute.of(context)?.settings.name ?? RouteNames.marketplace;

    setState(() {
      _isCheckingCreateAccess = true;
    });

    final activeUser = await _resolveActiveUser();
    final request = await VerificationRequestRepository().load();
    final canCreate = _canCreateListing(activeUser, request);

    if (!mounted) {
      return;
    }

    setState(() {
      _isCheckingCreateAccess = false;
    });

    if (canCreate) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => MarketplaceCreateListingScreen(
            controller: _controller,
            activeUser: activeUser,
          ),
        ),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VerificationRequestScreen(
          returnRouteName: returnRouteName,
          completionTargetLabel: 'Marketplace',
          requestedForUser: activeUser,
        ),
      ),
    );
  }

  Future<UserModel> _resolveActiveUser() async {
    final UserModel? shellUser = context
        .read<MainShellController>()
        .currentUser;
    final activeAccountId = await AccountSwitchingRepository()
        .readActiveAccountId();
    final UserModel? sessionUser = await AuthRepository().currentUser();
    if (activeAccountId == null || activeAccountId.trim().isEmpty) {
      return sessionUser ??
          shellUser ??
          const UserModel(
            id: '',
            name: '',
            username: '',
            avatar: '',
            bio: '',
            role: UserRole.guest,
            followers: 0,
            following: 0,
          );
    }
    if (sessionUser != null && sessionUser.id == activeAccountId) {
      return sessionUser;
    }
    return shellUser ??
        const UserModel(
          id: '',
          name: '',
          username: '',
          avatar: '',
          bio: '',
          role: UserRole.guest,
          followers: 0,
          following: 0,
        );
  }

  bool _canCreateListing(
    UserModel activeUser,
    VerificationRequestModel request,
  ) {
    return activeUser.verified ||
        activeUser.verificationStatus.toLowerCase() == 'verified' ||
        request.status == VerificationStatus.approved;
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
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: searchController,
            readOnly: true,
            onTap: () async {
              final selectedQuery = await Navigator.of(context).push<String>(
                MaterialPageRoute<String>(
                  builder: (_) => MarketplaceSearchScreen(
                    controller: controller,
                    initialQuery: searchController.text,
                  ),
                ),
              );
              if (selectedQuery != null) {
                searchController.value = TextEditingValue(
                  text: selectedQuery,
                  selection: TextSelection.collapsed(
                    offset: selectedQuery.length,
                  ),
                );
                controller.updateSearch(selectedQuery);
              }
            },
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
              child: _quickFilters(),
            ),
          ),
          _SectionTitle(
            title: 'Featured items',
            action: 'View all',
            onActionTap: () => _openFeaturedItems(context),
          ),
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

  void _openFeaturedItems(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MarketplaceFeaturedItemsScreen(controller: controller),
      ),
    );
  }
}

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
