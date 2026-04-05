import 'package:flutter/material.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/data/service/media_picker_service.dart';
import '../../../core/functions/app_feedback.dart';
import '../model/story_preview_model.dart';
import '../model/story_text_composer_model.dart';
import 'story_preview_screen.dart';
import 'story_text_composer_screen.dart';

enum StoryComposerMode { gallery }

class AddStoryScreen extends StatefulWidget {
  const AddStoryScreen({super.key});

  @override
  State<AddStoryScreen> createState() => _AddStoryScreenState();
}

class _AddStoryScreenState extends State<AddStoryScreen> {
  static const List<String> _galleryItems = <String>[
    'https://picsum.photos/seed/50/400/600',
    'https://picsum.photos/seed/51/400/600',
    'https://picsum.photos/seed/52/400/600',
    'https://picsum.photos/seed/53/400/600',
    'https://picsum.photos/seed/54/400/600',
    'https://picsum.photos/seed/55/400/600',
    'https://picsum.photos/seed/56/400/600',
    'https://picsum.photos/seed/57/400/600',
    'https://picsum.photos/seed/58/400/600',
    'https://picsum.photos/seed/59/400/600',
    'https://picsum.photos/seed/60/400/600',
    'https://picsum.photos/seed/61/400/600',
  ];

  final MediaPickerService _mediaPickerService = MediaPickerService();

  StoryComposerMode _mode = StoryComposerMode.gallery;
  bool _isMultiSelectEnabled = false;
  final Set<int> _selectedGalleryIndexes = <int>{};
  String? _selectedMediaPath;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildComposerOptions(),
          const SizedBox(height: 18),
          _buildGalleryHeader(),
          const SizedBox(height: 12),
          Expanded(
            child: _buildGalleryGrid(),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingAction(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.black, size: 28),
        onPressed: () => AppGet.back<void>(),
      ),
      title: const Text(
        'Create story',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.black, size: 28),
          onPressed: _showSettingsMessage,
        ),
      ],
    );
  }

  Widget _buildComposerOptions() {
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildOptionCard(
            child: const Text(
              'Aa',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            label: 'Text',
            selected: false,
            onTap: _openTextComposer,
          ),
          _buildOptionCard(
            icon: Icons.music_note_outlined,
            label: 'Music',
            selected: false,
            onTap: _openMusicComposer,
          ),
          _buildOptionCard(
            icon: Icons.photo_library_outlined,
            label: 'Gallery',
            selected: _mode == StoryComposerMode.gallery,
            onTap: _activateGalleryMode,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    IconData? icon,
    Widget? child,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.lightBackground : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.35)
                : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (child != null)
              child
            else
              Icon(
                icon,
                size: 28,
                color: selected ? AppColors.primary : Colors.black,
              ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: selected ? AppColors.primary : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: _pickImage,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Gallery',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down, size: 28),
                ],
              ),
            ),
          ),
          OutlinedButton.icon(
            onPressed: _toggleMultiSelect,
            icon: const Icon(Icons.collections_outlined, size: 20),
            label: Text(
              _isMultiSelectEnabled ? 'Multiple on' : 'Select multiple',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
              side: const BorderSide(color: Colors.black, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryGrid() {
    return Stack(
      key: const ValueKey<String>('gallery-grid'),
      children: [
        GridView.builder(
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
            childAspectRatio: 0.8,
          ),
          itemCount: _galleryItems.length,
          itemBuilder: (BuildContext context, int index) {
            final bool isSelected = _selectedGalleryIndexes.contains(index);
            return GestureDetector(
              onTap: () => _selectGalleryItem(index),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _galleryItems[index],
                    fit: BoxFit.cover,
                  ),
                  if (index == 0)
                    Positioned(
                      left: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '00:06',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (isSelected)
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary, width: 4),
                        color: Colors.black.withValues(alpha: 0.12),
                      ),
                    ),
                  if (isSelected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _isMultiSelectEnabled
                                ? '${_selectedOrderFor(index)}'
                                : '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        if (_selectedMediaPath != null)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Material(
              color: Colors.black.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.image_rounded,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Selected image: ${_selectedMediaPath!.split('/').last}',
                        style: const TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedMediaPath = null;
                        });
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFloatingAction() {
    if (_isMultiSelectEnabled) {
      return FloatingActionButton.extended(
        onPressed: _selectedGalleryIndexes.isEmpty ? null : _shareMultipleNow,
        backgroundColor: AppColors.splashBackground,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.send_rounded),
        label: const Text(
          'Share now',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      );
    }

    return FloatingActionButton(
      onPressed: _handleCameraCapture,
      backgroundColor: Colors.white,
      elevation: 8,
      shape: const CircleBorder(),
      child: const Icon(
        Icons.camera_alt,
        color: AppColors.primary,
        size: 28,
      ),
    );
  }

  void _activateGalleryMode() {
    setState(() => _mode = StoryComposerMode.gallery);
  }

  void _toggleMultiSelect() {
    setState(() {
      _isMultiSelectEnabled = !_isMultiSelectEnabled;
      if (!_isMultiSelectEnabled && _selectedGalleryIndexes.length > 1) {
        final int first = _selectedGalleryIndexes.first;
        _selectedGalleryIndexes
          ..clear()
          ..add(first);
      }
    });
  }

  int _selectedOrderFor(int index) {
    return _selectedGalleryIndexes.toList().indexOf(index) + 1;
  }

  void _selectGalleryItem(int index) {
    setState(() {
      _mode = StoryComposerMode.gallery;
      _selectedMediaPath = null;
      if (_isMultiSelectEnabled) {
        if (_selectedGalleryIndexes.contains(index)) {
          _selectedGalleryIndexes.remove(index);
        } else {
          _selectedGalleryIndexes.add(index);
        }
      } else {
        _selectedGalleryIndexes
          ..clear()
          ..add(index);
      }
    });

    if (!_isMultiSelectEnabled) {
      _openStoryPreview(
        StoryPreviewModel(
          mediaPath: _galleryItems[index],
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final String? path = await _mediaPickerService.pickImage();
    if (!mounted || path == null) {
      return;
    }

    setState(() {
      _mode = StoryComposerMode.gallery;
      _selectedMediaPath = path;
      _selectedGalleryIndexes.clear();
    });
    _openStoryPreview(
      StoryPreviewModel(
        mediaPath: path,
        isLocalFile: true,
      ),
    );
  }

  Future<void> _handleCameraCapture() async {
    final String? path = await _mediaPickerService.captureImage();
    if (!mounted || path == null) {
      return;
    }

    setState(() {
      _mode = StoryComposerMode.gallery;
      _selectedMediaPath = path;
      _selectedGalleryIndexes.clear();
    });
    _openStoryPreview(
      StoryPreviewModel(
        mediaPath: path,
        isLocalFile: true,
      ),
    );
  }

  void _showSettingsMessage() {
    AppFeedback.showSnackbar(
      title: 'Settings',
      message: 'Story settings coming soon',
    );
  }

  void _openStoryPreview(StoryPreviewModel preview) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StoryPreviewScreen(preview: preview),
      ),
    );
  }

  Future<void> _shareMultipleNow() async {
    if (_selectedGalleryIndexes.isEmpty) {
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) {
      return;
    }

    AppFeedback.showSnackbar(
      title: 'Stories shared',
      message: '${_selectedGalleryIndexes.length} items shared to your story.',
    );
    AppGet.back<void>();
  }

  void _openTextComposer() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const StoryTextComposerScreen(
          config: StoryTextComposerModel(),
        ),
      ),
    );
  }

  void _openMusicComposer() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const StoryTextComposerScreen(
          config: StoryTextComposerModel(startWithMusic: true),
        ),
      ),
    );
  }
}
