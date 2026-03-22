class GroupModel {
  const GroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.members,
    this.isPrivate = false,
  });

  final String id;
  final String name;
  final String description;
  final int members;
  final bool isPrivate;
}
