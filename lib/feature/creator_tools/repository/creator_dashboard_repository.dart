import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/creator_metric_model.dart';
import '../service/creator_tools_service.dart';

class CreatorDashboardRepository {
  CreatorDashboardRepository({CreatorToolsService? service})
    : _service = service ?? CreatorToolsService();

  final CreatorToolsService _service;

  Future<CreatorDashboardPayload> load() async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .getEndpoint('creator_dashboard');
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to load creator dashboard.');
    }

    final Map<String, dynamic> payload =
        ApiPayloadReader.readMap(response.data['data']) ?? response.data;
    final Map<String, dynamic> creator =
        ApiPayloadReader.readMap(payload['creator']) ??
        const <String, dynamic>{};
    final Map<String, dynamic> analytics =
        ApiPayloadReader.readMap(payload['analytics']) ??
        const <String, dynamic>{};
    final Map<String, dynamic> totals =
        ApiPayloadReader.readMap(analytics['totals']) ??
        const <String, dynamic>{};

    final List<CreatorMetricModel> metrics =
        ApiPayloadReader.readMapList(
              payload,
              preferredKeys: const <String>['metrics'],
            )
            .map(CreatorMetricModel.fromApiJson)
            .where((item) => item.label.isNotEmpty)
            .toList(growable: false);

    return CreatorDashboardPayload(
      creatorName: ApiPayloadReader.readString(creator['name']),
      creatorUsername: ApiPayloadReader.readString(creator['username']),
      creatorRole: ApiPayloadReader.readString(creator['role']),
      metrics: metrics,
      totals: <CreatorSummaryItem>[
        CreatorSummaryItem(
          label: 'Posts',
          value: ApiPayloadReader.readString(totals['posts']),
        ),
        CreatorSummaryItem(
          label: 'Reels',
          value: ApiPayloadReader.readString(totals['reels']),
        ),
        CreatorSummaryItem(
          label: 'Story views',
          value: ApiPayloadReader.readString(totals['stories']),
        ),
      ],
      detailItems: <CreatorSummaryItem>[
        CreatorSummaryItem(
          label: 'Followers',
          value: ApiPayloadReader.readString(creator['followers']),
        ),
        CreatorSummaryItem(
          label: 'Following',
          value: ApiPayloadReader.readString(creator['following']),
        ),
        CreatorSummaryItem(
          label: 'Role',
          value: ApiPayloadReader.readString(creator['role']),
        ),
      ],
    );
  }
}
