import 'package:flutter/material.dart';

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
}
