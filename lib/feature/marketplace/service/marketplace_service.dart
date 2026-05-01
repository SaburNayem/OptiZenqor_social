import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class MarketplaceService extends FeatureServiceBase {
  MarketplaceService({super.apiClient});

  @override
  String get featureName => 'marketplace';

  @override
  Map<String, String> get endpoints => <String, String>{
    'marketplace': ApiEndPoints.marketplace,
    'products': ApiEndPoints.marketplaceProducts,
    'compare': ApiEndPoints.marketplaceCompare,
    'checkout': ApiEndPoints.marketplaceCheckout,
    'drafts': ApiEndPoints.marketplaceDrafts,
    'sellerFollows': ApiEndPoints.marketplaceSellerFollows,
  };
}
