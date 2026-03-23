import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/services/media_picker_service.dart';
import '../../../core/services/upload_service.dart';
import '../../../core/widgets/inline_video_player.dart';
import '../../drafts_and_scheduling/model/draft_item_model.dart';
import '../../drafts_and_scheduling/repository/drafts_and_scheduling_repository.dart';

class CreatePostResult {
  const CreatePostResult({
    required this.caption,
    this.mediaUrl,
    this.isVideo = false,
    this.audience = 'Everyone',
    this.location,
    this.taggedPeople = const <String>[],
    this.coAuthors = const <String>[],
    this.altText,
    this.editHistory = const <String>[],
  });

  final String caption;
  final String? mediaUrl;
  final bool isVideo;
  final String audience;
  final String? location;
  final List<String> taggedPeople;
  final List<String> coAuthors;
  final String? altText;
  final List<String> editHistory;
}

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _mediaController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _tagPeopleController = TextEditingController();
  final TextEditingController _coAuthorsController = TextEditingController();
  final TextEditingController _altTextController = TextEditingController();
  final ValueNotifier<bool> _isVideo = ValueNotifier<bool>(false);
  final ValueNotifier<String> _audience = ValueNotifier<String>('Everyone');
  final MediaPickerService _pickerService = MediaPickerService();
  final UploadService _uploadService = UploadService();
  final DraftsAndSchedulingRepository _draftRepository =
      DraftsAndSchedulingRepository();

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
    _locationController.dispose();
    _tagPeopleController.dispose();
    _coAuthorsController.dispose();
    _altTextController.dispose();
    _isVideo.dispose();
    _audience.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          IconButton(
            onPressed: _saveDraft,
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Save draft',
          ),
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
          ValueListenableBuilder<String>(
            valueListenable: _audience,
            builder: (context, audience, child) {
              return DropdownButtonFormField<String>(
                initialValue: audience,
                decoration: const InputDecoration(
                  labelText: 'Audience',
                  border: OutlineInputBorder(),
                ),
                items: const <String>[
                  'Everyone',
                  'Followers',
                  'Close Friends',
                  'Subscribers',
                ]
                    .map(
                      (value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    _audience.value = value;
                  }
                },
              );
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Location tag',
              hintText: 'Add location',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tagPeopleController,
            decoration: const InputDecoration(
              labelText: 'Tag people',
              hintText: '@username1, @username2',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _coAuthorsController,
            decoration: const InputDecoration(
              labelText: 'Co-authors',
              hintText: '@collab.creator',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _altTextController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Alt text placeholder',
              hintText: 'Describe the media for accessibility',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              Chip(label: Text('Version history placeholder')),
              Chip(label: Text('Collaborative post placeholder')),
              Chip(label: Text('Edit history placeholder')),
            ],
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
                        onSelected: (selected) {
                          _isVideo.value = false;
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Video'),
                        selected: isVideo,
                        onSelected: (selected) {
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
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Story and Reel Creation Depth',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text('Story stickers')),
                      Chip(label: Text('Poll sticker')),
                      Chip(label: Text('Question sticker')),
                      Chip(label: Text('Emoji slider')),
                      Chip(label: Text('Mention sticker')),
                      Chip(label: Text('Location sticker')),
                      Chip(label: Text('Music sticker')),
                      Chip(label: Text('Link sticker')),
                      Chip(label: Text('Reel audio attach')),
                      Chip(label: Text('Text overlays')),
                      Chip(label: Text('Captions placeholder')),
                      Chip(label: Text('Trim/crop placeholder')),
                      Chip(label: Text('Cover selection')),
                      Chip(label: Text('Remix/duet placeholder')),
                      Chip(label: Text('Save reel draft')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveDraft() async {
    final title = _captionController.text.trim().isEmpty
        ? 'Untitled draft'
        : _captionController.text.trim();
    await _draftRepository.write(<DraftItemModel>[
      DraftItemModel(
        id: 'draft_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        type: _isVideo.value ? PublishType.reel : PublishType.post,
        audience: _audience.value,
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        taggedPeople: _splitCsv(_tagPeopleController.text),
        coAuthors: _splitCsv(_coAuthorsController.text),
        altText: _altTextController.text.trim().isEmpty
            ? null
            : _altTextController.text.trim(),
        versionHistory: const <String>[
          'Initial draft saved locally',
          'Version history placeholder',
        ],
        editHistory: const <String>['Draft saved from composer'],
      ),
      ...await _draftRepository.read(),
    ]);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Draft saved locally')));
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
        audience: _audience.value,
        location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        taggedPeople: _splitCsv(_tagPeopleController.text),
        coAuthors: _splitCsv(_coAuthorsController.text),
        altText: _altTextController.text.trim().isEmpty ? null : _altTextController.text.trim(),
        editHistory: const <String>[
          'Created from composer',
          'Post edit history placeholder',
        ],
      ),
    );
  }

  List<String> _splitCsv(String value) {
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }
}
