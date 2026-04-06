import 'product_model.dart';

enum MarketplaceSort { latest, nearest, priceLowHigh, priceHighLow, relevant }

extension MarketplaceSortLabel on MarketplaceSort {
  String get label {
    switch (this) {
      case MarketplaceSort.latest:
        return 'Latest';
      case MarketplaceSort.nearest:
        return 'Nearest';
      case MarketplaceSort.priceLowHigh:
        return 'Price low-high';
      case MarketplaceSort.priceHighLow:
        return 'Price high-low';
      case MarketplaceSort.relevant:
        return 'Most relevant';
    }
  }
}

class MarketplaceFilterModel {
  const MarketplaceFilterModel({
    this.category,
    this.minPrice = 0,
    this.maxPrice = 5000,
    this.locationRadius = 25,
    this.condition,
    this.deliveryAvailable = false,
    this.negotiableOnly = false,
    this.verifiedSellersOnly = false,
    this.sortBy = MarketplaceSort.relevant,
  });

  final String? category;
  final double minPrice;
  final double maxPrice;
  final double locationRadius;
  final ProductCondition? condition;
  final bool deliveryAvailable;
  final bool negotiableOnly;
  final bool verifiedSellersOnly;
  final MarketplaceSort sortBy;

  MarketplaceFilterModel copyWith({
    String? category,
    double? minPrice,
    double? maxPrice,
    double? locationRadius,
    ProductCondition? condition,
    bool? clearCondition,
    bool? deliveryAvailable,
    bool? negotiableOnly,
    bool? verifiedSellersOnly,
    MarketplaceSort? sortBy,
  }) {
    return MarketplaceFilterModel(
      category: category ?? this.category,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      locationRadius: locationRadius ?? this.locationRadius,
      condition: clearCondition == true ? null : condition ?? this.condition,
      deliveryAvailable: deliveryAvailable ?? this.deliveryAvailable,
      negotiableOnly: negotiableOnly ?? this.negotiableOnly,
      verifiedSellersOnly: verifiedSellersOnly ?? this.verifiedSellersOnly,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}
