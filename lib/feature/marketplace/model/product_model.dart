import 'package:flutter/material.dart';
import '../../../core/data/api/api_payload_reader.dart';

enum ProductCondition { newItem, likeNew, good, fair, refurbished }

enum SellerType { individual, shop, verified }

enum DeliveryOption { pickup, shipping, delivery }

enum ListingStatus { active, pending, sold, expired, draft }

extension ProductConditionLabel on ProductCondition {
  String get label {
    switch (this) {
      case ProductCondition.newItem:
        return 'New';
      case ProductCondition.likeNew:
        return 'Like New';
      case ProductCondition.good:
        return 'Good';
      case ProductCondition.fair:
        return 'Fair';
      case ProductCondition.refurbished:
        return 'Refurbished';
    }
  }
}

extension SellerTypeLabel on SellerType {
  String get label {
    switch (this) {
      case SellerType.individual:
        return 'Individual';
      case SellerType.shop:
        return 'Shop';
      case SellerType.verified:
        return 'Verified';
    }
  }
}

extension DeliveryOptionLabel on DeliveryOption {
  String get label {
    switch (this) {
      case DeliveryOption.pickup:
        return 'Pickup';
      case DeliveryOption.shipping:
        return 'Shipping';
      case DeliveryOption.delivery:
        return 'Local delivery';
    }
  }

  IconData get icon {
    switch (this) {
      case DeliveryOption.pickup:
        return Icons.storefront_outlined;
      case DeliveryOption.shipping:
        return Icons.local_shipping_outlined;
      case DeliveryOption.delivery:
        return Icons.delivery_dining_outlined;
    }
  }
}

extension ListingStatusLabel on ListingStatus {
  String get label {
    switch (this) {
      case ListingStatus.active:
        return 'Active';
      case ListingStatus.pending:
        return 'Pending review';
      case ListingStatus.sold:
        return 'Sold';
      case ListingStatus.expired:
        return 'Expired';
      case ListingStatus.draft:
        return 'Draft';
    }
  }
}

class ProductReview {
  const ProductReview({
    required this.author,
    required this.rating,
    required this.comment,
    required this.dateLabel,
  });

  final String author;
  final double rating;
  final String comment;
  final String dateLabel;
}

class ProductModel {
  const ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.subcategory,
    required this.condition,
    required this.location,
    required this.distanceLabel,
    required this.timePosted,
    required this.images,
    required this.sellerId,
    required this.sellerName,
    required this.sellerType,
    required this.isNegotiable,
    required this.deliveryOptions,
    required this.attributes,
    required this.tags,
    required this.brand,
    required this.quantity,
    required this.isFeatured,
    required this.isTrending,
    required this.isRecommended,
    required this.isRecentlyViewed,
    required this.hasPriceDrop,
    required this.isAuction,
    required this.rating,
    required this.reviewCount,
    required this.reviews,
    required this.listingStatus,
    required this.views,
    required this.watchers,
    required this.chats,
    required this.isHiddenByModeration,
    required this.reviewStatus,
  });

  final String id;
  final String title;
  final String description;
  final double price;
  final String category;
  final String subcategory;
  final ProductCondition condition;
  final String location;
  final String distanceLabel;
  final DateTime timePosted;
  final List<String> images;
  final String sellerId;
  final String sellerName;
  final SellerType sellerType;
  final bool isNegotiable;
  final List<DeliveryOption> deliveryOptions;
  final Map<String, String> attributes;
  final List<String> tags;
  final String brand;
  final int quantity;
  final bool isFeatured;
  final bool isTrending;
  final bool isRecommended;
  final bool isRecentlyViewed;
  final bool hasPriceDrop;
  final bool isAuction;
  final double rating;
  final int reviewCount;
  final List<ProductReview> reviews;
  final ListingStatus listingStatus;
  final int views;
  final int watchers;
  final int chats;
  final bool isHiddenByModeration;
  final String reviewStatus;

  factory ProductModel.fromApiJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? seller = ApiPayloadReader.readMap(
      json['seller'],
    );
    final String category = ApiPayloadReader.readString(
      json['category'],
      fallback: 'General',
    );
    final String companyName = ApiPayloadReader.readString(
      seller?['name'] ?? json['sellerName'],
      fallback: 'Unknown seller',
    );
    final String brand = ApiPayloadReader.readString(
      json['brand'] ?? seller?['storeName'],
      fallback: companyName,
    );

    return ProductModel(
      id: ApiPayloadReader.readString(json['id']),
      title: ApiPayloadReader.readString(
        json['title'],
        fallback: 'Marketplace item',
      ),
      description: ApiPayloadReader.readString(json['description']),
      price: ApiPayloadReader.readDouble(json['price']),
      category: category,
      subcategory: ApiPayloadReader.readString(
        json['subcategory'],
        fallback: category,
      ),
      condition: _conditionFromValue(json['condition']),
      location: ApiPayloadReader.readString(
        json['location'],
        fallback: 'Unknown',
      ),
      distanceLabel: ApiPayloadReader.readString(
        json['distanceLabel'],
        fallback: 'Nearby',
      ),
      timePosted:
          ApiPayloadReader.readDateTime(
            json['timePosted'] ?? json['createdAt'],
          ) ??
          DateTime.now(),
      images: ApiPayloadReader.readStringList(json['images'] ?? json['media']),
      sellerId: ApiPayloadReader.readString(json['sellerId'] ?? seller?['id']),
      sellerName: companyName,
      sellerType: _sellerTypeFromValue(
        json['sellerType'] ?? seller?['sellerType'] ?? seller?['type'],
      ),
      isNegotiable: ApiPayloadReader.readBool(json['isNegotiable']) ?? false,
      deliveryOptions: _deliveryOptionsFromValue(json['deliveryOptions']),
      attributes: _attributesFromValue(json['attributes']),
      tags: ApiPayloadReader.readStringList(json['tags']),
      brand: brand,
      quantity: ApiPayloadReader.readInt(json['quantity']),
      isFeatured: ApiPayloadReader.readBool(json['isFeatured']) ?? false,
      isTrending: ApiPayloadReader.readBool(json['isTrending']) ?? false,
      isRecommended: ApiPayloadReader.readBool(json['isRecommended']) ?? false,
      isRecentlyViewed:
          ApiPayloadReader.readBool(json['isRecentlyViewed']) ?? false,
      hasPriceDrop: ApiPayloadReader.readBool(json['hasPriceDrop']) ?? false,
      isAuction: ApiPayloadReader.readBool(json['isAuction']) ?? false,
      rating: ApiPayloadReader.readDouble(json['rating']),
      reviewCount: ApiPayloadReader.readInt(json['reviewCount']),
      reviews: _reviewsFromValue(json['reviews']),
      listingStatus: _listingStatusFromValue(json['listingStatus']),
      views: ApiPayloadReader.readInt(json['views']),
      watchers: ApiPayloadReader.readInt(json['watchers']),
      chats: ApiPayloadReader.readInt(json['chats']),
      isHiddenByModeration:
          ApiPayloadReader.readBool(json['isHiddenByModeration']) ?? false,
      reviewStatus: ApiPayloadReader.readString(
        json['reviewStatus'],
        fallback: 'Approved',
      ),
    );
  }

  ProductModel copyWith({
    double? price,
    bool? isRecentlyViewed,
    ListingStatus? listingStatus,
    bool? isHiddenByModeration,
  }) {
    return ProductModel(
      id: id,
      title: title,
      description: description,
      price: price ?? this.price,
      category: category,
      subcategory: subcategory,
      condition: condition,
      location: location,
      distanceLabel: distanceLabel,
      timePosted: timePosted,
      images: images,
      sellerId: sellerId,
      sellerName: sellerName,
      sellerType: sellerType,
      isNegotiable: isNegotiable,
      deliveryOptions: deliveryOptions,
      attributes: attributes,
      tags: tags,
      brand: brand,
      quantity: quantity,
      isFeatured: isFeatured,
      isTrending: isTrending,
      isRecommended: isRecommended,
      isRecentlyViewed: isRecentlyViewed ?? this.isRecentlyViewed,
      hasPriceDrop: hasPriceDrop,
      isAuction: isAuction,
      rating: rating,
      reviewCount: reviewCount,
      reviews: reviews,
      listingStatus: listingStatus ?? this.listingStatus,
      views: views,
      watchers: watchers,
      chats: chats,
      isHiddenByModeration: isHiddenByModeration ?? this.isHiddenByModeration,
      reviewStatus: reviewStatus,
    );
  }

  static ProductCondition _conditionFromValue(Object? value) {
    switch ((value?.toString() ?? '').trim().toLowerCase()) {
      case 'new':
      case 'newitem':
      case 'new_item':
        return ProductCondition.newItem;
      case 'likenew':
      case 'like_new':
      case 'like new':
        return ProductCondition.likeNew;
      case 'fair':
        return ProductCondition.fair;
      case 'refurbished':
        return ProductCondition.refurbished;
      case 'good':
      default:
        return ProductCondition.good;
    }
  }

  static SellerType _sellerTypeFromValue(Object? value) {
    switch ((value?.toString() ?? '').trim().toLowerCase()) {
      case 'verified':
        return SellerType.verified;
      case 'shop':
      case 'business':
        return SellerType.shop;
      case 'individual':
      default:
        return SellerType.individual;
    }
  }

  static List<DeliveryOption> _deliveryOptionsFromValue(Object? value) {
    final List<String> items = ApiPayloadReader.readStringList(value);
    if (items.isEmpty) {
      return const <DeliveryOption>[DeliveryOption.pickup];
    }
    return items
        .map((String item) {
          switch (item.toLowerCase()) {
            case 'shipping':
              return DeliveryOption.shipping;
            case 'delivery':
            case 'local_delivery':
              return DeliveryOption.delivery;
            case 'pickup':
            default:
              return DeliveryOption.pickup;
          }
        })
        .toList(growable: false);
  }

  static Map<String, String> _attributesFromValue(Object? value) {
    final Map<String, dynamic>? map = ApiPayloadReader.readMap(value);
    if (map == null) {
      return const <String, String>{};
    }
    return map.map<String, String>(
      (String key, dynamic item) => MapEntry(key, item?.toString() ?? ''),
    );
  }

  static List<ProductReview> _reviewsFromValue(Object? value) {
    final List<Map<String, dynamic>> items =
        ApiPayloadReader.readMapListFromAny(value);
    return items
        .map(
          (Map<String, dynamic> item) => ProductReview(
            author: ApiPayloadReader.readString(
              item['author'] ?? item['buyerName'],
              fallback: 'Buyer',
            ),
            rating: ApiPayloadReader.readDouble(item['rating']),
            comment: ApiPayloadReader.readString(item['comment']),
            dateLabel: ApiPayloadReader.readString(
              item['dateLabel'] ?? item['createdAt'],
            ),
          ),
        )
        .toList(growable: false);
  }

  static ListingStatus _listingStatusFromValue(Object? value) {
    switch ((value?.toString() ?? '').trim().toLowerCase()) {
      case 'pending':
        return ListingStatus.pending;
      case 'sold':
        return ListingStatus.sold;
      case 'expired':
        return ListingStatus.expired;
      case 'draft':
        return ListingStatus.draft;
      case 'active':
      default:
        return ListingStatus.active;
    }
  }
}
