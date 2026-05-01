import 'package:flutter/material.dart';

enum CreatePostMediaSheetAction { chooseMedia, chooseVideo, capturePhoto }

class CreatePostSheetHelper {
  CreatePostSheetHelper._();

  static const List<String> feelingOptions = <String>[
    'Happy',
    'Excited',
    'Traveling',
    'Working',
    'Blessed',
  ];

  static const List<String> privacyOptions = <String>[
    'Everyone',
    'Followers',
    'Close Friends',
  ];

  static Future<CreatePostMediaSheetAction?> showMediaPickerSheet(
    BuildContext context,
  ) {
    return showModalBottomSheet<CreatePostMediaSheetAction>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose photo / video'),
                onTap: () => Navigator.of(
                  context,
                ).pop(CreatePostMediaSheetAction.chooseMedia),
              ),
              ListTile(
                leading: const Icon(Icons.videocam_outlined),
                title: const Text('Choose single video'),
                onTap: () => Navigator.of(
                  context,
                ).pop(CreatePostMediaSheetAction.chooseVideo),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Take photo'),
                onTap: () => Navigator.of(
                  context,
                ).pop(CreatePostMediaSheetAction.capturePhoto),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<String?> showSimpleOptionSheet({
    required BuildContext context,
    required String title,
    required List<String> options,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...options.map(
                (option) => ListTile(
                  title: Text(option),
                  onTap: () => Navigator.of(context).pop(option),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<String?> showTextInputDialog({
    required BuildContext context,
    required String title,
    required String hintText,
    String initialValue = '',
    int maxLines = 1,
  }) async {
    final TextEditingController controller = TextEditingController(
      text: initialValue,
    );
    final String? result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(hintText: hintText),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    return result;
  }

  static bool isVideoPath(String path) {
    final String lower = path.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.m4v') ||
        lower.endsWith('.webm');
  }
}
