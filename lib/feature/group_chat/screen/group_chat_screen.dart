import 'package:flutter/material.dart';

import '../controller/group_chat_controller.dart';

class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({super.key});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final GroupChatController _controller = GroupChatController();
  final TextEditingController _groupController = TextEditingController();
  final TextEditingController _dialogController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  @override
  void dispose() {
    _groupController.dispose();
    _dialogController.dispose();
    _controller.dispose();
    super.dispose();
  }

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
            children: <Widget>[
              if ((_controller.errorMessage ?? '').isNotEmpty) ...<Widget>[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(_controller.errorMessage!),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: <Widget>[
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
                      '${group.summary.isEmpty ? 'No summary yet' : group.summary}\n'
                      'Unread: ${group.unreadCount}',
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (String value) async {
                        if (value == 'add') {
                          final String username = await _prompt(
                            context,
                            title: 'Add member',
                            hint: 'Username or user id',
                          );
                          if (username.isEmpty) {
                            return;
                          }
                          await _controller.addMember(group.id, username);
                          return;
                        }
                        if (value == 'rename') {
                          final String nextName = await _prompt(
                            context,
                            title: 'Rename group',
                            hint: 'Group name',
                            initialValue: group.name,
                          );
                          if (nextName.isEmpty) {
                            return;
                          }
                          await _controller.renameGroup(group.id, nextName);
                          return;
                        }
                        if (value == 'delete') {
                          await _controller.deleteGroup(group.id);
                          return;
                        }
                        if (value == 'role') {
                          final String username = await _prompt(
                            context,
                            title: 'Promote member',
                            hint: 'Username',
                            initialValue: group.members.isEmpty
                                ? ''
                                : group.members.first,
                          );
                          if (username.isEmpty) {
                            return;
                          }
                          await _controller.updateMemberRole(
                            group.id,
                            username,
                            'moderator',
                          );
                          return;
                        }
                        final String username = await _prompt(
                          context,
                          title: 'Remove member',
                          hint: 'Username',
                          initialValue: group.members.isEmpty
                              ? ''
                              : group.members.last,
                        );
                        if (username.isEmpty) {
                          return;
                        }
                        await _controller.removeMember(group.id, username);
                      },
                      itemBuilder: (_) => const <PopupMenuEntry<String>>[
                        PopupMenuItem(value: 'add', child: Text('Add member')),
                        PopupMenuItem(value: 'rename', child: Text('Rename')),
                        PopupMenuItem(
                          value: 'role',
                          child: Text('Make member moderator'),
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

  Future<String> _prompt(
    BuildContext context, {
    required String title,
    required String hint,
    String initialValue = '',
  }) async {
    _dialogController.text = initialValue;
    final String? value = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: _dialogController,
            decoration: InputDecoration(hintText: hint),
            autofocus: true,
            onSubmitted: (_) {
              Navigator.of(dialogContext).pop(_dialogController.text.trim());
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(
                dialogContext,
              ).pop(_dialogController.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    return (value ?? '').trim();
  }
}
