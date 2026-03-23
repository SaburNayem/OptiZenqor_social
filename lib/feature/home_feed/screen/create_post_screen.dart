import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/services/media_picker_service.dart';
import '../../../core/services/upload_service.dart';
import '../../../core/widgets/inline_video_player.dart';

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

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _mediaController = TextEditingController();
  final ValueNotifier<bool> _isVideo = ValueNotifier<bool>(false);
  final MediaPickerService _pickerService = MediaPickerService();
  final UploadService _uploadService = UploadService();

  StreamSubscription<UploadProgress>? _uploadSubscription;
  String? _pickedPath;
  String? _uploadedRemotePath;
  double _uploadProgress = 0;
  UploadStatus? _uploadStatus;
  String? _uploadTaskId;

  @override
  void dispose() {
    _uploadSubscription?.cancel();
    _captionController.dispose();
    _mediaController.dispose();
    _isVideo.dispose();
    super.dispose();
  }

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
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _pickMedia,
                        icon: const Icon(Icons.photo_library_outlined),
                        label: Text(isVideo ? 'Pick video' : 'Pick image'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _pickedPath == null ? null : _startUpload,
                        icon: const Icon(Icons.cloud_upload_outlined),
                        label: const Text('Upload'),
                      ),
                      OutlinedButton.icon(
                        onPressed: (_uploadStatus == UploadStatus.uploading && _uploadTaskId != null)
                            ? _cancelUpload
                            : null,
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text('Cancel upload'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _uploadStatus == UploadStatus.failed ? _retryUpload : null,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry upload'),
                      ),
                      FilterChip(
                        label: const Text('Background upload placeholder'),
                        selected: _uploadStatus == UploadStatus.background,
                        onSelected: (_) {
                          setState(() {
                            _uploadStatus = UploadStatus.background;
                          });
                        },
                      ),
                    ],
                  ),
                  if (_pickedPath != null) ...[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: isVideo
                          ? SizedBox(
                              height: 220,
                              child: InlineVideoPlayer(filePath: _pickedPath),
                            )
                          : Image.file(
                              File(_pickedPath!),
                              height: 220,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ],
                  if (_uploadStatus != null) ...[
                    const SizedBox(height: 10),
                    LinearProgressIndicator(value: _uploadProgress.clamp(0, 1)),
                    const SizedBox(height: 6),
                    Text('Upload status: ${_uploadStatus!.name}'),
                  ],
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

  Future<void> _pickMedia() async {
    final isVideo = _isVideo.value;
    final picked = isVideo
        ? await _pickerService.pickVideo()
        : await _pickerService.pickImage();
    if (!mounted) {
      return;
    }
    setState(() {
      _pickedPath = picked;
      if (picked != null) {
        _mediaController.text = picked;
      }
    });
  }

  Future<void> _startUpload() async {
    final localPath = _pickedPath;
    if (localPath == null || localPath.isEmpty) {
      return;
    }
    _uploadTaskId = 'up_${DateTime.now().millisecondsSinceEpoch}';
    await _uploadSubscription?.cancel();
    _uploadSubscription = _uploadService
        .uploadFile(
          taskId: _uploadTaskId!,
          localPath: localPath,
          runInBackground: _uploadStatus == UploadStatus.background,
        )
        .listen((event) {
      if (!mounted) {
        return;
      }
      setState(() {
        _uploadStatus = event.status;
        _uploadProgress = event.progress;
        if (event.remotePath != null) {
          _uploadedRemotePath = event.remotePath;
          _mediaController.text = event.remotePath!;
        }
      });
    });
  }

  void _cancelUpload() {
    final taskId = _uploadTaskId;
    if (taskId == null) {
      return;
    }
    _uploadService.cancel(taskId);
  }

  Future<void> _retryUpload() async {
    final localPath = _pickedPath;
    final taskId = _uploadTaskId;
    if (localPath == null || taskId == null) {
      return;
    }
    await _uploadSubscription?.cancel();
    _uploadSubscription = _uploadService
        .retry(taskId: taskId, localPath: localPath)
        .listen((event) {
      if (!mounted) {
        return;
      }
      setState(() {
        _uploadStatus = event.status;
        _uploadProgress = event.progress;
        if (event.remotePath != null) {
          _uploadedRemotePath = event.remotePath;
          _mediaController.text = event.remotePath!;
        }
      });
    });
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
        mediaUrl: _uploadedRemotePath ?? (_mediaController.text.trim().isEmpty ? null : _mediaController.text.trim()),
        isVideo: _isVideo.value,
      ),
    );
  }
}
