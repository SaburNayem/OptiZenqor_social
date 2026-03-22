import 'package:flutter/foundation.dart';

import '../../../core/common_models/load_state_model.dart';
import '../../../core/common_models/product_model.dart';
import '../repository/marketplace_repository.dart';

class MarketplaceController extends ChangeNotifier {
  MarketplaceController({MarketplaceRepository? repository})
      : _repository = repository ?? MarketplaceRepository();

  final MarketplaceRepository _repository;

  LoadStateModel state = const LoadStateModel();
  List<ProductModel> products = <ProductModel>[];
  String searchQuery = '';

  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();
    try {
      products = await _repository.fetchProducts(query: searchQuery);
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        isEmpty: products.isEmpty,
      );
      notifyListeners();
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Unable to load marketplace',
      );
      notifyListeners();
    }
  }

  Future<void> updateSearch(String query) async {
    searchQuery = query;
    await load();
  }
}
