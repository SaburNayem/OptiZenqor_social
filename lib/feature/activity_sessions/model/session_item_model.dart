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
      id: json['id'] as String,
      device: json['device'] as String,
      location: json['location'] as String,
      platform: json['platform'] as String? ?? 'Unknown',
      lastActive: json['lastActive'] as String? ?? 'Unknown',
      active: json['active'] as bool? ?? false,
      isCurrent: json['isCurrent'] as bool? ?? false,
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
