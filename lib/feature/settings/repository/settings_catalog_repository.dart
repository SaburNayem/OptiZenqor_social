import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service/api_client_service.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/settings_item_model.dart';
import '../model/settings_section_model.dart';

class SettingsCatalogRepository {
  SettingsCatalogRepository({ApiClientService? apiClient})
    : _apiClient = apiClient ?? ApiClientService();

  final ApiClientService _apiClient;

  Future<List<SettingsSectionModel>> fetchSections() async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _apiClient
        .get(ApiEndPoints.settings);
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to load settings.');
    }

    final List<Map<String, dynamic>> sections = ApiPayloadReader.readMapList(
      response.data,
      preferredKeys: const <String>['data'],
    );
    return sections.map(_mapSection).toList(growable: false);
  }

  SettingsSectionModel _mapSection(Map<String, dynamic> json) {
    final List<SettingsItemModel> items = ApiPayloadReader.readMapListFromAny(
      json['items'],
    ).map(_mapItem).toList(growable: false);

    return SettingsSectionModel(
      title: ApiPayloadReader.readString(json['title']),
      description: ApiPayloadReader.readString(json['description']),
      items: items,
    );
  }

  SettingsItemModel _mapItem(Map<String, dynamic> json) {
    return SettingsItemModel(
      title: ApiPayloadReader.readString(json['title']),
      subtitle: ApiPayloadReader.readString(json['subtitle']).isEmpty
          ? null
          : ApiPayloadReader.readString(json['subtitle']),
      routeName: ApiPayloadReader.readString(json['routeName']).isEmpty
          ? null
          : ApiPayloadReader.readString(json['routeName']),
    );
  }
}
