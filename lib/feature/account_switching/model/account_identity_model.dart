import '../../../core/data/api/api_payload_reader.dart';

class AccountIdentityModel {
  const AccountIdentityModel({
    required this.id,
    required this.name,
    required this.handle,
    required this.roleLabel,
    this.isVerified = false,
  });

  final String id;
  final String name;
  final String handle;
  final String roleLabel;
  final bool isVerified;

  factory AccountIdentityModel.fromJson(Map<String, dynamic> json) {
    return AccountIdentityModel(
      id: ApiPayloadReader.readString(json['id']),
      name: ApiPayloadReader.readString(json['name']),
      handle: ApiPayloadReader.readString(json['handle']),
      roleLabel: json['roleLabel'] as String? ?? 'Personal',
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }

  factory AccountIdentityModel.fromApiJson(Map<String, dynamic> json) {
    final String username = ApiPayloadReader.readString(
      json['username'] ?? json['handle'],
    );
    final String name = ApiPayloadReader.readString(
      json['name'] ?? json['displayName'],
      fallback: username.isEmpty ? 'Account' : username,
    );

    return AccountIdentityModel(
      id: ApiPayloadReader.readString(json['id']),
      name: name,
      handle: username.startsWith('@') ? username : '@$username',
      roleLabel: ApiPayloadReader.readString(
        json['roleLabel'] ?? json['role'],
        fallback: 'Personal',
      ),
      isVerified:
          ApiPayloadReader.readBool(json['isVerified'] ?? json['verified']) ??
          false,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'handle': handle,
      'roleLabel': roleLabel,
      'isVerified': isVerified,
    };
  }
}
