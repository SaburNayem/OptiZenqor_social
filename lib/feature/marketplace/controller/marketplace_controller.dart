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

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    final data = await _repository.loadMarketplace();
    _products = data.products;
    sellers = data.sellers;
    categories = data.categories;
    savedItemIds = List<String>.from(data.savedItemIds);
    followedSellerIds = List<String>.from(data.followedSellerIds);
    savedSearches = List<String>.from(data.savedSearches);
    recentSearches = List<String>.from(data.recentSearches);
    trendingSearches = List<String>.from(data.trendingSearches);
    notifications = List<String>.from(data.notifications);
    blockedKeywords = List<String>.from(data.blockedKeywords);
    chatMessages = List<MarketplaceChatMessage>.from(data.chatMessages);
    offerHistory = List<MarketplaceOfferEvent>.from(data.offerHistory);
    orders = List<MarketplaceOrderModel>.from(data.orders);
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

  void toggleSave(String productId) {
    if (savedItemIds.contains(productId)) {
      savedItemIds.remove(productId);
    } else {
      savedItemIds.insert(0, productId);
    }
    notifyListeners();
  }

  void toggleCompare(String productId) {
    if (compareItemIds.contains(productId)) {
      compareItemIds.remove(productId);
    } else if (compareItemIds.length < 3) {
      compareItemIds.add(productId);
    }
    notifyListeners();
  }

  void markViewed(String productId) {
    _recentlyViewedIds.remove(productId);
    _recentlyViewedIds.insert(0, productId);
    notifyListeners();
  }

  void toggleFollowSeller(String sellerId) {
    if (followedSellerIds.contains(sellerId)) {
      followedSellerIds.remove(sellerId);
    } else {
      followedSellerIds.add(sellerId);
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

  void deleteListing(String productId) {
    _products = _products.where((item) => item.id != productId).toList();
    savedItemIds.remove(productId);
    notifyListeners();
  }

  void markAsSold(String productId) =>
      _updateListingStatus(productId, ListingStatus.sold);

  void pauseListing(String productId) =>
      _updateListingStatus(productId, ListingStatus.expired);

  void repostListing(String productId) =>
      _updateListingStatus(productId, ListingStatus.active);

  void publishDraft({
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
  }) {
    _products.insert(
      0,
      ProductModel(
        id: 'item-${_products.length + 1}',
        title: title,
        description: description,
        price: price,
        category: category,
        subcategory: subcategory,
        condition: condition,
        location: location,
        distanceLabel: 'Just now',
        timePosted: DateTime.now(),
        images: const <String>[
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=1200&q=80',
        ],
        sellerId: 'seller-1',
        sellerName: 'Ava Rahman',
        sellerType: SellerType.verified,
        isNegotiable: isNegotiable,
        deliveryOptions: deliveryOptions,
        attributes: optionalFields,
        tags: tags,
        brand: optionalFields['Brand'] ?? 'Independent',
        quantity: quantity,
        isFeatured: boostListing,
        isTrending: boostListing,
        isRecommended: true,
        isRecentlyViewed: false,
        hasPriceDrop: false,
        isAuction: false,
        rating: 0,
        reviewCount: 0,
        reviews: const <ProductReview>[],
        listingStatus: ListingStatus.active,
        views: 0,
        watchers: 0,
        chats: 0,
        isHiddenByModeration: false,
        reviewStatus: listingApprovalEnabled ? 'Awaiting approval' : 'Approved',
      ),
    );
    notifications.insert(0, 'Published "$title" to Marketplace');
    notifyListeners();
  }

  void saveDraft({
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
  }) {
    _products.insert(
      0,
      ProductModel(
        id: 'draft-${_products.length + 1}',
        title: title,
        description: description,
        price: price,
        category: category,
        subcategory: subcategory,
        condition: condition,
        location: location,
        distanceLabel: 'Draft',
        timePosted: DateTime.now(),
        images: const <String>[
          'https://images.unsplash.com/photo-1512436991641-6745cdb1723f?auto=format&fit=crop&w=1200&q=80',
        ],
        sellerId: 'seller-1',
        sellerName: 'Ava Rahman',
        sellerType: SellerType.verified,
        isNegotiable: isNegotiable,
        deliveryOptions: deliveryOptions,
        attributes: optionalFields,
        tags: tags,
        brand: optionalFields['Brand'] ?? 'Independent',
        quantity: quantity,
        isFeatured: false,
        isTrending: false,
        isRecommended: false,
        isRecentlyViewed: false,
        hasPriceDrop: false,
        isAuction: false,
        rating: 0,
        reviewCount: 0,
        reviews: const <ProductReview>[],
        listingStatus: ListingStatus.draft,
        views: 0,
        watchers: 0,
        chats: 0,
        isHiddenByModeration: false,
        reviewStatus: 'Draft',
      ),
    );
    notifications.insert(0, 'Saved "$title" as draft');
    notifyListeners();
  }

  void loadMoreBrowse() {
    if (browseVisibleCount < _products.length) {
      browseVisibleCount += 4;
      notifyListeners();
    }
  }

  void sendMessage(String text, {String? imageUrl}) {
    if (text.trim().isEmpty && imageUrl == null) {
      return;
    }
    chatMessages.add(
      MarketplaceChatMessage(
        id: 'chat-${chatMessages.length + 1}',
        senderName: 'You',
        text: text.trim().isEmpty ? 'Sent an image' : text.trim(),
        imageUrl: imageUrl,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void sendQuickReply(String reply) => sendMessage(reply);

  void sendOffer(double amount) {
    offerHistory.add(
      MarketplaceOfferEvent(
        actor: 'You',
        action: 'Offered',
        amount: amount,
        timestamp: DateTime.now(),
      ),
    );
    chatMessages.add(
      MarketplaceChatMessage(
        id: 'chat-${chatMessages.length + 1}',
        senderName: 'You',
        text: 'Sent an offer',
        timestamp: DateTime.now(),
        isOffer: true,
        offerAmount: amount,
      ),
    );
    notifyListeners();
  }

  void placeOrder(ProductModel product) {
    orders.insert(
      0,
      MarketplaceOrderModel(
        id: 'ord-${orders.length + 1}',
        productId: product.id,
        productTitle: product.title,
        amount: product.price,
        status: MarketplaceOrderStatus.confirmed,
        address: 'House 14, Road 7, Dhanmondi, Dhaka',
        deliveryMethod: product.deliveryOptions.first.label,
        paymentMethod: 'Wallet',
        createdAt: DateTime.now(),
      ),
    );
    notifications.insert(0, 'Order confirmed for ${product.title}');
    notifyListeners();
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

  void _updateListingStatus(String productId, ListingStatus status) {
    _products = _products
        .map(
          (item) => item.id == productId
              ? item.copyWith(listingStatus: status)
              : item,
        )
        .toList();
    notifyListeners();
  }
}
