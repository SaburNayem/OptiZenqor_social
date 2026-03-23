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
      id: json['id'] as String,
      name: json['name'] as String,
      handle: json['handle'] as String,
      roleLabel: json['roleLabel'] as String? ?? 'Personal',
      isVerified: json['isVerified'] as bool? ?? false,
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
