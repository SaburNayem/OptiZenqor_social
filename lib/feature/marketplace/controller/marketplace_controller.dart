import 'package:flutter/foundation.dart';

import '../../../core/common_data/mock_data.dart';
import '../../../core/common_models/product_model.dart';

class MarketplaceController extends ChangeNotifier {
  List<ProductModel> products = <ProductModel>[];

  Future<void> load() async {
    await Future<void>.delayed(const Duration(milliseconds: 360));
    products = MockData.products;
    notifyListeners();
  }
}
