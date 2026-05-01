import 'dart:math';

import 'package:flutter/foundation.dart';

import '../model/marketplace_category_model.dart';
import '../model/marketplace_chat_model.dart';
import '../model/marketplace_filter_model.dart';
import '../model/marketplace_order_model.dart';
import '../model/product_model.dart';
import '../model/seller_model.dart';
import '../repository/marketplace_repository.dart';

class MarketplaceController extends ChangeNotifier {
  MarketplaceController({MarketplaceRepository? repository})
    : _repository = repository ?? MarketplaceRepository();

  final MarketplaceRepository _repository;
  final Random _random = Random(3);
  final List<String> _recentlyViewedIds = <String>[];

  bool isLoading = true;
  bool isGridMode = true;
  bool listingApprovalEnabled = true;
  bool autoHideSuspiciousListings = true;
  bool checkoutEnabled = true;
  bool isSyncingMarketplaceAction = false;
  String selectedLocation = 'Dhaka, Bangladesh';
  String searchQuery = '';
  String selectedCategory = 'All';
  String selectedQuickFilter = 'Nearby';
  int browseVisibleCount = 4;
  MarketplaceFilterModel filter = const MarketplaceFilterModel();

  List<ProductModel> _products = <ProductModel>[];
  List<SellerModel> sellers = <SellerModel>[];
  List<MarketplaceCategoryModel> categories = <MarketplaceCategoryModel>[];
  List<String> savedItemIds = <String>[];
  List<String> compareItemIds = <String>[];
  List<String> followedSellerIds = <String>[];
  List<String> savedSearches = <String>[];
  List<String> recentSearches = <String>[];
  List<String> trendingSearches = <String>[];
  List<String> notifications = <String>[];
  List<String> blockedKeywords = <String>[];
  List<MarketplaceChatMessage> chatMessages = <MarketplaceChatMessage>[];
  List<MarketplaceOfferEvent> offerHistory = <MarketplaceOfferEvent>[];
  List<MarketplaceOrderModel> orders = <MarketplaceOrderModel>[];
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final data = await _repository.loadMarketplace();
      _products = data.products;
      sellers = data.sellers;
      categories = data.categories;
      savedItemIds = List<String>.from(data.savedItemIds);
      compareItemIds = List<String>.from(data.compareItemIds);
      followedSellerIds = List<String>.from(data.followedSellerIds);
      savedSearches = List<String>.from(data.savedSearches);
      recentSearches = List<String>.from(data.recentSearches);
      trendingSearches = List<String>.from(data.trendingSearches);
      notifications = List<String>.from(data.notifications);
      blockedKeywords = List<String>.from(data.blockedKeywords);
      chatMessages = List<MarketplaceChatMessage>.from(data.chatMessages);
      offerHistory = List<MarketplaceOfferEvent>.from(data.offerHistory);
      orders = List<MarketplaceOrderModel>.from(data.orders);
    } catch (error) {
      errorMessage = error.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  List<ProductModel> get allProducts =>
      List<ProductModel>.unmodifiable(_products);

  List<ProductModel> get filteredProducts {
    var items = _products.where(
      (item) => item.listingStatus != ListingStatus.draft,
    );
    if (selectedCategory != 'All') {
      items = items.where((item) => item.category == selectedCategory);
    }
    if (searchQuery.trim().isNotEmpty) {
      final term = searchQuery.toLowerCase();
      items = items.where(
        (item) =>
            item.title.toLowerCase().contains(term) ||
            item.description.toLowerCase().contains(term) ||
            item.category.toLowerCase().contains(term) ||
            item.brand.toLowerCase().contains(term),
      );
    }
    if (filter.category != null) {
      items = items.where((item) => item.category == filter.category);
    }
    items = items.where(
      (item) => item.price >= filter.minPrice && item.price <= filter.maxPrice,
    );
    if (filter.condition != null) {
      items = items.where((item) => item.condition == filter.condition);
    }
    if (filter.deliveryAvailable) {
      items = items.where((item) => item.deliveryOptions.length > 1);
    }
    if (filter.negotiableOnly) {
      items = items.where((item) => item.isNegotiable);
    }
    if (filter.verifiedSellersOnly) {
      items = items.where((item) => item.sellerType == SellerType.verified);
    }
    switch (selectedQuickFilter) {
      case 'Nearby':
        items = items.where((item) => !item.distanceLabel.contains('14'));
      case 'New today':
        items = items.where(
          (item) => DateTime.now().difference(item.timePosted).inHours < 24,
        );
      case 'Delivery':
        items = items.where(
          (item) => item.deliveryOptions.contains(DeliveryOption.shipping),
        );
      case 'Negotiable':
        items = items.where((item) => item.isNegotiable);
      case 'Price low to high':
      case 'Price high to low':
        break;
    }
    final result = items.toList();
    switch (filter.sortBy) {
      case MarketplaceSort.latest:
        result.sort((a, b) => b.timePosted.compareTo(a.timePosted));
      case MarketplaceSort.nearest:
        result.sort((a, b) => a.distanceLabel.compareTo(b.distanceLabel));
      case MarketplaceSort.priceLowHigh:
        result.sort((a, b) => a.price.compareTo(b.price));
      case MarketplaceSort.priceHighLow:
        result.sort((a, b) => b.price.compareTo(a.price));
      case MarketplaceSort.relevant:
        result.sort(
          (a, b) => (b.watchers + b.views).compareTo(a.watchers + a.views),
        );
    }
    return result.take(browseVisibleCount).toList();
  }

  List<ProductModel> get featuredItems =>
      _products.where((item) => item.isFeatured).take(5).toList();

  List<ProductModel> get recommendedItems =>
      _products.where((item) => item.isRecommended).take(6).toList();

  List<ProductModel> get recentlyViewedItems => _products
      .where(
        (item) => item.isRecentlyViewed || _recentlyViewedIds.contains(item.id),
      )
      .take(5)
      .toList();

  List<ProductModel> get savedItems =>
      _products.where((item) => savedItemIds.contains(item.id)).toList();

  List<ProductModel> listingsByStatus(ListingStatus status) =>
      _products.where((item) => item.listingStatus == status).toList();

  SellerModel sellerById(String id) =>
      sellers.firstWhere((seller) => seller.id == id);

  ProductModel productById(String id) =>
      _products.firstWhere((product) => product.id == id);

  List<ProductModel> similarProducts(ProductModel product) {
    return _products
        .where(
          (item) =>
              item.id != product.id &&
              (item.category == product.category ||
                  item.sellerId == product.sellerId),
        )
        .take(4)
        .toList();
  }

  void updateSearch(String query) {
    searchQuery = query;
    if (query.trim().isNotEmpty) {
      recentSearches.remove(query.trim());
      recentSearches.insert(0, query.trim());
      if (recentSearches.length > 5) {
        recentSearches = recentSearches.take(5).toList();
      }
    }
    browseVisibleCount = 4;
    notifyListeners();
  }

  void selectLocation(String value) {
    selectedLocation = value;
    notifyListeners();
  }

  void selectCategory(String value) {
    selectedCategory = value;
    browseVisibleCount = 4;
    notifyListeners();
  }

  void selectQuickFilter(String value) {
    selectedQuickFilter = value;
    if (value == 'Price low to high') {
      filter = filter.copyWith(sortBy: MarketplaceSort.priceLowHigh);
    } else if (value == 'Price high to low') {
      filter = filter.copyWith(sortBy: MarketplaceSort.priceHighLow);
    }
    browseVisibleCount = 4;
    notifyListeners();
  }

  void updateFilter(MarketplaceFilterModel value) {
    filter = value;
    browseVisibleCount = 4;
    notifyListeners();
  }

  void toggleGridMode() {
    isGridMode = !isGridMode;
    notifyListeners();
  }

  Future<bool> toggleSave(String productId) async {
    final bool shouldSave = !savedItemIds.contains(productId);
    final ProductModel? product = _products
        .where((item) => item.id == productId)
        .cast<ProductModel?>()
        .firstOrNull;

    isSyncingMarketplaceAction = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _repository.setSavedItem(
        productId: productId,
        shouldSave: shouldSave,
        title: product?.title,
      );
      if (shouldSave) {
        if (!savedItemIds.contains(productId)) {
          savedItemIds.insert(0, productId);
        }
      } else {
        savedItemIds.remove(productId);
      }
      return true;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isSyncingMarketplaceAction = false;
      notifyListeners();
    }
  }

  Future<bool> toggleCompare(String productId) async {
    final List<String> nextCompareItems = List<String>.from(compareItemIds);
    if (nextCompareItems.contains(productId)) {
      nextCompareItems.remove(productId);
    } else if (nextCompareItems.length < 3) {
      nextCompareItems.add(productId);
    }

    isSyncingMarketplaceAction = true;
    errorMessage = null;
    notifyListeners();
    try {
      compareItemIds = await _repository.updateCompareItems(nextCompareItems);
      return true;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isSyncingMarketplaceAction = false;
      notifyListeners();
    }
  }

  void markViewed(String productId) {
    _recentlyViewedIds.remove(productId);
    _recentlyViewedIds.insert(0, productId);
    notifyListeners();
  }

  Future<bool> toggleFollowSeller(String sellerId) async {
    final bool shouldFollow = !followedSellerIds.contains(sellerId);
    isSyncingMarketplaceAction = true;
    errorMessage = null;
    notifyListeners();
    try {
      final bool following = await _repository.setSellerFollow(
        sellerId: sellerId,
        shouldFollow: shouldFollow,
      );
      if (following) {
        if (!followedSellerIds.contains(sellerId)) {
          followedSellerIds.add(sellerId);
        }
      } else {
        followedSellerIds.remove(sellerId);
      }
      return true;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isSyncingMarketplaceAction = false;
      notifyListeners();
    }
  }

  Future<void> loadProductInteractions(String productId) async {
    errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait(<Future<dynamic>>[
        _repository.fetchProductChatMessages(productId),
        _repository.fetchProductOffers(productId),
      ]);
      chatMessages = List<MarketplaceChatMessage>.from(
        results[0] as List<MarketplaceChatMessage>,
      );
      offerHistory = List<MarketplaceOfferEvent>.from(
        results[1] as List<MarketplaceOfferEvent>,
      );
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    }
    notifyListeners();
  }

  void toggleFollowCategory(String categoryName) {
    categories = categories
        .map(
          (category) => category.name == categoryName
              ? category.copyWith(isFollowed: !category.isFollowed)
              : category,
        )
        .toList();
    notifyListeners();
  }

  void saveSearch(String query) {
    if (query.trim().isEmpty) {
      return;
    }
    savedSearches.remove(query.trim());
    savedSearches.insert(0, query.trim());
    notifyListeners();
  }

  Future<void> deleteListing(String productId) async {
    final ProductModel? listing = _products.cast<ProductModel?>().firstWhere(
      (ProductModel? item) => item?.id == productId,
      orElse: () => null,
    );
    if (listing?.listingStatus == ListingStatus.draft) {
      try {
        await _repository.deleteDraft(productId);
      } catch (error) {
        errorMessage = error.toString().replaceFirst('Exception: ', '');
        notifyListeners();
        return;
      }
    }
    _products = _products.where((item) => item.id != productId).toList();
    savedItemIds.remove(productId);
    notifyListeners();
  }

  Future<void> markAsSold(String productId) =>
      _persistListingStatus(productId, ListingStatus.sold);

  Future<void> pauseListing(String productId) =>
      _persistListingStatus(productId, ListingStatus.expired);

  Future<void> repostListing(String productId) =>
      _persistListingStatus(productId, ListingStatus.active);

  Future<bool> publishDraft({
    required String title,
    required String description,
    required String category,
    required String subcategory,
    required ProductCondition condition,
    required double price,
    required bool isNegotiable,
    required int quantity,
    required List<String> tags,
    required String location,
    required List<DeliveryOption> deliveryOptions,
    required bool boostListing,
    required Map<String, String> optionalFields,
    required String sellerId,
    required String sellerName,
    required String sellerAvatar,
    required SellerType sellerType,
  }) async {
    final ProductModel? created = await _repository.createListing(
      title: title,
      description: description,
      category: category,
      subcategory: subcategory,
      condition: condition,
      price: price,
      location: location,
      sellerId: sellerId,
      sellerName: sellerName,
    );
    if (created == null) {
      errorMessage = 'Unable to publish marketplace listing.';
      notifyListeners();
      return false;
    }
    _products.insert(0, created);
    _upsertSeller(
      sellerId: sellerId,
      sellerName: sellerName,
      sellerAvatar: sellerAvatar,
      sellerType: sellerType,
    );
    notifications.insert(0, 'Published "$title" to Marketplace');
    notifyListeners();
    return true;
  }

  Future<bool> saveDraft({
    required String title,
    required String description,
    required String category,
    required String subcategory,
    required ProductCondition condition,
    required double price,
    required bool isNegotiable,
    required int quantity,
    required List<String> tags,
    required String location,
    required List<DeliveryOption> deliveryOptions,
    required Map<String, String> optionalFields,
    required String sellerId,
    required String sellerName,
    required SellerType sellerType,
  }) async {
    isSyncingMarketplaceAction = true;
    errorMessage = null;
    notifyListeners();
    try {
      final ProductModel draft = await _repository.saveDraft(
        title: title,
        description: description,
        category: category,
        subcategory: subcategory,
        condition: condition,
        price: price,
        isNegotiable: isNegotiable,
        quantity: quantity,
        tags: tags,
        location: location,
        deliveryOptions: deliveryOptions,
        optionalFields: optionalFields,
        sellerId: sellerId,
        sellerName: sellerName,
        sellerType: sellerType,
      );
      _products.insert(0, draft);
      notifications.insert(0, 'Saved "$title" as draft');
      _upsertSeller(
        sellerId: sellerId,
        sellerName: sellerName,
        sellerAvatar: '',
        sellerType: sellerType,
      );
      return true;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isSyncingMarketplaceAction = false;
      notifyListeners();
    }
  }

  void loadMoreBrowse() {
    if (browseVisibleCount < _products.length) {
      browseVisibleCount += 4;
      notifyListeners();
    }
  }

  Future<bool> sendMessage(
    String productId,
    String text, {
    String? imageUrl,
  }) async {
    if (text.trim().isEmpty && imageUrl == null) {
      return false;
    }
    isSyncingMarketplaceAction = true;
    errorMessage = null;
    notifyListeners();
    try {
      final MarketplaceChatMessage remoteMessage = await _repository
          .sendMessage(productId: productId, text: text, imageUrl: imageUrl);
      final MarketplaceChatMessage message = MarketplaceChatMessage(
        id: remoteMessage.id,
        senderId: remoteMessage.senderId,
        senderName: 'You',
        text: remoteMessage.text,
        timestamp: remoteMessage.timestamp,
        productId: remoteMessage.productId ?? productId,
        imageUrl: remoteMessage.imageUrl,
        isOffer: remoteMessage.isOffer,
        offerAmount: remoteMessage.offerAmount,
        productTitle: remoteMessage.productTitle,
      );
      chatMessages = <MarketplaceChatMessage>[message, ...chatMessages];
      return true;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isSyncingMarketplaceAction = false;
      notifyListeners();
    }
  }

  Future<bool> sendQuickReply(String productId, String reply) =>
      sendMessage(productId, reply);

  Future<bool> sendOffer(String productId, double amount) async {
    isSyncingMarketplaceAction = true;
    errorMessage = null;
    notifyListeners();
    try {
      final MarketplaceOfferEvent offer = await _repository.sendOffer(
        productId: productId,
        amount: amount,
      );
      offerHistory = <MarketplaceOfferEvent>[offer, ...offerHistory];
      chatMessages = <MarketplaceChatMessage>[
        MarketplaceChatMessage(
          id: offer.id ?? 'offer-${offerHistory.length}',
          senderId: null,
          senderName: 'You',
          text: offer.note?.isNotEmpty == true ? offer.note! : 'Sent an offer',
          timestamp: offer.timestamp,
          productId: offer.productId ?? productId,
          isOffer: true,
          offerAmount: offer.amount,
        ),
        ...chatMessages,
      ];
      return true;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isSyncingMarketplaceAction = false;
      notifyListeners();
    }
  }

  Future<bool> placeOrder(ProductModel product) async {
    final MarketplaceOrderModel? order = await _repository.createOrder(
      productId: product.id,
      address: 'House 14, Road 7, Dhanmondi, Dhaka',
      deliveryMethod: product.deliveryOptions.first.label,
      paymentMethod: 'Wallet',
    );
    if (order == null) {
      errorMessage = 'Unable to create marketplace order.';
      notifyListeners();
      return false;
    }
    orders.insert(0, order);
    notifications.insert(0, 'Order confirmed for ${product.title}');
    notifyListeners();
    return true;
  }

  String suspiciousScan(ProductModel product) {
    final flagged = blockedKeywords.where(
      (keyword) => product.description.toLowerCase().contains(keyword),
    );
    return flagged.isEmpty
        ? 'No suspicious keywords found'
        : flagged.join(', ');
  }

  double randomCounterOffer(ProductModel product) {
    return max(product.price * 0.9, product.price - (_random.nextInt(80) + 20));
  }

  void _upsertSeller({
    required String sellerId,
    required String sellerName,
    required String sellerAvatar,
    required SellerType sellerType,
  }) {
    final existingIndex = sellers.indexWhere((seller) => seller.id == sellerId);
    final SellerModel? existing = existingIndex == -1
        ? null
        : sellers[existingIndex];
    final activeListings = _products
        .where(
          (item) =>
              item.sellerId == sellerId &&
              item.listingStatus != ListingStatus.draft,
        )
        .length;

    final updatedSeller = SellerModel(
      id: sellerId,
      name: sellerName,
      avatar: sellerAvatar,
      bio:
          existing?.bio ??
          'Marketplace seller profile for $sellerName on OptiZenqor.',
      joinDate: existing?.joinDate ?? DateTime.now(),
      rating: existing?.rating ?? 5,
      responseRate: existing?.responseRate ?? 100,
      responseTime: existing?.responseTime ?? 'within 15 mins',
      followers: existing?.followers ?? 0,
      following: existing?.following ?? 0,
      isVerified: sellerType == SellerType.verified,
      sellerType: sellerType,
      activeListings: activeListings,
      completedOrders: existing?.completedOrders ?? 0,
      reviews: existing?.reviews ?? const <SellerReview>[],
      storeName: existing?.storeName ?? sellerName,
      strikeStatus: existing?.strikeStatus ?? 'No warnings',
    );

    if (existingIndex == -1) {
      sellers.insert(0, updatedSeller);
      return;
    }
    sellers[existingIndex] = updatedSeller;
  }

  Future<void> _persistListingStatus(
    String productId,
    ListingStatus status,
  ) async {
    isSyncingMarketplaceAction = true;
    errorMessage = null;
    notifyListeners();
    try {
      final ProductModel updated = await _repository.updateListingStatus(
        productId: productId,
        status: status,
      );
      _products = _products
          .map((item) => item.id == productId ? updated : item)
          .toList(growable: false);
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isSyncingMarketplaceAction = false;
      notifyListeners();
    }
  }
}
