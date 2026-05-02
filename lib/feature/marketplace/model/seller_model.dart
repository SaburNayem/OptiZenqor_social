import 'product_model.dart';
import '../../../core/data/api/api_payload_reader.dart';

class SellerReview {
  const SellerReview({
    required this.buyerName,
    required this.rating,
    required this.comment,
    required this.dateLabel,
  });

  final String buyerName;
  final double rating;
  final String comment;
  final String dateLabel;
}

class SellerModel {
  const SellerModel({
    required this.id,
    required this.name,
    required this.avatar,
    required this.bio,
    required this.joinDate,
    required this.rating,
    required this.responseRate,
    required this.responseTime,
    required this.followers,
    required this.following,
    required this.isVerified,
    required this.sellerType,
    required this.activeListings,
    required this.completedOrders,
    required this.reviews,
    required this.storeName,
    required this.strikeStatus,
  });

  final String id;
  final String name;
  final String avatar;
  final String bio;
  final DateTime joinDate;
  final double rating;
  final int responseRate;
  final String responseTime;
  final int followers;
  final int following;
  final bool isVerified;
  final SellerType sellerType;
  final int activeListings;
  final int completedOrders;
  final List<SellerReview> reviews;
  final String storeName;
  final String strikeStatus;

  factory SellerModel.fromApiJson(Map<String, dynamic> json) {
    return SellerModel(
      id: ApiPayloadReader.readString(json['id']),
      name: ApiPayloadReader.readString(json['name']),
      avatar: ApiPayloadReader.readString(json['avatar'] ?? json['avatarUrl']),
      bio: ApiPayloadReader.readString(json['bio'] ?? json['description']),
      joinDate:
          ApiPayloadReader.readDateTime(
            json['joinDate'] ?? json['createdAt'],
          ) ??
          DateTime.now(),
      rating: ApiPayloadReader.readDouble(json['rating']),
      responseRate: ApiPayloadReader.readInt(json['responseRate']),
      responseTime: ApiPayloadReader.readString(json['responseTime']),
      followers: ApiPayloadReader.readInt(json['followers']),
      following: ApiPayloadReader.readInt(json['following']),
      isVerified:
          ApiPayloadReader.readBool(json['isVerified'] ?? json['verified']) ??
          false,
      sellerType: _sellerTypeFromValue(json['sellerType'] ?? json['type']),
      activeListings: ApiPayloadReader.readInt(json['activeListings']),
      completedOrders: ApiPayloadReader.readInt(json['completedOrders']),
      reviews: _reviewsFromValue(json['reviews']),
      storeName: ApiPayloadReader.readString(
        json['storeName'],
        fallback: ApiPayloadReader.readString(json['name']),
      ),
      strikeStatus: ApiPayloadReader.readString(json['strikeStatus']),
    );
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

  static List<SellerReview> _reviewsFromValue(Object? value) {
    final List<Map<String, dynamic>> items =
        ApiPayloadReader.readMapListFromAny(value);
    return items
        .map(
          (Map<String, dynamic> item) => SellerReview(
            buyerName: ApiPayloadReader.readString(
              item['buyerName'] ?? item['author'],
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
}
