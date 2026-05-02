import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/page_model.dart';
import '../service/pages_service.dart';

class PagesRepository {
  PagesRepository({PagesService? service})
    : _service = service ?? PagesService();

  final PagesService _service;

  Future<List<PageModel>> load() async {
    final List<PageModel>? remotePages = await _loadFromApi();
    if (remotePages != null) {
      return remotePages;
    }
    return const <PageModel>[];
  }

  Future<PageModel?> createPage({
    required String name,
    required String about,
    required String category,
  }) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .post('/pages/create', <String, dynamic>{
          'name': name.trim(),
          'about': about.trim(),
          'category': category.trim(),
        });
    if (!response.isSuccess || response.data['success'] == false) {
      return null;
    }
    final Map<String, dynamic>? payload =
        ApiPayloadReader.readMap(response.data['data']) ??
        ApiPayloadReader.readMap(response.data['page']) ??
        ApiPayloadReader.readMap(response.data['item']) ??
        ApiPayloadReader.readMap(response.data);
    if (payload == null || payload.isEmpty) {
      return null;
    }
    final PageModel page = PageModel.fromApiJson(payload);
    return page.id.isNotEmpty ? page : null;
  }

  Future<PageModel?> toggleFollow(String pageId) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .patch('/pages/$pageId/follow', const <String, dynamic>{});
    if (!response.isSuccess || response.data['success'] == false) {
      return null;
    }
    final Map<String, dynamic>? payload =
        ApiPayloadReader.readMap(response.data['data']) ??
        ApiPayloadReader.readMap(response.data['page']) ??
        ApiPayloadReader.readMap(response.data['item']) ??
        ApiPayloadReader.readMap(response.data);
    if (payload == null || payload.isEmpty) {
      return null;
    }
    final PageModel page = PageModel.fromApiJson(payload);
    return page.id.isNotEmpty ? page : null;
  }

  Future<String> currentUserId() async {
    try {
      final ServiceResponseModel<Map<String, dynamic>> response = await _service
          .apiClient
          .get('/auth/me');
      if (!response.isSuccess || response.data['success'] == false) {
        return '';
      }
      final Map<String, dynamic>? payload =
          ApiPayloadReader.readMap(response.data['data']) ??
          ApiPayloadReader.readMap(response.data['user']) ??
          ApiPayloadReader.readMap(response.data);
      if (payload != null && payload.isNotEmpty) {
        return ApiPayloadReader.readString(payload['id']);
      }
    } catch (_) {
      return '';
    }
    return '';
  }

  Future<List<PageModel>?> _loadFromApi() async {
    try {
      final ServiceResponseModel<Map<String, dynamic>> response = await _service
          .getEndpoint('pages');
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
