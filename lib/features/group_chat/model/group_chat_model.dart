class GroupChatModel {
  const GroupChatModel({
    required this.id,
    required this.name,
    required this.members,
    required this.roles,
    this.media = const <String>[],
  });

  final String id;
  final String name;
  final List<String> members;
  final Map<String, String> roles;
  final List<String> media;
}
