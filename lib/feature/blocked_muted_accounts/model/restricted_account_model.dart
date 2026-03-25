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
      id: json['id'] as String,
      name: json['name'] as String,
      handle: json['handle'] as String,
      status: json['status'] as String,
      avatarUrl: json['avatarUrl'] as String?,
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
