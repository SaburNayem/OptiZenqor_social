import 'package:flutter/material.dart';

class CreatePostResult {
  const CreatePostResult({
    required this.caption,
    this.mediaUrl,
    this.isVideo = false,
  });

  final String caption;
  final String? mediaUrl;
  final bool isVideo;
}

class CreatePostScreen extends StatelessWidget {
  CreatePostScreen({super.key});

  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _mediaController = TextEditingController();
  final ValueNotifier<bool> _isVideo = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          TextButton(
            onPressed: () => _submit(context),
            child: const Text('Post'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _captionController,
            minLines: 5,
            maxLines: 8,
            decoration: const InputDecoration(
              hintText: 'What do you want to share?',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          ValueListenableBuilder<bool>(
            valueListenable: _isVideo,
            builder: (context, isVideo, _) {
              return Column(
                children: [
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Photo'),
                        selected: !isVideo,
                        onSelected: (_) {
                          _isVideo.value = false;
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Video'),
                        selected: isVideo,
                        onSelected: (_) {
                          _isVideo.value = true;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _mediaController,
                    decoration: InputDecoration(
                      labelText: isVideo ? 'Video URL (optional)' : 'Photo URL (optional)',
                      hintText: isVideo
                          ? 'https://example.com/video.mp4'
                          : 'https://example.com/photo.jpg',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => _submit(context),
            icon: const Icon(Icons.send_rounded),
            label: const Text('Post Now'),
          ),
        ],
      ),
    );
  }

  void _submit(BuildContext context) {
    final caption = _captionController.text.trim();
    if (caption.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Please write something first')));
      return;
    }
    Navigator.of(context).pop(
      CreatePostResult(
        caption: caption,
        mediaUrl: _mediaController.text.trim().isEmpty ? null : _mediaController.text.trim(),
        isVideo: _isVideo.value,
      ),
    );
  }
}
