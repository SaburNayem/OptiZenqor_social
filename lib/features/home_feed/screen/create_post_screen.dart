import 'dart:io';

import 'package:flutter/material.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../core/data/mock/mock_data.dart';
import '../../../core/data/service/media_picker_service.dart';
import '../../../core/widgets/inline_video_player.dart';
import '../../live_stream/model/live_stream_model.dart';
import '../../live_stream/screen/live_broadcast_screen.dart';

class CreatePostResult {
  const CreatePostResult({
    required this.caption,
    this.mediaPaths = const <String>[],
    this.isVideo = false,
    this.audience = 'Everyone',
    this.location,
    this.taggedPeople = const <String>[],
    this.coAuthors = const <String>[],
    this.altText,
    this.editHistory = const <String>[],
    this.feeling,
  });

  final String caption;
  final List<String> mediaPaths;
  final bool isVideo;
  final String audience;
  final String? location;
  final List<String> taggedPeople;
  final List<String> coAuthors;
  final String? altText;
  final List<String> editHistory;
  final String? feeling;
}

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _captionController = TextEditingController();
  final MediaPickerService _mediaPickerService = MediaPickerService();

  List<String> _mediaPaths = <String>[];
  bool _isVideo = false;
  String _audience = 'Everyone';
  String? _location;
  String? _feeling;
  String? _altText;
  List<String> _taggedPeople = <String>[];
  List<String> _coAuthors = <String>[];

  bool get _canShare =>
      _captionController.text.trim().isNotEmpty ||
      _mediaPaths.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _captionController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = MockData.users.first;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => AppGet.back(),
        ),
        title: const Text(
          'New Post',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            child: SizedBox(
              width: 88,
              child: ElevatedButton(
                onPressed: _canShare ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF26C6DA),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      const Color(0xFF26C6DA).withValues(alpha: 0.32),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: const Text(
                  'Share',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  constraints: BoxConstraints(
                    minHeight: 180,
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
                  ),
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(currentUser.avatar),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentUser.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: _pickPrivacy,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.public_rounded,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _audience,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: TextField(
                          controller: _captionController,
                          maxLines: null,
                          minLines: 8,
                          expands: false,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: const InputDecoration(
                            hintText: "What's on your mind?",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildMediaPreview(),
                if (_mediaPaths.isNotEmpty) const SizedBox(height: 24),
                _buildOptionItem(
                  icon: Icons.add_photo_alternate,
                  label: _mediaPaths.isEmpty
                      ? 'Photo / Video'
                      : 'Add more photo / video',
                  bgColor: const Color(0xFFE8F5E9),
                  iconColor: const Color(0xFF4CAF50),
                  onTap: _showMediaPickerSheet,
                ),
                _buildOptionItem(
                  icon: Icons.wifi_tethering_outlined,
                  label: 'Go Live',
                  bgColor: const Color(0xFFFFF3E0),
                  iconColor: const Color(0xFFFF7043),
                  onTap: _goLive,
                ),
                _buildOptionItem(
                  icon: Icons.location_on_outlined,
                  label: _location == null ? 'Check in' : 'Location: $_location',
                  bgColor: const Color(0xFFE3F2FD),
                  iconColor: const Color(0xFF42A5F5),
                  onTap: _pickLocation,
                ),
                _buildOptionItem(
                  icon: Icons.sentiment_satisfied_alt_outlined,
                  label: _feeling == null
                      ? 'Feeling / Activity'
                      : 'Feeling: $_feeling',
                  bgColor: const Color(0xFFFFFDE7),
                  iconColor: const Color(0xFFFFD600),
                  onTap: _pickFeeling,
                ),
                _buildOptionItem(
                  icon: Icons.person_add_alt_1_outlined,
                  label: _taggedPeople.isEmpty
                      ? 'Tag People'
                      : 'Tagged: ${_taggedPeople.join(', ')}',
                  bgColor: const Color(0xFFF3E5F5),
                  iconColor: const Color(0xFF8E24AA),
                  onTap: _pickTaggedPeople,
                ),
                _buildOptionItem(
                  icon: Icons.group_add_outlined,
                  label: _coAuthors.isEmpty
                      ? 'Add collaborators'
                      : 'Collaborators: ${_coAuthors.join(', ')}',
                  bgColor: const Color(0xFFE0F7FA),
                  iconColor: const Color(0xFF00ACC1),
                  onTap: _pickCoAuthors,
                ),
                if (_mediaPaths.isNotEmpty && !_hasAnyVideo)
                  _buildOptionItem(
                    icon: Icons.image_search_outlined,
                    label: _altText == null ? 'Add alt text' : 'Alt text added',
                    bgColor: const Color(0xFFFFF3E0),
                    iconColor: const Color(0xFFFB8C00),
                    onTap: _editAltText,
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.add_photo_alternate_outlined,
                    color: Color(0xFF26C6DA),
                  ),
                  onPressed: _showMediaPickerSheet,
                ),
                IconButton(
                  icon: const Icon(Icons.tag, color: Color(0xFF26C6DA)),
                  onPressed: _pickTaggedPeople,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.sentiment_satisfied_alt_outlined,
                    color: Color(0xFF26C6DA),
                  ),
                  onPressed: _pickFeeling,
                ),
                const Spacer(),
                Text(
                  '${_captionController.text.length} / 280',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool get _hasAnyVideo => _mediaPaths.any(_isVideoPath);

  Widget _buildMediaPreview() {
    if (_mediaPaths.isEmpty) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        color: Colors.black,
        child: Stack(
          children: [
            SizedBox(
              height: 320,
              child: PageView.builder(
                itemCount: _mediaPaths.length,
                itemBuilder: (context, index) {
                  final path = _mediaPaths[index];
                  return AspectRatio(
                    aspectRatio: 1,
                    child: _isVideoPath(path)
                        ? InlineVideoPlayer(
                            filePath: path,
                            autoPlay: false,
                          )
                        : Image.file(
                            File(path),
                            fit: BoxFit.cover,
                          ),
                  );
                },
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Row(
                children: [
                  _buildMediaActionChip(
                    icon: Icons.swap_horiz_rounded,
                    label: 'Replace',
                    onTap: _showMediaPickerSheet,
                  ),
                  const SizedBox(width: 8),
                  _buildMediaActionChip(
                    icon: Icons.close_rounded,
                    label: 'Remove',
                    onTap: () {
                      setState(() {
                        _mediaPaths = <String>[];
                        _isVideo = false;
                        _altText = null;
                      });
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              left: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _hasAnyVideo
                      ? '${_mediaPaths.length} media selected'
                      : '${_mediaPaths.length} photo selected',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            if (_mediaPaths.length > 1)
              Positioned(
                right: 12,
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${_mediaPaths.length} items',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18, left: 8, right: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Future<void> _showMediaPickerSheet() {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose photo / video'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickMediaFiles();
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam_outlined),
                title: const Text('Choose single video'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickVideo();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Take photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _capturePhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickMediaFiles() async {
    final List<String> paths = await _mediaPickerService.pickPostMedia();
    if (paths.isEmpty || !mounted) {
      return;
    }
    setState(() {
      _mediaPaths = paths;
      _isVideo = paths.length == 1 && _isVideoPath(paths.first);
      _altText = null;
    });
  }

  Future<void> _capturePhoto() async {
    final String? path = await _mediaPickerService.captureImage();
    if (path == null || !mounted) {
      return;
    }
    setState(() {
      _mediaPaths = <String>[path];
      _isVideo = false;
      _altText = null;
    });
  }

  Future<void> _pickVideo() async {
    final String? path = await _mediaPickerService.pickVideo();
    if (path == null || !mounted) {
      return;
    }
    setState(() {
      _mediaPaths = <String>[path];
      _isVideo = true;
      _altText = null;
    });
  }

  Future<void> _pickFeeling() async {
    const options = <String>['Happy', 'Excited', 'Traveling', 'Working', 'Blessed'];
    final String? value = await _showSimpleOptionSheet(
      title: 'Choose feeling',
      options: options,
    );
    if (value == null) {
      return;
    }
    setState(() {
      _feeling = value;
    });
  }

  Future<void> _pickLocation() async {
    final TextEditingController controller =
        TextEditingController(text: _location ?? '');
    final String? result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add location'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter location'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (result == null) {
      return;
    }
    setState(() {
      _location = result.isEmpty ? null : result;
    });
  }

  Future<void> _pickTaggedPeople() async {
    final String? result = await _showSimpleOptionSheet(
      title: 'Tag people',
      options: MockData.users.take(5).map((item) => '@${item.username}').toList(),
    );
    if (result == null) {
      return;
    }
    setState(() {
      if (!_taggedPeople.contains(result)) {
        _taggedPeople = <String>[..._taggedPeople, result];
      }
    });
  }

  Future<void> _pickCoAuthors() async {
    final String? result = await _showSimpleOptionSheet(
      title: 'Add collaborator',
      options: MockData.users.skip(1).take(5).map((item) => '@${item.username}').toList(),
    );
    if (result == null) {
      return;
    }
    setState(() {
      if (!_coAuthors.contains(result)) {
        _coAuthors = <String>[..._coAuthors, result];
      }
    });
  }

  Future<void> _editAltText() async {
    final TextEditingController controller =
        TextEditingController(text: _altText ?? '');
    final String? result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add alt text'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Describe this image for accessibility',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (result == null) {
      return;
    }
    setState(() {
      _altText = result.isEmpty ? null : result;
    });
  }

  Future<String?> _showSimpleOptionSheet({
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

  Future<void> _pickPrivacy() async {
    final String? audience = await _showSimpleOptionSheet(
      title: 'Choose privacy',
      options: const <String>['Everyone', 'Followers', 'Close Friends'],
    );
    if (audience == null) {
      return;
    }
    setState(() {
      _audience = audience;
    });
  }

  Future<void> _submit() async {
    final String caption = _captionController.text.trim();
    if (!_canShare) {
      return;
    }
    AppGet.back(
      result: CreatePostResult(
        caption: caption,
        mediaPaths: _mediaPaths,
        isVideo: _isVideo,
        audience: _audience,
        location: _location,
        taggedPeople: _taggedPeople,
        coAuthors: _coAuthors,
        altText: _altText,
        editHistory: _feeling == null ? const <String>[] : <String>['Feeling: $_feeling'],
        feeling: _feeling,
      ),
    );
  }

  bool _isVideoPath(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.m4v') ||
        lower.endsWith('.webm');
  }

  Future<void> _goLive() async {
    if (_mediaPaths.length > 1) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Go Live allows only one photo.')),
        );
      return;
    }
    if (_hasAnyVideo) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Video is not allowed for Go Live.')),
        );
      return;
    }
    final currentUser = MockData.users.first;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LiveBroadcastScreen(
          initialTitle: _captionController.text.trim().isEmpty
              ? '${currentUser.name} is going live'
              : _captionController.text.trim(),
          initialPhotoPath: _mediaPaths.isEmpty ? null : _mediaPaths.first,
          initialAudience: _mapAudience(_audience),
        ),
      ),
    );
  }

  LiveAudienceVisibility _mapAudience(String value) {
    switch (value) {
      case 'Followers':
      case 'Close Friends':
        return LiveAudienceVisibility.friends;
      default:
        return LiveAudienceVisibility.public;
    }
  }
}
