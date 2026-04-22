import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class SellerProfileService extends FeatureServiceBase {
  SellerProfileService({super.apiClient});

  @override
  String get featureName => 'seller_profile';

  @override
  Map<String, String> get endpoints => <String, String>{
    'products': ApiEndPoints.marketplaceProducts,
    'user_profile': ApiEndPoints.userById(':id'),
  };
}
