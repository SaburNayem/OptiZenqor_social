class OfflineActionModel {
  const OfflineActionModel({
    required this.id,
    required this.type,
    required this.payload,
    this.retries = 0,
  });

  final String id;
  final String type;
  final Map<String, dynamic> payload;
  final int retries;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'payload': payload,
      'retries': retries,
    };
  }

  factory OfflineActionModel.fromJson(Map<String, dynamic> json) {
    return OfflineActionModel(
      id: json['id'] as String,
      type: json['type'] as String,
      payload: Map<String, dynamic>.from(json['payload'] as Map),
      retries: (json['retries'] as int?) ?? 0,
    );
  }
}
