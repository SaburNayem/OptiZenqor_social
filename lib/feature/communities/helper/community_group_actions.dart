import 'package:flutter/material.dart';

import '../widget/community_group_common_widgets.dart';

class CommunityGroupActions {
  static Future<void> showCreatePostSheet(BuildContext context) async {
    final controller = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Create post',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Share something with the group',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showSnack(context, 'Post created locally');
                  },
                  child: const Text('Post'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> showInviteOptions(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return const SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.link_rounded),
                title: Text('Invite via link'),
              ),
              ListTile(
                leading: Icon(Icons.qr_code_rounded),
                title: Text('QR invite'),
              ),
              ListTile(
                leading: Icon(Icons.person_add_alt_1_rounded),
                title: Text('Invite members'),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> showGroupChatRoom(BuildContext context) async {
    final inputController = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Group chat room',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              const CommunityChatBubble(
                sender: 'Sadia',
                message: 'Welcome everyone to the room.',
              ),
              const CommunityChatBubble(
                sender: 'Riyad',
                message: 'Sharing the event deck soon.',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: inputController,
                      decoration: const InputDecoration(
                        hintText: 'Message the room',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: () =>
                        _showSnack(context, 'Message sent locally'),
                    child: const Text('Send'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> showSearchInsideGroup(BuildContext context) async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search inside group'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Search posts, events, hashtags',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showSnack(context, 'Search: ${controller.text.trim()}');
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> showMoreMenu(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return const SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.push_pin_outlined),
                title: Text('Pinned posts'),
              ),
              ListTile(
                leading: Icon(Icons.schedule_outlined),
                title: Text('Scheduled posts'),
              ),
              ListTile(
                leading: Icon(Icons.drafts_outlined),
                title: Text('Draft posts'),
              ),
              ListTile(
                leading: Icon(Icons.tag_rounded),
                title: Text('Hashtags inside group'),
              ),
              ListTile(
                leading: Icon(Icons.fact_check_outlined),
                title: Text('Member requests approval'),
              ),
              ListTile(
                leading: Icon(Icons.manage_history_outlined),
                title: Text('Activity log'),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> showMediaViewer(
    BuildContext context, {
    required String label,
    required bool isVideo,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(18),
            height: 320,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isVideo ? Icons.videocam_rounded : Icons.photo_rounded,
                  size: 58,
                ),
                const SizedBox(height: 14),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isVideo
                      ? 'Full video viewer preview'
                      : 'Full photo viewer preview',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

void _showSnack(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}

