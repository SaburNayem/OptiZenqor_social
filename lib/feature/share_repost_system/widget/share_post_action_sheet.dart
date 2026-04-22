import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/data/models/post_model.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/navigation/app_get.dart';
import '../screen/share_post_screen.dart';

Future<void> showSharePostActionSheet({
  required BuildContext context,
  required PostModel post,
  required UserModel author,
}) {
  final String postLink = 'https://optizenqor.app/post/${post.id}';

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
              onTap: () {
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
              onTap: () {
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
