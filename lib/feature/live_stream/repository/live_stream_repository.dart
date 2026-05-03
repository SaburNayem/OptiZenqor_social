import 'package:flutter/material.dart';

import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/live_stream_model.dart';
import '../service/live_stream_service.dart';

class LiveStreamRepository {
  LiveStreamRepository({LiveStreamService? service})
    : _service = service ?? LiveStreamService();

  final LiveStreamService _service;

  Future<LiveStreamModel> load({
    String? initialTitle,
    String? initialPhotoPath,
    LiveAudienceVisibility? initialAudience,
  }) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .getEndpoint('live_stream_setup');
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to load live stream setup.');
    }

    return _mapLiveStream(
      _resolvePayload(response.data),
      initialTitle: initialTitle,
      initialPhotoPath: initialPhotoPath,
      initialAudience: initialAudience,
    );
  }

  Future<LiveStreamModel> startLive({
    required String title,
    required String description,
    required String category,
    required String location,
    required LiveAudienceVisibility audience,
    required List<LiveQuickOptionModel> quickOptions,
    String? existingStreamId,
    String? initialPhotoPath,
  }) async {
    String streamId = existingStreamId?.trim() ?? '';
    if (streamId.isEmpty) {
      final ServiceResponseModel<Map<String, dynamic>> createResponse =
          await _service.apiClient.post(
            _service.endpoints['live_stream']!,
            <String, dynamic>{
              'title': title.trim(),
              'description': description.trim(),
              'category': category.trim(),
              'location': location.trim(),
              'audience': _audienceValue(audience),
              'quickOptions': quickOptions
                  .map(
                    (LiveQuickOptionModel item) => <String, dynamic>{
                      'id': item.id,
                      'label': item.label,
                      'selected': item.selected,
                    },
                  )
                  .toList(growable: false),
            },
          );
      if (!createResponse.isSuccess ||
          createResponse.data['success'] == false) {
        throw Exception(
          createResponse.message ?? 'Unable to create live stream.',
        );
      }
      final Map<String, dynamic> createdPayload = _resolvePayload(
        createResponse.data,
      );
      streamId = ApiPayloadReader.readString(
        createdPayload['id'] ?? createdPayload['streamId'],
      );
      if (streamId.isEmpty) {
        throw Exception('The backend did not return a live stream id.');
      }
    }

    final ServiceResponseModel<Map<String, dynamic>> startResponse =
        await _service.apiClient.patch(
          '/live-stream/$streamId/start',
          const <String, dynamic>{},
        );
    if (!startResponse.isSuccess || startResponse.data['success'] == false) {
      throw Exception(startResponse.message ?? 'Unable to start live stream.');
    }

    return _mapLiveStream(
      _resolvePayload(startResponse.data),
      initialPhotoPath: initialPhotoPath,
      initialAudience: audience,
    );
  }

  Future<LiveStreamModel> endLive(
    String streamId, {
    String? initialPhotoPath,
  }) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .patch('/live-stream/$streamId/end', const <String, dynamic>{});
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to end live stream.');
    }
    return _mapLiveStream(
      _resolvePayload(response.data),
      initialPhotoPath: initialPhotoPath,
    );
  }

  Future<LiveCommentModel> createComment({
    required String streamId,
    required String message,
  }) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .post('/live-stream/$streamId/comments', <String, dynamic>{
          'message': message.trim(),
        });
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to send live comment.');
    }
    final Map<String, dynamic> payload = _resolvePayload(response.data);
    return _mapComment(payload);
  }

  LiveStreamModel _mapLiveStream(
    Map<String, dynamic> payload, {
    String? initialTitle,
    String? initialPhotoPath,
    LiveAudienceVisibility? initialAudience,
  }) {
    final String liveTitle = initialTitle?.trim().isNotEmpty == true
        ? initialTitle!.trim()
        : ApiPayloadReader.readString(payload['title']);
    return LiveStreamModel(
      streamId: ApiPayloadReader.readString(
        payload['id'] ?? payload['streamId'],
      ),
      creatorName: ApiPayloadReader.readString(payload['host']),
      username: ApiPayloadReader.readString(payload['username']),
      avatarUrl: ApiPayloadReader.readString(payload['avatarUrl']),
      previewLabel: ApiPayloadReader.readString(payload['previewLabel']),
      liveTitle: liveTitle,
      description: ApiPayloadReader.readString(payload['description']),
      audience: initialAudience ?? _audienceFromValue(payload['audience']),
      viewerCount: ApiPayloadReader.readInt(
        payload['audienceCount'] ?? payload['viewerCount'],
      ),
      category: ApiPayloadReader.readString(payload['category']),
      location: ApiPayloadReader.readString(payload['location']),
      previewPhotoPath: initialPhotoPath,
      quickOptions: _readQuickOptions(payload['quickOptions']),
      comments: _readComments(payload['comments']),
    );
  }

  List<LiveQuickOptionModel> _readQuickOptions(Object? value) {
    final List<Map<String, dynamic>> items =
        ApiPayloadReader.readMapListFromAny(value);
    if (items.isEmpty) {
      return const <LiveQuickOptionModel>[];
    }

    return items
        .map((Map<String, dynamic> item) {
          final String id = ApiPayloadReader.readString(item['id']);
          return LiveQuickOptionModel(
            id: id,
            label: ApiPayloadReader.readString(item['label']),
            icon: _iconForQuickOption(id),
            selected: ApiPayloadReader.readBool(item['selected']) ?? false,
          );
        })
        .toList(growable: false);
  }

  List<LiveCommentModel> _readComments(Object? value) {
    return ApiPayloadReader.readMapListFromAny(value)
        .map(_mapComment)
        .where((LiveCommentModel item) => item.id.isNotEmpty)
        .toList(growable: false);
  }

  LiveCommentModel _mapComment(Map<String, dynamic> item) {
    return LiveCommentModel(
      id: ApiPayloadReader.readString(item['id']),
      username: ApiPayloadReader.readString(item['username']),
      avatarUrl: ApiPayloadReader.readString(item['avatarUrl']),
      message: ApiPayloadReader.readString(item['message']),
      verified: ApiPayloadReader.readBool(item['verified']) ?? false,
    );
  }

  Map<String, dynamic> _resolvePayload(Map<String, dynamic> response) {
    return ApiPayloadReader.readMap(response['data']) ??
        ApiPayloadReader.readMap(response['stream']) ??
        ApiPayloadReader.readMap(response['comment']) ??
        response;
  }

  LiveAudienceVisibility _audienceFromValue(Object? value) {
    switch ((value?.toString() ?? '').trim().toLowerCase()) {
      case 'friends':
        return LiveAudienceVisibility.friends;
      case 'onlyme':
      case 'only_me':
      case 'only me':
      case 'private':
        return LiveAudienceVisibility.onlyMe;
      case 'public':
      default:
        return LiveAudienceVisibility.public;
    }
  }

  String _audienceValue(LiveAudienceVisibility value) {
    switch (value) {
      case LiveAudienceVisibility.public:
        return 'public';
      case LiveAudienceVisibility.friends:
        return 'friends';
      case LiveAudienceVisibility.onlyMe:
        return 'onlyMe';
    }
  }

  IconData _iconForQuickOption(String id) {
    switch (id.toLowerCase()) {
      case 'friend':
        return Icons.group_add_outlined;
      case 'fundraiser':
        return Icons.volunteer_activism_outlined;
      case 'event':
        return Icons.event_outlined;
      case 'audio':
        return Icons.graphic_eq_rounded;
      case 'poll':
        return Icons.poll_outlined;
      case 'qa':
        return Icons.quiz_outlined;
      case 'products':
        return Icons.shopping_bag_outlined;
      case 'screen':
        return Icons.screen_share_outlined;
      case 'live':
      default:
        return Icons.videocam_rounded;
    }
  }
}
