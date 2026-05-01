import '../../../core/data/api/api_payload_reader.dart';

class SessionItemModel {
  const SessionItemModel({
    required this.id,
    required this.device,
    required this.location,
    required this.platform,
    required this.lastActive,
    required this.active,
    this.isCurrent = false,
  });

  final String id;
  final String device;
  final String location;
  final String platform;
  final String lastActive;
  final bool active;
  final bool isCurrent;

  SessionItemModel copyWith({
    String? id,
    String? device,
    String? location,
    String? platform,
    String? lastActive,
    bool? active,
    bool? isCurrent,
  }) {
    return SessionItemModel(
      id: id ?? this.id,
      device: device ?? this.device,
      location: location ?? this.location,
      platform: platform ?? this.platform,
      lastActive: lastActive ?? this.lastActive,
      active: active ?? this.active,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }

  factory SessionItemModel.fromJson(Map<String, dynamic> json) {
    return SessionItemModel(
      id: ApiPayloadReader.readString(json['id']),
      device: ApiPayloadReader.readString(json['device']),
      location: ApiPayloadReader.readString(json['location']),
      platform: ApiPayloadReader.readString(
        json['platform'],
        fallback: 'Unknown',
      ),
      lastActive: ApiPayloadReader.readString(
        json['lastActive'],
        fallback: 'Unknown',
      ),
      active: ApiPayloadReader.readBool(json['active']) ?? false,
      isCurrent: ApiPayloadReader.readBool(json['isCurrent']) ?? false,
    );
  }

  factory SessionItemModel.fromApiJson(Map<String, dynamic> json) {
    final DateTime? lastActiveAt = ApiPayloadReader.readDateTime(
      json['lastActiveAt'] ?? json['updatedAt'] ?? json['createdAt'],
    );

    return SessionItemModel(
      id: ApiPayloadReader.readString(json['id']),
      device: ApiPayloadReader.readString(
        json['device'] ?? json['deviceName'],
        fallback: 'Unknown device',
      ),
      location: ApiPayloadReader.readString(
        json['location'] ?? json['ipLocation'],
        fallback: 'Unknown location',
      ),
      platform: ApiPayloadReader.readString(
        json['platform'] ?? json['client'],
        fallback: 'Unknown',
      ),
      lastActive:
          lastActiveAt?.toLocal().toString() ??
          ApiPayloadReader.readString(
            json['lastActive'] ?? json['lastSeen'],
            fallback: 'Unknown',
          ),
      active:
          ApiPayloadReader.readBool(json['active'] ?? json['isActive']) ??
          false,
      isCurrent:
          ApiPayloadReader.readBool(
            json['isCurrent'] ?? json['currentSession'],
          ) ??
          false,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'device': device,
      'location': location,
      'platform': platform,
      'lastActive': lastActive,
      'active': active,
      'isCurrent': isCurrent,
    };
  }
}
