import 'package:flutter/material.dart';

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
        builder: (_, _) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if ((_controller.errorMessage ?? '').isNotEmpty) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(_controller.errorMessage!),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _groupController,
                      decoration: const InputDecoration(
                        hintText: 'New group name',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await _controller.createGroup(_groupController.text);
                      _groupController.clear();
                    },
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ..._controller.groups.map(
                (group) => Card(
                  child: ListTile(
                    title: Text(group.name),
                    subtitle: Text(
                      'Members: ${group.members.join(', ')}\n'
                      'Media: ${group.media.join(', ')}',
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'add') {
                          await _controller.addMember(
                            group.id,
                            'member${group.members.length + 1}',
                          );
                        } else if (value == 'rename') {
                          await _controller.renameGroup(
                            group.id,
                            '${group.name} Updated',
                          );
                        } else if (value == 'delete') {
                          await _controller.deleteGroup(group.id);
                        } else if (value == 'role' &&
                            group.members.isNotEmpty) {
                          await _controller.updateMemberRole(
                            group.id,
                            group.members.first,
                            'moderator',
                          );
                        } else if (group.members.isNotEmpty) {
                          await _controller.removeMember(
                            group.id,
                            group.members.last,
                          );
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'add', child: Text('Add member')),
                        PopupMenuItem(value: 'rename', child: Text('Rename')),
                        PopupMenuItem(
                          value: 'role',
                          child: Text('Make first member moderator'),
                        ),
                        PopupMenuItem(
                          value: 'remove',
                          child: Text('Remove member'),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete group'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
