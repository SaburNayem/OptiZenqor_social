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
    final ServiceResponseModel<Map<String, dynamic>> response =
        await _service.getEndpoint('live_stream_setup');
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to load live stream setup.');
    }

    final Map<String, dynamic> payload =
        ApiPayloadReader.readMap(response.data['data']) ??
        ApiPayloadReader.readMap(response.data['result']) ??
        response.data;
    final String liveTitle = initialTitle?.trim().isNotEmpty == true
        ? initialTitle!.trim()
        : ApiPayloadReader.readString(payload['title'], fallback: 'Go live');

    return LiveStreamModel(
      creatorName: ApiPayloadReader.readString(payload['host'], fallback: 'Live host'),
      username: ApiPayloadReader.readString(payload['username'], fallback: '@live'),
      avatarUrl: ApiPayloadReader.readString(payload['avatarUrl']),
      previewLabel: 'Describe what your live video is about',
      liveTitle: liveTitle,
      description: ApiPayloadReader.readString(payload['description']),
      audience: initialAudience ?? LiveAudienceVisibility.public,
      viewerCount: ApiPayloadReader.readInt(payload['audienceCount']),
      category: ApiPayloadReader.readString(payload['category'], fallback: 'Live'),
      location: ApiPayloadReader.readString(payload['location']),
      previewPhotoPath: initialPhotoPath,
      quickOptions: _readQuickOptions(payload['quickOptions']),
      comments: _readComments(payload['comments']),
    );
  }

  List<LiveQuickOptionModel> _readQuickOptions(Object? value) {
    final List<Map<String, dynamic>> items = ApiPayloadReader.readMapListFromAny(
      value,
    );
    if (items.isEmpty) {
      return const <LiveQuickOptionModel>[
        LiveQuickOptionModel(
          id: 'live',
          label: 'Live video',
          icon: Icons.videocam_rounded,
          selected: true,
        ),
      ];
    }

    return items.map((Map<String, dynamic> item) {
      final String id = ApiPayloadReader.readString(item['id']);
      return LiveQuickOptionModel(
        id: id,
        label: ApiPayloadReader.readString(item['label'], fallback: id),
        icon: _iconForQuickOption(id),
        selected: ApiPayloadReader.readBool(item['selected']) ?? false,
      );
    }).toList(growable: false);
  }

  List<LiveCommentModel> _readComments(Object? value) {
    return ApiPayloadReader.readMapListFromAny(value)
        .map(
          (Map<String, dynamic> item) => LiveCommentModel(
            id: ApiPayloadReader.readString(item['id']),
            username: ApiPayloadReader.readString(
              item['username'],
              fallback: 'viewer',
            ),
            avatarUrl: ApiPayloadReader.readString(item['avatarUrl']),
            message: ApiPayloadReader.readString(item['message']),
            verified: ApiPayloadReader.readBool(item['verified']) ?? false,
          ),
        )
        .where((LiveCommentModel item) => item.id.isNotEmpty)
        .toList(growable: false);
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
