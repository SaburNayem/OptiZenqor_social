import '../model/group_chat_model.dart';

class GroupChatRepository {
  final List<GroupChatModel> _groups = <GroupChatModel>[
    const GroupChatModel(
      id: 'gc1',
      name: 'Core Product Team',
      members: <String>['mayaquinn', 'rafiahmed'],
      roles: <String, String>{
        'mayaquinn': 'admin',
        'rafiahmed': 'member',
      },
      media: <String>['spec_v1.pdf'],
    ),
  ];

  List<GroupChatModel> all() => List<GroupChatModel>.from(_groups);

  void create(String name, String creator) {
    _groups.insert(
      0,
      GroupChatModel(
        id: 'gc_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        members: <String>[creator],
        roles: <String, String>{creator: 'admin'},
      ),
    );
  }

  void addMember(String groupId, String username) {
    final index = _groups.indexWhere((group) => group.id == groupId);
    if (index == -1) {
      return;
    }
    final group = _groups[index];
    if (group.members.contains(username)) {
      return;
    }
    _groups[index] = GroupChatModel(
      id: group.id,
      name: group.name,
      members: <String>[...group.members, username],
      roles: <String, String>{...group.roles, username: 'member'},
      media: group.media,
    );
  }

  void removeMember(String groupId, String username) {
    final index = _groups.indexWhere((group) => group.id == groupId);
    if (index == -1) {
      return;
    }
    final group = _groups[index];
    _groups[index] = GroupChatModel(
      id: group.id,
      name: group.name,
      members: group.members.where((member) => member != username).toList(),
      roles: Map<String, String>.from(group.roles)..remove(username),
      media: group.media,
    );
  }
}
