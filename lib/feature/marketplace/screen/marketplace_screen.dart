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
import '../../../core/widgets/error_state_view.dart';

part 'marketplace_secondary_screens.dart';

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
        final UserRole currentRole =
            context.read<MainShellController>().currentUser?.role ??
            UserRole.guest;
        final bool canCreateMarketplace =
            currentRole == UserRole.business || currentRole == UserRole.admin;
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
            body: ErrorStateView(
              message: _controller.errorMessage!,
              onRetry: _controller.load,
              onRefresh: _controller.load,
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
                if (canCreateMarketplace)
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
    return activeUser.role == UserRole.business ||
        activeUser.role == UserRole.admin;
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
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                CategoryChip(
                  label: controller.selectedLocation,
                  selected: true,
                  leading: const Icon(Icons.place_outlined, size: 18),
                  onTap: () => _showLocations(context, controller),
                ),
                const SizedBox(width: 10),
                CategoryChip(
                  label: controller.selectedCategory == 'All'
                      ? 'Categories'
                      : controller.selectedCategory,
                  selected: controller.selectedCategory != 'All',
                  leading: const Icon(Icons.grid_view_rounded, size: 18),
                  onTap: () => _showCategoryPicker(context, controller),
                ),
                const SizedBox(width: 10),
                CategoryChip(
                  label: 'Filters',
                  selected:
                      controller.selectedQuickFilter != 'Nearby' ||
                      controller.filter != const MarketplaceFilterModel(),
                  leading: const Icon(Icons.tune_rounded, size: 18),
                  onTap: onFilterTap,
                ),
              ],
            ),
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
    final bool hasActiveBrowseFilters =
        controller.selectedCategory != 'All' ||
        controller.searchQuery.trim().isNotEmpty ||
        controller.selectedQuickFilter != 'Nearby' ||
        controller.filter != const MarketplaceFilterModel();
    final List<ProductModel> browseResults = controller.filteredBrowseResults;
    final List<ProductModel> visibleResults = controller.filteredProducts;
    final bool showEmptyState = browseResults.isEmpty;

    return RefreshIndicator(
      onRefresh: controller.load,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.extentAfter < 300) {
            controller.loadMoreBrowse();
          }
          return false;
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _quickFilters(),
                    const SizedBox(height: 12),
                    _BrowseShortcutRow(controller: controller),
                  ],
                ),
              ),
            ),
            _SectionTitle(title: 'Browse categories'),
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
                      onTap: () =>
                          controller.toggleFollowCategory(category.name),
                    );
                  },
                ),
              ),
            ),
            _SectionTitle(
              title: showEmptyState ? 'No posts found' : 'Marketplace listings',
              action: showEmptyState
                  ? null
                  : (controller.isGridMode ? 'List view' : 'Grid view'),
              onActionTap: showEmptyState ? null : controller.toggleGridMode,
            ),
            if (showEmptyState)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: _MarketplaceEmptyState(
                    hasActiveFilters: hasActiveBrowseFilters,
                    onBrowseCategoriesTap: () =>
                        DefaultTabController.of(context).animateTo(1),
                    onMyListingsTap: () =>
                        DefaultTabController.of(context).animateTo(2),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                sliver: controller.isGridMode
                    ? SliverGrid(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final item = visibleResults[index];
                          return ProductCard(
                            product: item,
                            controller: controller,
                            onTap: () => _openDetails(context, item),
                          );
                        }, childCount: visibleResults.length),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.72,
                            ),
                      )
                    : SliverList.separated(
                        itemCount: visibleResults.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = visibleResults[index];
                          return ProductCard(
                            product: item,
                            compact: true,
                            controller: controller,
                            onTap: () => _openDetails(context, item),
                          );
                        },
                      ),
              ),
            if (!showEmptyState && controller.hasMoreFilteredProducts)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: Container(
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
                  ),
                ),
              ),
            if (!hasActiveBrowseFilters &&
                controller.featuredItems.isNotEmpty) ...[
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
            ],
            if (!hasActiveBrowseFilters &&
                controller.recentlyViewedItems.isNotEmpty) ...[
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
            ],
            if (!hasActiveBrowseFilters &&
                controller.recommendedItems.isNotEmpty) ...[
              _SectionTitle(
                title: 'Recommended items',
                action: controller.isGridMode ? 'List view' : 'Grid view',
                onActionTap: controller.toggleGridMode,
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
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
            ],
          ],
        ),
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

class _BrowseShortcutRow extends StatelessWidget {
  const _BrowseShortcutRow({required this.controller});

  final MarketplaceController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          FilledButton.tonalIcon(
            onPressed: () => DefaultTabController.of(context).animateTo(1),
            icon: const Icon(Icons.grid_view_rounded),
            label: const Text('Browse categories'),
          ),
          const SizedBox(width: 10),
          FilledButton.tonalIcon(
            onPressed: () => DefaultTabController.of(context).animateTo(2),
            icon: const Icon(Icons.storefront_outlined),
            label: const Text('My listings'),
          ),
          const SizedBox(width: 10),
          Chip(
            avatar: const Icon(Icons.place_outlined, size: 18),
            label: Text(controller.selectedLocation),
          ),
        ],
      ),
    );
  }
}

class _MarketplaceEmptyState extends StatelessWidget {
  const _MarketplaceEmptyState({
    required this.hasActiveFilters,
    required this.onBrowseCategoriesTap,
    required this.onMyListingsTap,
  });

  final bool hasActiveFilters;
  final VoidCallback onBrowseCategoriesTap;
  final VoidCallback onMyListingsTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 30,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            hasActiveFilters
                ? 'No posts found for this filter.'
                : 'No posts found right now.',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            hasActiveFilters
                ? 'Try another category, quick filter, or search term.'
                : 'Browse categories or open your listings while we wait for new products.',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.tonalIcon(
                onPressed: onBrowseCategoriesTap,
                icon: const Icon(Icons.grid_view_rounded),
                label: const Text('Browse categories'),
              ),
              FilledButton.tonalIcon(
                onPressed: onMyListingsTap,
                icon: const Icon(Icons.storefront_outlined),
                label: const Text('My listings'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
