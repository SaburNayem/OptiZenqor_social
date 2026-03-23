import 'package:flutter/foundation.dart';

import '../model/group_chat_model.dart';
import '../repository/group_chat_repository.dart';

class GroupChatController extends ChangeNotifier {
  GroupChatController({GroupC  GroupChatController({GroupC  GroupChatController({GroupC  GroupChatController({GroupC  GroupChatController({GroupC  GroupChatController({GroupC  GroupChatController({GroupC  GroupChatController({GroupC  GroupChatController({GroupC  GroupChatController({GroupC  GroupChatController({GroupC  GroupChatController({GroupC  GroupChatController({GroupC  GroupChatController({GroupC  GroupChatController({GroupC  GroupChatController({GroupC  GroupChatController({GroupC  GroupChatController({GroupC  GroupChatController({GroupC  GroupChatController({GroupC  GroupChatController({GroupC  GroupChatController({GroupC  GroupChatController({GroupC  GroupChatController({GroupC  GroupChatController({GroupC  GroupChatController({GroupC  Groutter/material.dart';

import '../controller/group_chat_controller.dart';

class GroupChatScreen extends StatelessWidget {
  GroupChatScreen({super.key}) {
    _controller.load();
  }

  final GroupChatController _controller = GroupChatController();
  final TextEditingController _groupController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Group Chat')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _groupController,
                      decoration: const InputDecoration(hintText: 'New group name'),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _controller.createGroup(_groupController.text);
                      _groupController.clear();
                    },
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ..._controller.groups.map((group) {
                return Card(
                  child: ListTile(
                    title: Text(group.name),
                    subtitle: Text(
                      'Members: ${group.members.join(', ')}\nMedia: ${group.media.join(', ')}',
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'add') {
                          _controller.addMember(group.id, 'member${group.members.length + 1}');
                        } else {
                          _controller.removeMember(group.id, group.members.last);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'add', child: Text('Add member')),
                        PopupMenuItem(value: 'remove', child: Text('Remove member')),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
