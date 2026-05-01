import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/data/models/post_model.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/navigation/app_get.dart';
import '../screen/share_post_screen.dart';
import '../service/share_repost_system_service.dart';

Future<void> showSharePostActionSheet({
  required BuildContext context,
  required PostModel post,
  required UserModel author,
}) {
  final String postLink = 'https://optizenqor.app/post/${post.id}';
  final ShareRepostSystemService shareService = ShareRepostSystemService();

  Future<void> trackShare(String option) async {
    try {
      await shareService.postEndpoint(
        'track',
        payload: <String, dynamic>{'targetId': post.id, 'option': option},
      );
    } catch (_) {}
  }

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.post_add_rounded),
              title: const Text('Share as post'),
              subtitle: const Text('Open the share composer'),
              onTap: () async {
                await trackShare('share_as_post');
                if (!context.mounted) {
                  return;
                }
                Navigator.of(sheetContext).pop();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => SharePostScreen(post: post, author: author),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.send_outlined),
              title: const Text('Share externally'),
              subtitle: const Text('Open static external share options'),
              onTap: () async {
                await trackShare('external_share');
                if (!context.mounted) {
                  return;
                }
                Navigator.of(sheetContext).pop();
                AppGet.snackbar('Share post', 'Static external share opened');
              },
            ),
            ListTile(
              leading: const Icon(Icons.link_rounded),
              title: const Text('Copy post link'),
              subtitle: Text(postLink),
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: postLink));
                await trackShare('copy_link');
                if (!context.mounted) {
                  return;
                }
                Navigator.of(sheetContext).pop();
                AppGet.snackbar('Copied', 'Post link copied');
              },
            ),
          ],
        ),
      );
    },
  );
}
