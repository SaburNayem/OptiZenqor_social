class ProfileUpdateModel {
  const ProfileUpdateModel({
    required this.name,
    required this.username,
    required this.bio,
    this.website,
    this.location,
    this.avatarUrl,
    this.coverImageUrl,
  });

  final String name;
  final String username;
  final String bio;
  final String? website;
  final String? location;
  final String? avatarUrl;
  final String? coverImageUrl;

  Map<String, dynamic> toPayload() {
    return <String, dynamic>{
      'name': name.trim(),
      'username': username.trim(),
      'bio': bio.trim(),
      if (website != null && website!.trim().isNotEmpty)
        'website': website!.trim(),
      if (location != null && location!.trim().isNotEmpty)
        'location': location!.trim(),
      if (avatarUrl != null && avatarUrl!.trim().isNotEmpty)
        'avatarUrl': avatarUrl!.trim(),
      if (coverImageUrl != null && coverImageUrl!.trim().isNotEmpty)
        'coverImageUrl': coverImageUrl!.trim(),
    };
  }
}
