import 'package:flutter/material.dart';

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
    final MarketplaceSeedData? remoteData = await _loadRemoteMarketplace();
    return remoteData ??
        const MarketplaceSeedData(
          products: <ProductModel>[],
          sellers: <SellerModel>[],
          categories: <MarketplaceCategoryModel>[],
          savedItemIds: <String>[],
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

  Future<MarketplaceSeedData?> _loadRemoteMarketplace() async {
    for (final String key in <String>['marketplace', 'products']) {
      try {
        final ServiceResponseModel<Map<String, dynamic>> response =
            await _service.getEndpoint(key);
        if (!response.isSuccess || response.data['success'] == false) {
          continue;
        }

        final Map<String, dynamic> payload = _resolveMarketplacePayload(
          response.data,
        );
        final List<Map<String, dynamic>> productItems =
            ApiPayloadReader.readMapList(
          payload,
          preferredKeys: const <String>['products', 'items'],
        );
        if (productItems.isEmpty) {
          continue;
        }

        final List<ProductModel> products = productItems
            .map(ProductModel.fromApiJson)
            .where((ProductModel item) => item.id.isNotEmpty)
            .toList(growable: false);
        if (products.isEmpty) {
          continue;
        }

        final List<SellerModel> sellers = _readSellers(payload, products);
        final List<MarketplaceCategoryModel> categories = _readCategories(
          payload,
          products,
        );

        return MarketplaceSeedData(
          products: products,
          sellers: sellers,
          categories: categories,
          savedItemIds: ApiPayloadReader.readStringList(payload['savedItemIds']),
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
      } catch (_) {}
    }

    return null;
  }

  Map<String, dynamic> _resolveMarketplacePayload(Map<String, dynamic> response) {
    final Map<String, dynamic>? data = ApiPayloadReader.readMap(response['data']);
    final Map<String, dynamic>? result = ApiPayloadReader.readMap(
      response['result'],
    );
    final Map<String, dynamic>? payload = ApiPayloadReader.readMap(
      response['payload'],
    );
    return data ?? result ?? payload ?? response;
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

  List<MarketplaceChatMessage> _readChatMessages(Map<String, dynamic> payload) {
    final List<Map<String, dynamic>> items = ApiPayloadReader.readMapList(
      payload,
      preferredKeys: const <String>['chatMessages', 'messages', 'chats'],
    );
    return items
        .map(
          (Map<String, dynamic> item) => MarketplaceChatMessage(
            id: ApiPayloadReader.readString(item['id']),
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
            productTitle: ApiPayloadReader.readString(
              item['productTitle'] ?? item['listingTitle'],
            ),
          ),
        )
        .where((MarketplaceChatMessage item) => item.id.isNotEmpty)
        .toList(growable: false);
  }

  List<MarketplaceOfferEvent> _readOfferHistory(Map<String, dynamic> payload) {
    final List<Map<String, dynamic>> items = ApiPayloadReader.readMapList(
      payload,
      preferredKeys: const <String>['offerHistory', 'offers'],
    );
    return items
        .map(
          (Map<String, dynamic> item) => MarketplaceOfferEvent(
            actor: ApiPayloadReader.readString(
              item['actor'] ?? item['senderName'],
              fallback: 'User',
            ),
            action: ApiPayloadReader.readString(
              item['action'] ?? item['type'],
              fallback: 'Offered',
            ),
            amount: ApiPayloadReader.readDouble(
              item['amount'] ?? item['price'],
            ),
            timestamp:
                ApiPayloadReader.readDateTime(
                  item['timestamp'] ?? item['createdAt'],
                ) ??
                DateTime.now(),
          ),
        )
        .where((MarketplaceOfferEvent item) => item.actor.isNotEmpty)
        .toList(growable: false);
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
            amount: ApiPayloadReader.readDouble(item['amount'] ?? item['price']),
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

  List<MarketplaceCategoryModel> _deriveCategories(List<ProductModel> products) {
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
}
