import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service/api_client_service.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/trending_item_model.dart';

class TrendingRepository {
  TrendingRepository({ApiClientService? apiClient})
    : _apiClient = apiClient ?? ApiClientService();

  final ApiClientService _apiClient;

  Future<List<TrendingItemModel>> load() async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _apiClient
        .get(ApiEndPoints.trending);
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(
        response.data['message']?.toString() ?? 'Failed to load trending data.',
      );
    }

    final List<TrendingItemModel> items =
        ApiPayloadReader.readMapList(
              response.data,
              preferredKeys: const <String>['data', 'items', 'results'],
            )
            .map(TrendingItemModel.fromApiJson)
            .where((TrendingItemModel item) {
              return item.title.isNotEmpty;
            })
            .toList(growable: false);

    return items;
  }
}
