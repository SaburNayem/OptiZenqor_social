import '../api/api_payload_reader.dart';
import '../../helpers/media_url_resolver.dart';

class MessageModel {
  const MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.read,
    this.starred = false,
    this.replyToMessageId,
    this.deliveryState = 'delivered',
    this.kind = 'text',
    this.mediaPath,
    this.latitude,
    this.longitude,
    this.locationUrl,
    this.locationName,
  });

  final String id;
  final String chatId;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool read;
  final bool starred;
  final String? replyToMessageId;
  final String deliveryState;
  final String kind;
  final String? mediaPath;
  final double? latitude;
  final double? longitude;
  final String? locationUrl;
  final String? locationName;

  factory MessageModel.fromApiJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? lastMessage = ApiPayloadReader.readMap(
      json['lastMessage'],
    );
    final Map<String, dynamic> source = lastMessage ?? json;
    final String attachmentKind = _readAttachmentKind(source);
    final _MessageLocationPayload locationPayload = _readLocationPayload(
      source,
    );
    final String resolvedKind = ApiPayloadReader.readString(
      source['kind'] ?? source['type'],
      fallback: locationPayload.hasLocation
          ? 'location'
          : (attachmentKind.isNotEmpty ? attachmentKind : 'text'),
    );

    return MessageModel(
      id: ApiPayloadReader.readString(source['id'] ?? json['id']),
      chatId: ApiPayloadReader.readString(
        json['chatId'] ?? json['threadId'] ?? source['chatId'],
      ),
      senderId: ApiPayloadReader.readString(
        source['senderId'] ?? source['authorId'] ?? json['senderId'],
      ),
      text: ApiPayloadReader.readString(
        source['text'] ?? source['message'] ?? source['body'],
      ),
      timestamp:
          ApiPayloadReader.readDateTime(
            source['timestamp'] ?? source['createdAt'] ?? source['sentAt'],
          ) ??
          DateTime.now(),
      read:
          ApiPayloadReader.readBool(source['read'] ?? source['isRead']) ??
          false,
      starred:
          ApiPayloadReader.readBool(source['starred'] ?? source['isStarred']) ??
          false,
      replyToMessageId: ApiPayloadReader.readString(
        source['replyToMessageId'] ?? source['replyTo'],
      ),
      deliveryState: ApiPayloadReader.readString(
        source['deliveryState'] ?? source['status'],
        fallback: 'delivered',
      ),
      kind: resolvedKind,
      mediaPath: MediaUrlResolver.resolve(_readPrimaryAttachmentUrl(source)),
      latitude: locationPayload.latitude,
      longitude: locationPayload.longitude,
      locationUrl: locationPayload.locationUrl,
      locationName: locationPayload.locationName,
    );
  }

  MessageModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? text,
    DateTime? timestamp,
    bool? read,
    bool? starred,
    String? replyToMessageId,
    String? deliveryState,
    String? kind,
    String? mediaPath,
    double? latitude,
    double? longitude,
    String? locationUrl,
    String? locationName,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      read: read ?? this.read,
      starred: starred ?? this.starred,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      deliveryState: deliveryState ?? this.deliveryState,
      kind: kind ?? this.kind,
      mediaPath: mediaPath ?? this.mediaPath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationUrl: locationUrl ?? this.locationUrl,
      locationName: locationName ?? this.locationName,
    );
  }

  static _MessageLocationPayload _readLocationPayload(
    Map<String, dynamic> source,
  ) {
    final Map<String, dynamic>? locationMap =
        ApiPayloadReader.readMap(source['location']) ??
        ApiPayloadReader.readMap(source['geo']) ??
        ApiPayloadReader.readMap(source['geoLocation']) ??
        ApiPayloadReader.readMap(source['coordinates']);
    final Map<String, dynamic>? metadataMap =
        ApiPayloadReader.readMap(source['metadata']) ??
        ApiPayloadReader.readMap(source['meta']);

    final _MessageLatLng? coordinates = _readLocationCoordinates(
      source,
      locationMap,
      metadataMap,
    );
    final String locationUrl = ApiPayloadReader.readString(
      _firstPresent(<Object?>[
        source['locationUrl'],
        source['mapUrl'],
        source['mapsUrl'],
        source['googleMapsUrl'],
        locationMap?['locationUrl'],
        locationMap?['mapUrl'],
        locationMap?['mapsUrl'],
        locationMap?['url'],
        metadataMap?['locationUrl'],
        metadataMap?['mapUrl'],
        metadataMap?['mapsUrl'],
      ]),
    );
    final String locationName = ApiPayloadReader.readString(
      _firstPresent(<Object?>[
        source['locationName'],
        source['locationLabel'],
        source['address'],
        if (source['location'] is String) source['location'],
        locationMap?['name'],
        locationMap?['label'],
        locationMap?['address'],
        metadataMap?['locationName'],
        metadataMap?['locationLabel'],
      ]),
    );

    return _MessageLocationPayload(
      latitude: coordinates?.latitude,
      longitude: coordinates?.longitude,
      locationUrl: locationUrl.isEmpty ? null : locationUrl,
      locationName: locationName.isEmpty ? null : locationName,
    );
  }

  static _MessageLatLng? _readLocationCoordinates(
    Map<String, dynamic> source,
    Map<String, dynamic>? locationMap,
    Map<String, dynamic>? metadataMap,
  ) {
    for (final Map<String, dynamic>? item in <Map<String, dynamic>?>[
      source,
      locationMap,
      metadataMap,
    ]) {
      if (item == null) {
        continue;
      }
      final _MessageLatLng? explicit = _readExplicitLatLng(item);
      if (explicit != null) {
        return explicit;
      }
      final _MessageLatLng? coordinates = _readCoordinateList(
        _firstPresent(<Object?>[
          item['coordinates'],
          item['coords'],
          item['geoCoordinates'],
          item['position'],
        ]),
      );
      if (coordinates != null) {
        return coordinates;
      }
      final _MessageLatLng? textCoordinates = _extractLatLng(
        ApiPayloadReader.readString(
          _firstPresent(<Object?>[
            item['locationText'],
            item['location'],
            item['address'],
            item['text'],
            item['message'],
            item['body'],
          ]),
        ),
      );
      if (textCoordinates != null) {
        return textCoordinates;
      }
    }
    return null;
  }

  static _MessageLatLng? _readExplicitLatLng(Map<String, dynamic> source) {
    final double? latitude = _readOptionalDouble(
      _firstPresent(<Object?>[
        source['latitude'],
        source['lat'],
        source['locationLatitude'],
      ]),
    );
    final double? longitude = _readOptionalDouble(
      _firstPresent(<Object?>[
        source['longitude'],
        source['lng'],
        source['lon'],
        source['long'],
        source['locationLongitude'],
      ]),
    );
    return _validLatLng(latitude, longitude);
  }

  static _MessageLatLng? _readCoordinateList(Object? value) {
    if (value is! List || value.length < 2) {
      return null;
    }
    final double? first = _readOptionalDouble(value[0]);
    final double? second = _readOptionalDouble(value[1]);
    if (first == null || second == null) {
      return null;
    }
    if (first.abs() > 90 && second.abs() <= 90) {
      return _validLatLng(second, first);
    }
    return _validLatLng(second, first) ?? _validLatLng(first, second);
  }

  static _MessageLatLng? _extractLatLng(String value) {
    final RegExpMatch? match = RegExp(
      r'(-?\d+(?:\.\d+)?)\s*,\s*(-?\d+(?:\.\d+)?)',
    ).firstMatch(value);
    if (match == null) {
      return null;
    }
    return _validLatLng(
      double.tryParse(match.group(1) ?? ''),
      double.tryParse(match.group(2) ?? ''),
    );
  }

  static _MessageLatLng? _validLatLng(double? latitude, double? longitude) {
    if (latitude == null ||
        longitude == null ||
        latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      return null;
    }
    return _MessageLatLng(latitude, longitude);
  }

  static double? _readOptionalDouble(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    final String normalized = value.toString().trim();
    if (normalized.isEmpty) {
      return null;
    }
    return double.tryParse(normalized);
  }

  static Object? _firstPresent(List<Object?> values) {
    for (final Object? value in values) {
      if (value == null) {
        continue;
      }
      if (value is String && value.trim().isEmpty) {
        continue;
      }
      return value;
    }
    return null;
  }

  static String _readPrimaryAttachmentUrl(Map<String, dynamic> source) {
    final String directUrl = ApiPayloadReader.readString(
      source['mediaPath'] ??
          source['mediaUrl'] ??
          source['attachmentUrl'] ??
          source['imageUrl'] ??
          source['audioUrl'] ??
          source['videoUrl'] ??
          source['fileUrl'],
    );
    if (directUrl.isNotEmpty) {
      return directUrl;
    }

    final List<Map<String, dynamic>> attachmentItems =
        ApiPayloadReader.readMapListFromAny(
          source['attachmentItems'] ?? source['attachments'],
        );
    for (final Map<String, dynamic> item in attachmentItems) {
      final String nestedUrl = ApiPayloadReader.readString(
        item['mediaPath'] ??
            item['mediaUrl'] ??
            item['attachmentUrl'] ??
            item['imageUrl'] ??
            item['audioUrl'] ??
            item['videoUrl'] ??
            item['fileUrl'] ??
            item['url'] ??
            item['path'] ??
            item['secureUrl'] ??
            item['secure_url'],
      );
      if (nestedUrl.isNotEmpty) {
        return nestedUrl;
      }
    }

    final List<String> attachmentUrls = ApiPayloadReader.readStringList(
      source['attachments'],
    );
    return attachmentUrls.isEmpty ? '' : attachmentUrls.first;
  }

  static String _readAttachmentKind(Map<String, dynamic> source) {
    final List<Map<String, dynamic>> attachmentItems =
        ApiPayloadReader.readMapListFromAny(
          source['attachmentItems'] ?? source['attachments'],
        );
    for (final Map<String, dynamic> item in attachmentItems) {
      final String explicitKind = _normalizeAttachmentKind(
        ApiPayloadReader.readString(
          item['kind'] ??
              item['type'] ??
              item['resourceType'] ??
              item['resource_type'],
        ),
      );
      if (explicitKind.isNotEmpty) {
        return explicitKind;
      }
      final String mimeType = ApiPayloadReader.readString(
        item['mimeType'] ?? item['mime_type'] ?? item['contentType'],
      ).toLowerCase();
      if (mimeType.startsWith('image/')) {
        return 'image';
      }
      if (mimeType.startsWith('audio/')) {
        return 'audio';
      }
      if (mimeType.startsWith('video/')) {
        return 'video';
      }
      if (mimeType.isNotEmpty) {
        return 'file';
      }
    }
    return '';
  }

  static String _normalizeAttachmentKind(String kind) {
    switch (kind.trim().toLowerCase()) {
      case 'gallery':
      case 'camera':
      case 'photo':
      case 'image':
        return 'image';
      case 'voice':
      case 'audio':
        return 'audio';
      case 'video':
        return 'video';
      case 'document':
      case 'file':
      case 'raw':
        return 'file';
      default:
        return '';
    }
  }
}

class _MessageLocationPayload {
  const _MessageLocationPayload({
    this.latitude,
    this.longitude,
    this.locationUrl,
    this.locationName,
  });

  final double? latitude;
  final double? longitude;
  final String? locationUrl;
  final String? locationName;

  bool get hasLocation =>
      (latitude != null && longitude != null) ||
      (locationUrl ?? '').trim().isNotEmpty ||
      (locationName ?? '').trim().isNotEmpty;
}

class _MessageLatLng {
  const _MessageLatLng(this.latitude, this.longitude);

  final double latitude;
  final double longitude;
}
