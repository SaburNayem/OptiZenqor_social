import 'product_model.dart';

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
}
