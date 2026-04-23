import '../../../core/data/api/api_payload_reader.dart';

class RestrictedAccountModel {
  const RestrictedAccountModel({
    required this.id,
    required this.name,
    required this.handle,
    required this.status,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String handle;
  final String status;
  final String? avatarUrl;

  factory RestrictedAccountModel.fromJson(Map<String, dynamic> json) {
    return RestrictedAccountModel(
      id: ApiPayloadReader.readString(json['id']),
      name: ApiPayloadReader.readString(json['name']),
      handle: ApiPayloadReader.readString(json['handle']),
      status: ApiPayloadReader.readString(json['status']),
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  factory RestrictedAccountModel.fromApiJson(
    Map<String, dynamic> json, {
    required String status,
  }) {
    final String username = ApiPayloadReader.readString(
      json['username'] ?? json['handle'],
    );
    return RestrictedAccountModel(
      id: ApiPayloadReader.readString(json['id']),
      name: ApiPayloadReader.readString(
        json['name'] ?? json['displayName'],
        fallback: username.isEmpty ? 'Unknown account' : username,
      ),
      handle: username.startsWith('@') ? username : '@$username',
      status: status,
      avatarUrl: ApiPayloadReader.readString(
        json['avatarUrl'] ?? json['avatar'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'handle': handle,
      'status': status,
      'avatarUrl': avatarUrl,
    };
  }
}
