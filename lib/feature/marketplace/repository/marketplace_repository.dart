import '../../../core/common_data/mock_data.dart';
import '../../../core/common_models/product_model.dart';

class MarketplaceRepository {
  Future<List<ProductModel>> fetchProducts({String? query}) async {
    await Future<void>.delayed(const Duration(milliseconds: 260));
    var items = MockData.products;
    if (query != null && query.trim().isNotEmpty) {
      final term = query.toLowerCase();
      items = items
          .where((item) => item.title.toLowerCase().contains(term))
          .toList();
    }
    return items;
  }
}
