class GroupModel {
  const GroupModel({required this.id, required this.name, required this.members, this.joined = false});
  final String id;
  final String name;
  final int members;
  final bool joined;
  GroupModel copyWith({bool? joined}) => GroupModel(id: id, name: name, members: members, joined: joined ?? this.joined);
}
