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
  final ShareRepostSystemService shareService = ShareRepostSystemService();
  final String? backendShareLink = _resolveBackendShareLink(post);

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
              subtitle: const Text(
                'Use the backend-provided share link when available',
              ),
              onTap: () async {
                await trackShare('external_share');
                if (backendShareLink == null || backendShareLink.isEmpty) {
                  if (!context.mounted) {
                    return;
                  }
                  Navigator.of(sheetContext).pop();
                  AppGet.snackbar(
                    'Unavailable',
                    'This post does not have a backend share link yet.',
                  );
                  return;
                }
                await Clipboard.setData(ClipboardData(text: backendShareLink));
                if (!context.mounted) {
                  return;
                }
                Navigator.of(sheetContext).pop();
                AppGet.snackbar(
                  'Copied',
                  'Post link copied for external sharing',
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.link_rounded),
              title: const Text('Copy post link'),
              subtitle: Text(
                backendShareLink ?? 'Backend share link unavailable',
              ),
              onTap: () async {
                await trackShare('copy_link');
                if (backendShareLink == null || backendShareLink.isEmpty) {
                  if (!context.mounted) {
                    return;
                  }
                  Navigator.of(sheetContext).pop();
                  AppGet.snackbar(
                    'Unavailable',
                    'This post does not have a backend share link yet.',
                  );
                  return;
                }
                await Clipboard.setData(ClipboardData(text: backendShareLink));
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

String? _resolveBackendShareLink(PostModel post) {
  // The current post payload does not expose a durable share URL yet.
  // Keep the client honest until backend contracts provide one explicitly.
  if (post.id.isEmpty) {
    return null;
  }
  return null;
}
