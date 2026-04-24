import '../../../core/constants/storage_keys.dart';
import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service/local_storage_service.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/page_model.dart';
import '../service/pages_service.dart';

class PagesRepository {
  PagesRepository({
    PagesService? service,
    LocalStorageService? storage,
  }) : _service = service ?? PagesService(),
       _storage = storage ?? LocalStorageService();

  final PagesService _service;
  final LocalStorageService _storage;

  Future<List<PageModel>> load() async {
    final List<PageModel>? remotePages = await _loadFromApi();
    if (remotePages != null) {
      return remotePages;
    }
    return const <PageModel>[];
  }

  Future<String> currentUserId() async {
    final Map<String, dynamic>? authSession = await _storage.readJson(
      StorageKeys.authSession,
    );
    final Object? user = authSession?['user'];
    if (user is Map<String, dynamic>) {
      return ApiPayloadReader.readString(user['id']);
    }
    if (user is Map) {
      return ApiPayloadReader.readString(user['id']);
    }
    return '';
  }

  Future<List<PageModel>?> _loadFromApi() async {
    try {
      final ServiceResponseModel<Map<String, dynamic>> response =
          await _service.getEndpoint('pages');
      if (!response.isSuccess || response.data['success'] == false) {
        return null;
      }
      final Map<String, dynamic> payload =
          ApiPayloadReader.readMap(response.data['data']) ?? response.data;
      final List<Map<String, dynamic>> items = ApiPayloadReader.readMapList(
        payload,
        preferredKeys: const <String>['pages', 'items'],
      );
      if (items.isNotEmpty) {
        return items
            .map(PageModel.fromApiJson)
            .where((PageModel item) => item.id.isNotEmpty)
            .toList(growable: false);
      }
      final Map<String, dynamic>? singlePage = ApiPayloadReader.readMap(
        payload['page'] ?? payload['item'],
      );
      if (singlePage != null && singlePage.isNotEmpty) {
        final PageModel page = PageModel.fromApiJson(singlePage);
        if (page.id.isNotEmpty) {
          return <PageModel>[page];
        }
      }
    } catch (_) {}
    return null;
  }
}
