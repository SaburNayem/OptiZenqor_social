import 'package:flutter/material.dart';

import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/marketplace_category_model.dart';
import '../model/marketplace_chat_model.dart';
import '../model/marketplace_order_model.dart';
import '../model/product_model.dart';
import '../model/seller_model.dart';
import '../service/marketplace_service.dart';

class MarketplaceSeedData {
  const MarketplaceSeedData({
    required this.products,
    required this.sellers,
    required this.categories,
    required this.savedItemIds,
    required this.compareItemIds,
    required this.followedSellerIds,
    required this.savedSearches,
    required this.recentSearches,
    required this.trendingSearches,
    required this.notifications,
    required this.blockedKeywords,
    required this.chatMessages,
    required this.offerHistory,
    required this.orders,
  });

  final List<ProductModel> products;
  final List<SellerModel> sellers;
  final List<MarketplaceCategoryModel> categories;
  final List<String> savedItemIds;
  final List<String> compareItemIds;
  final List<String> followedSellerIds;
  final List<String> savedSearches;
  final List<String> recentSearches;
  final List<String> trendingSearches;
  final List<String> notifications;
  final List<String> blockedKeywords;
  final List<MarketplaceChatMessage> chatMessages;
  final List<MarketplaceOfferEvent> offerHistory;
  final List<MarketplaceOrderModel> orders;
}

class MarketplaceRepository {
  MarketplaceRepository({MarketplaceService? service})
    : _service = service ?? MarketplaceService();

  final MarketplaceService _service;

  Future<MarketplaceSeedData> loadMarketplace() async {
    final MarketplaceSeedData remoteData = await _loadRemoteMarketplace();
    return remoteData.products.isNotEmpty
        ? remoteData
        : const MarketplaceSeedData(
            products: <ProductModel>[],
            sellers: <SellerModel>[],
            categories: <MarketplaceCategoryModel>[],
            savedItemIds: <String>[],
            compareItemIds: <String>[],
            followedSellerIds: <String>[],
            savedSearches: <String>[],
            recentSearches: <String>[],
            trendingSearches: <String>[],
            notifications: <String>[],
            blockedKeywords: <String>[],
            chatMessages: <MarketplaceChatMessage>[],
            offerHistory: <MarketplaceOfferEvent>[],
            orders: <MarketplaceOrderModel>[],
          );
  }

  Future<MarketplaceSeedData> _loadRemoteMarketplace() async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .getEndpoint('marketplace');
    _throwIfRequestFailed(
      response,
      fallbackMessage: 'Failed to load marketplace data from the backend.',
    );

    final Map<String, dynamic> payload = _resolveMarketplacePayload(
      response.data,
    );
    final List<Map<String, dynamic>> productItems =
        ApiPayloadReader.readMapList(
          payload,
          preferredKeys: const <String>['products', 'items'],
        );
    final List<ProductModel> products = productItems
        .map(ProductModel.fromApiJson)
        .where((ProductModel item) => item.id.isNotEmpty)
        .toList(growable: false);
    final List<ProductModel> draftProducts = _readDraftProducts(payload);
    final List<ProductModel> combinedProducts = <ProductModel>[
      ...products,
      ...draftProducts.where(
        (ProductModel draft) =>
            !products.any((ProductModel item) => item.id == draft.id),
      ),
    ];

    return MarketplaceSeedData(
      products: combinedProducts,
      sellers: _readSellers(payload, combinedProducts),
      categories: _readCategories(payload, combinedProducts),
      savedItemIds: ApiPayloadReader.readStringList(payload['savedItemIds']),
      compareItemIds: ApiPayloadReader.readStringList(
        payload['compareItemIds'],
      ),
      followedSellerIds: ApiPayloadReader.readStringList(
        payload['followedSellerIds'],
      ),
      savedSearches: ApiPayloadReader.readStringList(payload['savedSearches']),
      recentSearches: ApiPayloadReader.readStringList(
        payload['recentSearches'],
      ),
      trendingSearches: ApiPayloadReader.readStringList(
        payload['trendingSearches'],
      ),
      notifications: ApiPayloadReader.readStringList(payload['notifications']),
      blockedKeywords: ApiPayloadReader.readStringList(
        payload['blockedKeywords'],
      ),
      chatMessages: _readChatMessages(payload),
      offerHistory: _readOfferHistory(payload),
      orders: _readOrders(payload),
    );
  }

  Future<bool> setSellerFollow({
    required String sellerId,
    required bool shouldFollow,
  }) async {
    final String endpoint = ApiEndPoints.marketplaceSellerFollow(sellerId);
    final ServiceResponseModel<Map<String, dynamic>> response = shouldFollow
        ? await _service.apiClient.post(endpoint, const <String, dynamic>{})
        : await _service.apiClient.delete(endpoint);
    _throwIfRequestFailed(
      response,
      fallbackMessage: shouldFollow
          ? 'Unable to follow this seller right now.'
          : 'Unable to unfollow this seller right now.',
    );
    return _readBooleanResult(response.data, defaultValue: shouldFollow);
  }

  Future<bool> setSavedItem({
    required String productId,
    required bool shouldSave,
    String? title,
  }) async {
    final ServiceResponseModel<Map<String, dynamic>> response = shouldSave
        ? await _service.apiClient.post(
            ApiEndPoints.bookmarks,
            <String, dynamic>{
              'id': productId,
              'title': title ?? '',
              'type': 'product',
            },
          )
        : await _service.apiClient.delete(ApiEndPoints.bookmarkById(productId));
    _throwIfRequestFailed(
      response,
      fallbackMessage: shouldSave
          ? 'Unable to save this marketplace item right now.'
          : 'Unable to remove this marketplace item right now.',
    );
    return shouldSave;
  }

  Future<List<String>> updateCompareItems(List<String> productIds) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .patch(_service.endpoints['compare']!, <String, dynamic>{
          'productIds': productIds,
        });
    _throwIfRequestFailed(
      response,
      fallbackMessage: 'Unable to update marketplace compare items right now.',
    );
    final Map<String, dynamic> payload = _readRequiredPayload(
      response.data,
      fallbackMessage: 'Marketplace compare response was empty.',
    );
    return ApiPayloadReader.readStringList(payload['productIds']);
  }

  Future<ProductModel> updateListingStatus({
    required String productId,
    required ListingStatus status,
  }) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .patch(
          ApiEndPoints.marketplaceProductStatus(productId),
          <String, dynamic>{'status': _listingStatusValue(status)},
        );
    _throwIfRequestFailed(
      response,
      fallbackMessage: 'Unable to update marketplace listing status right now.',
    );
    return ProductModel.fromApiJson(
      _readRequiredPayload(
        response.data,
        fallbackMessage: 'Marketplace listing status response was empty.',
      ),
    );
  }

  Future<ProductModel> saveDraft({
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
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .post(_service.endpoints['drafts']!, <String, dynamic>{
          'title': title.trim(),
          'description': description.trim(),
          'price': price,
          'category': category,
          'subcategory': subcategory,
          'condition': condition.label,
          'location': location.trim(),
          'metadata': <String, dynamic>{
            'isNegotiable': isNegotiable,
            'quantity': quantity,
            'tags': tags,
            'deliveryOptions': deliveryOptions
                .map((DeliveryOption option) => option.label)
                .toList(growable: false),
            'attributes': optionalFields,
          },
        });
    _throwIfRequestFailed(
      response,
      fallbackMessage: 'Unable to save this marketplace draft right now.',
    );
    final Map<String, dynamic> payload = _readRequiredPayload(
      response.data,
      fallbackMessage: 'Marketplace draft response was empty.',
    );
    return _draftProductFromApiJson(
      payload,
      sellerId: sellerId,
      sellerName: sellerName,
      sellerType: sellerType,
    );
  }

  Future<void> deleteDraft(String draftId) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .delete(ApiEndPoints.marketplaceDraftById(draftId));
    _throwIfRequestFailed(
      response,
      fallbackMessage: 'Unable to delete this marketplace draft right now.',
    );
  }

  Future<List<MarketplaceChatMessage>> fetchProductChatMessages(
    String productId,
  ) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .get(ApiEndPoints.marketplaceProductChat(productId));
    _throwIfRequestFailed(
      response,
      fallbackMessage: 'Unable to load marketplace messages right now.',
    );
    final Map<String, dynamic> payload = _readRequiredPayload(
      response.data,
      fallbackMessage: 'Marketplace chat response was empty.',
    );
    return _readChatMessages(payload);
  }

  Future<MarketplaceChatMessage> sendMessage({
    required String productId,
    required String text,
    String? imageUrl,
  }) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .post(ApiEndPoints.marketplaceProductChatMessages(productId), <
          String,
          dynamic
        >{
          'text': text.trim(),
          if ((imageUrl ?? '').trim().isNotEmpty) 'imageUrl': imageUrl!.trim(),
        });
    _throwIfRequestFailed(
      response,
      fallbackMessage: 'Unable to send this marketplace message right now.',
    );
    return _readChatMessage(
      _readRequiredPayload(
        response.data,
        fallbackMessage: 'Marketplace message response was empty.',
      ),
    );
  }

  Future<List<MarketplaceOfferEvent>> fetchProductOffers(
    String productId,
  ) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .get(ApiEndPoints.marketplaceProductOffers(productId));
    _throwIfRequestFailed(
      response,
      fallbackMessage: 'Unable to load marketplace offers right now.',
    );
    final List<Map<String, dynamic>> items = _readMapListResponse(
      response.data,
      fallbackMessage: 'Marketplace offers response was empty.',
    );
    return items
        .map(_readOfferEvent)
        .where((MarketplaceOfferEvent item) => item.actor.isNotEmpty)
        .toList(growable: false);
  }

  Future<MarketplaceOfferEvent> sendOffer({
    required String productId,
    required double amount,
    String? note,
  }) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .post(
          ApiEndPoints.marketplaceProductOffers(productId),
          <String, dynamic>{
            'amount': amount,
            if ((note ?? '').trim().isNotEmpty) 'note': note!.trim(),
          },
        );
    _throwIfRequestFailed(
      response,
      fallbackMessage: 'Unable to send this marketplace offer right now.',
    );
    return _readOfferEvent(
      _readRequiredPayload(
        response.data,
        fallbackMessage: 'Marketplace offer response was empty.',
      ),
    );
  }

  Future<MarketplaceOrderModel?> createOrder({
    required String productId,
    required String address,
    required String deliveryMethod,
    required String paymentMethod,
  }) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .post(_service.endpoints['checkout']!, <String, dynamic>{
          'productId': productId,
          'address': address,
          'deliveryMethod': deliveryMethod,
          'paymentMethod': paymentMethod,
        });
    if (!response.isSuccess || response.data['success'] == false) {
      return null;
    }
    final Map<String, dynamic>? payload =
        ApiPayloadReader.readMap(response.data['data']) ??
        ApiPayloadReader.readMap(response.data['order']) ??
        ApiPayloadReader.readMap(response.data);
    if (payload == null || payload.isEmpty) {
      return null;
    }
    return MarketplaceOrderModel(
      id: ApiPayloadReader.readString(payload['id']),
      productId: ApiPayloadReader.readString(payload['productId']),
      productTitle: ApiPayloadReader.readString(payload['productTitle']),
      amount: ApiPayloadReader.readDouble(
        payload['amount'] ?? payload['price'],
      ),
      status: _orderStatusFromValue(payload['status']),
      address: ApiPayloadReader.readString(payload['address']),
      deliveryMethod: ApiPayloadReader.readString(payload['deliveryMethod']),
      paymentMethod: ApiPayloadReader.readString(payload['paymentMethod']),
      createdAt:
          ApiPayloadReader.readDateTime(payload['createdAt']) ?? DateTime.now(),
    );
  }

  Future<ProductModel?> createListing({
    required String title,
    required String description,
    required String category,
    required String subcategory,
    required ProductCondition condition,
    required double price,
    required String location,
    required String sellerId,
    required String sellerName,
  }) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .post(_service.endpoints['products']!, <String, dynamic>{
          'title': title.trim(),
          'description': description.trim(),
          'price': price,
          'category': category,
          'subcategory': subcategory,
          'sellerId': sellerId,
          'sellerName': sellerName,
          'location': location.trim(),
          'condition': condition.label,
        });
    if (!response.isSuccess || response.data['success'] == false) {
      return null;
    }
    final Map<String, dynamic>? payload =
        ApiPayloadReader.readMap(response.data['data']) ??
        ApiPayloadReader.readMap(response.data['product']) ??
        ApiPayloadReader.readMap(response.data);
    if (payload == null || payload.isEmpty) {
      return null;
    }
    return ProductModel.fromApiJson(payload);
  }

  Map<String, dynamic> _resolveMarketplacePayload(
    Map<String, dynamic> response,
  ) {
    final Map<String, dynamic>? data = ApiPayloadReader.readMap(
      response['data'],
    );
    final Map<String, dynamic>? result = ApiPayloadReader.readMap(
      response['result'],
    );
    final Map<String, dynamic>? payload = ApiPayloadReader.readMap(
      response['payload'],
    );
    return data ?? result ?? payload ?? response;
  }

  Map<String, dynamic> _readRequiredPayload(
    Map<String, dynamic> response, {
    required String fallbackMessage,
  }) {
    final Map<String, dynamic>? payload =
        ApiPayloadReader.readMap(response['data']) ??
        ApiPayloadReader.readMap(response['result']) ??
        ApiPayloadReader.readMap(response['payload']) ??
        ApiPayloadReader.readMap(response);
    if (payload == null || payload.isEmpty) {
      throw Exception(fallbackMessage);
    }
    return payload;
  }

  List<Map<String, dynamic>> _readMapListResponse(
    Map<String, dynamic> response, {
    required String fallbackMessage,
  }) {
    final List<Map<String, dynamic>> items =
        ApiPayloadReader.readMapListFromAny(response['data']);
    if (items.isNotEmpty) {
      return items;
    }
    final List<Map<String, dynamic>> fallbackItems =
        ApiPayloadReader.readMapListFromAny(response);
    if (fallbackItems.isNotEmpty) {
      return fallbackItems;
    }
    throw Exception(fallbackMessage);
  }

  void _throwIfRequestFailed(
    ServiceResponseModel<Map<String, dynamic>> response, {
    required String fallbackMessage,
  }) {
    if (response.isSuccess && response.data['success'] != false) {
      return;
    }
    throw Exception(
      response.data['message']?.toString().trim().isNotEmpty == true
          ? response.data['message'].toString()
          : fallbackMessage,
    );
  }

  bool _readBooleanResult(
    Map<String, dynamic> response, {
    required bool defaultValue,
  }) {
    final Map<String, dynamic>? payload = ApiPayloadReader.readMap(
      response['data'],
    );
    final bool? result = ApiPayloadReader.readBool(
      payload?['following'] ?? response['following'],
    );
    return result ?? defaultValue;
  }

  List<SellerModel> _readSellers(
    Map<String, dynamic> payload,
    List<ProductModel> products,
  ) {
    final List<Map<String, dynamic>> items = ApiPayloadReader.readMapList(
      payload,
      preferredKeys: const <String>['sellers'],
    );
    if (items.isNotEmpty) {
      final List<SellerModel> sellers = items
          .map(SellerModel.fromApiJson)
          .where((SellerModel item) => item.id.isNotEmpty)
          .toList(growable: false);
      if (sellers.isNotEmpty) {
        return sellers;
      }
    }
    return _deriveSellers(products);
  }

  List<MarketplaceCategoryModel> _readCategories(
    Map<String, dynamic> payload,
    List<ProductModel> products,
  ) {
    final List<Map<String, dynamic>> items = ApiPayloadReader.readMapList(
      payload,
      preferredKeys: const <String>['categories'],
    );
    if (items.isNotEmpty) {
      final List<MarketplaceCategoryModel> categories = items
          .map(_categoryFromApiJson)
          .where((MarketplaceCategoryModel item) => item.name.isNotEmpty)
          .toList(growable: false);
      if (categories.isNotEmpty) {
        return categories;
      }
    }
    return _deriveCategories(products);
  }

  MarketplaceCategoryModel _categoryFromApiJson(Map<String, dynamic> json) {
    final String name = ApiPayloadReader.readString(
      json['name'] ?? json['title'],
    );
    return MarketplaceCategoryModel(
      name: name,
      icon: _iconForCategory(name),
      subcategories: ApiPayloadReader.readStringList(
        json['subcategories'] ?? json['children'],
      ),
      isFollowed:
          ApiPayloadReader.readBool(
            json['isFollowed'] ?? json['followed'] ?? json['following'],
          ) ??
          false,
    );
  }

  List<ProductModel> _readDraftProducts(Map<String, dynamic> payload) {
    final List<Map<String, dynamic>> items = ApiPayloadReader.readMapList(
      payload,
      preferredKeys: const <String>['drafts'],
    );
    return items
        .map(
          (Map<String, dynamic> item) => _draftProductFromApiJson(
            item,
            sellerId: ApiPayloadReader.readString(
              item['sellerId'] ?? item['userId'],
            ),
            sellerName: ApiPayloadReader.readString(
              item['sellerName'],
              fallback: 'Draft listing',
            ),
            sellerType: SellerType.individual,
          ),
        )
        .where((ProductModel item) => item.id.isNotEmpty)
        .toList(growable: false);
  }

  ProductModel _draftProductFromApiJson(
    Map<String, dynamic> json, {
    required String sellerId,
    required String sellerName,
    required SellerType sellerType,
  }) {
    final Map<String, dynamic>? metadata = ApiPayloadReader.readMap(
      json['metadata'],
    );
    final Map<String, dynamic>? attributes = ApiPayloadReader.readMap(
      metadata?['attributes'],
    );
    final List<String> deliveryOptionValues = ApiPayloadReader.readStringList(
      metadata?['deliveryOptions'],
    );
    final List<String> images = ApiPayloadReader.readStringList(json['images']);
    return ProductModel(
      id: ApiPayloadReader.readString(json['id']),
      title: ApiPayloadReader.readString(
        json['title'],
        fallback: 'Untitled draft',
      ),
      description: ApiPayloadReader.readString(json['description']),
      price: ApiPayloadReader.readDouble(json['price']),
      category: ApiPayloadReader.readString(
        json['category'],
        fallback: 'General',
      ),
      subcategory: ApiPayloadReader.readString(
        json['subcategory'],
        fallback: ApiPayloadReader.readString(
          json['category'],
          fallback: 'General',
        ),
      ),
      condition: ProductModel.fromApiJson(<String, dynamic>{
        'condition': json['condition'],
      }).condition,
      location: ApiPayloadReader.readString(
        json['location'],
        fallback: 'Draft',
      ),
      distanceLabel: 'Draft',
      timePosted:
          ApiPayloadReader.readDateTime(
            json['updatedAt'] ?? json['createdAt'],
          ) ??
          DateTime.now(),
      images: images.isNotEmpty
          ? images
          : const <String>[
              'https://images.unsplash.com/photo-1512436991641-6745cdb1723f?auto=format&fit=crop&w=1200&q=80',
            ],
      sellerId: sellerId,
      sellerName: sellerName,
      sellerType: sellerType,
      isNegotiable:
          ApiPayloadReader.readBool(metadata?['isNegotiable']) ?? false,
      deliveryOptions: _deliveryOptionsFromStrings(deliveryOptionValues),
      attributes: attributes == null
          ? const <String, String>{}
          : attributes.map<String, String>(
              (String key, dynamic value) =>
                  MapEntry(key, value?.toString() ?? ''),
            ),
      tags: ApiPayloadReader.readStringList(metadata?['tags']),
      brand: ApiPayloadReader.readString(
        attributes?['Brand'],
        fallback: sellerName,
      ),
      quantity: ApiPayloadReader.readInt(metadata?['quantity']),
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
    );
  }

  List<MarketplaceChatMessage> _readChatMessages(Map<String, dynamic> payload) {
    final List<Map<String, dynamic>> items = ApiPayloadReader.readMapList(
      payload,
      preferredKeys: const <String>['chatMessages', 'messages', 'chats'],
    );
    return items
        .map(_readChatMessage)
        .where((MarketplaceChatMessage item) => item.id.isNotEmpty)
        .toList(growable: false);
  }

  MarketplaceChatMessage _readChatMessage(Map<String, dynamic> item) {
    return MarketplaceChatMessage(
      id: ApiPayloadReader.readString(item['id']),
      senderId: ApiPayloadReader.readString(item['senderId']),
      senderName: ApiPayloadReader.readString(
        item['senderName'] ?? item['sender'] ?? item['author'],
        fallback: 'Seller',
      ),
      text: ApiPayloadReader.readString(
        item['text'] ?? item['message'] ?? item['body'],
      ),
      timestamp:
          ApiPayloadReader.readDateTime(
            item['timestamp'] ?? item['createdAt'] ?? item['sentAt'],
          ) ??
          DateTime.now(),
      productId: ApiPayloadReader.readString(item['productId']),
      productTitle: ApiPayloadReader.readString(
        item['productTitle'] ?? item['listingTitle'],
      ),
      imageUrl: ApiPayloadReader.readString(item['imageUrl']),
      isOffer: ApiPayloadReader.readBool(item['isOffer']) ?? false,
      offerAmount: ApiPayloadReader.readDouble(item['offerAmount']),
    );
  }

  List<MarketplaceOfferEvent> _readOfferHistory(Map<String, dynamic> payload) {
    final List<Map<String, dynamic>> items = ApiPayloadReader.readMapList(
      payload,
      preferredKeys: const <String>['offerHistory', 'offers'],
    );
    return items
        .map(_readOfferEvent)
        .where((MarketplaceOfferEvent item) => item.actor.isNotEmpty)
        .toList(growable: false);
  }

  MarketplaceOfferEvent _readOfferEvent(Map<String, dynamic> item) {
    return MarketplaceOfferEvent(
      id: ApiPayloadReader.readString(item['id']),
      productId: ApiPayloadReader.readString(item['productId']),
      actor: ApiPayloadReader.readString(
        item['actor'] ?? item['senderName'],
        fallback: 'User',
      ),
      action: ApiPayloadReader.readString(
        item['action'] ?? item['type'],
        fallback: 'Offered',
      ),
      amount: ApiPayloadReader.readDouble(item['amount'] ?? item['price']),
      timestamp:
          ApiPayloadReader.readDateTime(
            item['timestamp'] ?? item['createdAt'] ?? item['updatedAt'],
          ) ??
          DateTime.now(),
      status: ApiPayloadReader.readString(item['status']),
      note: ApiPayloadReader.readString(item['note']),
    );
  }

  List<MarketplaceOrderModel> _readOrders(Map<String, dynamic> payload) {
    final List<Map<String, dynamic>> items = ApiPayloadReader.readMapList(
      payload,
      preferredKeys: const <String>['orders'],
    );
    return items
        .map(
          (Map<String, dynamic> item) => MarketplaceOrderModel(
            id: ApiPayloadReader.readString(item['id']),
            productId: ApiPayloadReader.readString(
              item['productId'] ?? item['listingId'],
            ),
            productTitle: ApiPayloadReader.readString(
              item['productTitle'] ?? item['title'],
            ),
            amount: ApiPayloadReader.readDouble(
              item['amount'] ?? item['price'],
            ),
            status: _orderStatusFromValue(item['status']),
            address: ApiPayloadReader.readString(item['address']),
            deliveryMethod: ApiPayloadReader.readString(
              item['deliveryMethod'] ?? item['shippingMethod'],
            ),
            paymentMethod: ApiPayloadReader.readString(item['paymentMethod']),
            createdAt:
                ApiPayloadReader.readDateTime(item['createdAt']) ??
                DateTime.now(),
          ),
        )
        .where((MarketplaceOrderModel item) => item.id.isNotEmpty)
        .toList(growable: false);
  }

  MarketplaceOrderStatus _orderStatusFromValue(Object? value) {
    switch ((value?.toString() ?? '').trim().toLowerCase()) {
      case 'pending':
        return MarketplaceOrderStatus.pending;
      case 'processing':
      case 'confirmed':
        return MarketplaceOrderStatus.confirmed;
      case 'shipped':
        return MarketplaceOrderStatus.shipped;
      case 'delivered':
        return MarketplaceOrderStatus.delivered;
      case 'cancelled':
      case 'canceled':
        return MarketplaceOrderStatus.cancelled;
      case 'returned':
        return MarketplaceOrderStatus.returned;
      default:
        return MarketplaceOrderStatus.pending;
    }
  }

  List<SellerModel> _deriveSellers(List<ProductModel> products) {
    final Map<String, SellerModel> sellersById = <String, SellerModel>{};
    for (final ProductModel product in products) {
      if (product.sellerId.isEmpty) {
        continue;
      }
      sellersById.putIfAbsent(
        product.sellerId,
        () => SellerModel(
          id: product.sellerId,
          name: product.sellerName,
          avatar: '',
          bio: 'Marketplace seller on OptiZenqor.',
          joinDate: DateTime.now(),
          rating: product.rating,
          responseRate: 0,
          responseTime: '',
          followers: 0,
          following: 0,
          isVerified: product.sellerType == SellerType.verified,
          sellerType: product.sellerType,
          activeListings: products
              .where((ProductModel item) => item.sellerId == product.sellerId)
              .length,
          completedOrders: 0,
          reviews: product.reviews
              .map(
                (ProductReview item) => SellerReview(
                  buyerName: item.author,
                  rating: item.rating,
                  comment: item.comment,
                  dateLabel: item.dateLabel,
                ),
              )
              .toList(growable: false),
          storeName: product.sellerName,
          strikeStatus: '',
        ),
      );
    }
    return sellersById.values.toList(growable: false);
  }

  List<MarketplaceCategoryModel> _deriveCategories(
    List<ProductModel> products,
  ) {
    final Map<String, Set<String>> categoryMap = <String, Set<String>>{};
    for (final ProductModel product in products) {
      categoryMap.putIfAbsent(product.category, () => <String>{});
      if (product.subcategory.isNotEmpty) {
        categoryMap[product.category]!.add(product.subcategory);
      }
    }

    return categoryMap.entries
        .map(
          (MapEntry<String, Set<String>> entry) => MarketplaceCategoryModel(
            name: entry.key,
            icon: _iconForCategory(entry.key),
            subcategories: entry.value.toList(growable: false),
          ),
        )
        .toList(growable: false);
  }

  IconData _iconForCategory(String category) {
    switch (category.trim().toLowerCase()) {
      case 'electronics':
        return Icons.devices_other_outlined;
      case 'home & furniture':
        return Icons.weekend_outlined;
      case 'beauty & personal care':
        return Icons.spa_outlined;
      case 'sports & outdoors':
        return Icons.sports_basketball_outlined;
      case 'digital products':
        return Icons.cloud_download_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  List<DeliveryOption> _deliveryOptionsFromStrings(List<String> values) {
    if (values.isEmpty) {
      return const <DeliveryOption>[DeliveryOption.pickup];
    }
    return values
        .map((String value) {
          switch (value.trim().toLowerCase()) {
            case 'shipping':
              return DeliveryOption.shipping;
            case 'local delivery':
            case 'delivery':
              return DeliveryOption.delivery;
            case 'pickup':
            default:
              return DeliveryOption.pickup;
          }
        })
        .toList(growable: false);
  }

  String _listingStatusValue(ListingStatus status) {
    switch (status) {
      case ListingStatus.active:
        return 'active';
      case ListingStatus.sold:
        return 'sold';
      case ListingStatus.expired:
        return 'expired';
      case ListingStatus.pending:
        return 'pending';
      case ListingStatus.draft:
        return 'draft';
    }
  }
}
