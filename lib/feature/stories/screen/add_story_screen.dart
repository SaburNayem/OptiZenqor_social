import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/data/models/story_model.dart';
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
  final MediaPickerService _mediaPickerService = MediaPickerService();

  StoryComposerMode _mode = StoryComposerMode.gallery;
  bool _isLoadingGallery = false;
  bool _hasGalleryPermission = false;
  bool _isMultiSelectEnabled = false;
  int _selectedAlbumIndex = 0;
  final List<String> _selectedAssetIds = <String>[];
  List<AssetPathEntity> _albums = <AssetPathEntity>[];
  List<AssetEntity> _galleryItems = <AssetEntity>[];
  String? _selectedMediaPath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureGalleryAccess();
    });
  }

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
      height: 88,
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
        width: 104,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.lightBackground : Colors.white,
          borderRadius: BorderRadius.circular(12),
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
                size: 22,
                color: selected ? AppColors.primary : Colors.black,
              ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
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
            onTap: _openAlbumMenu,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4,),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedAlbumLabel,
                    style: TextStyle(
                      fontSize: _selectedAlbumIndex == 0 ? 14 : 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.keyboard_arrow_down, size: 20),
                ],
              ),
            ),
          ),
          OutlinedButton.icon(
            onPressed: _hasGalleryPermission ? _toggleMultiSelect : null,
            icon: const Icon(Icons.collections_outlined, size: 16),
            label: Text(
              _isMultiSelectEnabled ? 'Multiple on' : 'Select multiple',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
              side: const BorderSide(color: Colors.black, width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: const Size(0, 34),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: const VisualDensity(
                horizontal: -2,
                vertical: -2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryGrid() {
    if (_isLoadingGallery) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_hasGalleryPermission) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.photo_library_outlined,
                size: 44,
                color: Colors.grey.shade500,
              ),
              const SizedBox(height: 12),
              const Text(
                'Allow photo access first.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'We will load your device photos inside the app and let you switch albums here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _ensureGalleryAccess,
                icon: const Icon(Icons.lock_open_rounded),
                label: const Text('Allow access'),
              ),
            ],
          ),
        ),
      );
    }

    if (_galleryItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.photo_library_outlined,
                size: 44,
                color: Colors.grey.shade500,
              ),
              const SizedBox(height: 12),
              const Text(
                'No recent media available here yet.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'No images found in this album yet. Try another album from the bar above.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

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
            final bool isSelected = _selectedAssetIds.contains(
              _galleryItems[index].id,
            );
            return GestureDetector(
              onTap: () => _selectGalleryItem(index),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AssetEntityImage(
                    _galleryItems[index],
                    fit: BoxFit.cover,
                    isOriginal: false,
                    thumbnailSize: const ThumbnailSize.square(400),
                    errorBuilder: (_, __, ___) => const ColoredBox(
                      color: Color(0x11000000),
                      child: Icon(Icons.broken_image_outlined),
                    ),
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
                                ? '${_selectedOrderFor(_galleryItems[index].id)}'
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
        onPressed: _selectedAssetIds.isEmpty ? null : _shareMultipleNow,
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
      if (!_isMultiSelectEnabled && _selectedAssetIds.length > 1) {
        final String first = _selectedAssetIds.first;
        _selectedAssetIds
          ..clear()
          ..add(first);
      }
    });
  }

  int _selectedOrderFor(String assetId) {
    return _selectedAssetIds.indexOf(assetId) + 1;
  }

  String get _selectedAlbumLabel {
    if (_albums.isEmpty || _selectedAlbumIndex >= _albums.length) {
      return 'Gallery';
    }
    return _selectedAlbumIndex == 0 ? 'All' : _albums[_selectedAlbumIndex].name;
  }

  Future<void> _selectGalleryItem(int index) async {
    final AssetEntity asset = _galleryItems[index];
    setState(() {
      _mode = StoryComposerMode.gallery;
      _selectedMediaPath = null;
      if (_isMultiSelectEnabled) {
        if (_selectedAssetIds.contains(asset.id)) {
          _selectedAssetIds.remove(asset.id);
        } else {
          _selectedAssetIds.add(asset.id);
        }
      } else {
        _selectedAssetIds
          ..clear()
          ..add(asset.id);
      }
    });

    if (!_isMultiSelectEnabled) {
      final File? file = await asset.file;
      if (!mounted || file == null) {
        AppFeedback.showSnackbar(
          title: 'Story',
          message: 'This photo could not be opened.',
        );
        return;
      }
      _openStoryPreview(
        StoryPreviewModel(
          mediaPath: file.path,
          isLocalFile: true,
        ),
      );
    }
  }

  Future<void> _ensureGalleryAccess() async {
    setState(() => _isLoadingGallery = true);
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();
    if (!mounted) {
      return;
    }

    final bool granted =
        permission.isAuth || permission == PermissionState.limited;
    if (!granted) {
      setState(() {
        _isLoadingGallery = false;
        _hasGalleryPermission = false;
      });
      AppFeedback.showSnackbar(
        title: 'Permission needed',
        message: 'Allow photo access to load your gallery inside the app.',
      );
      return;
    }

    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      hasAll: true,
    );
    if (!mounted) {
      return;
    }

    if (albums.isEmpty) {
      setState(() {
        _isLoadingGallery = false;
        _hasGalleryPermission = true;
        _albums = <AssetPathEntity>[];
        _galleryItems = <AssetEntity>[];
      });
      return;
    }

    final List<AssetEntity> assets = await albums.first.getAssetListPaged(
      page: 0,
      size: 200,
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoadingGallery = false;
      _hasGalleryPermission = true;
      _mode = StoryComposerMode.gallery;
      _albums = albums;
      _selectedAlbumIndex = 0;
      _galleryItems = assets;
      _selectedMediaPath = null;
      _selectedAssetIds.clear();
    });
  }

  Future<void> _selectAlbum(int index) async {
    if (index < 0 || index >= _albums.length) {
      return;
    }
    setState(() {
      _isLoadingGallery = true;
      _selectedAlbumIndex = index;
      _selectedAssetIds.clear();
      _selectedMediaPath = null;
    });

    final List<AssetEntity> assets = await _albums[index].getAssetListPaged(
      page: 0,
      size: 200,
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoadingGallery = false;
      _galleryItems = assets;
    });
  }

  Future<void> _openAlbumMenu() async {
    if (!_hasGalleryPermission) {
      await _ensureGalleryAccess();
      return;
    }
    if (_albums.isEmpty) {
      return;
    }

    final RenderBox? overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    final int? nextIndex = await showMenu<int>(
      context: context,
      position: RelativeRect.fromLTRB(
        16,
        150,
        (overlay?.size.width ?? 0) - 220,
        0,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      items: List<PopupMenuEntry<int>>.generate(_albums.length, (int index) {
        final bool isSelected = index == _selectedAlbumIndex;
        final AssetPathEntity album = _albums[index];
        final String label = index == 0 ? 'All' : album.name;

        return PopupMenuItem<int>(
          value: index,
          child: SizedBox(
            width: 180,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  index == 0
                      ? Icons.grid_view_rounded
                      : Icons.photo_album_outlined,
                  size: 18,
                  color: isSelected ? AppColors.primary : Colors.black87,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );

    if (nextIndex == null || nextIndex == _selectedAlbumIndex) {
      return;
    }
    await _selectAlbum(nextIndex);
  }

  Future<void> _pickImage() async {
    await _openAlbumMenu();
  }

  Future<void> _handleCameraCapture() async {
    final String? path = await _mediaPickerService.captureImage();
    if (!mounted || path == null) {
      return;
    }

    setState(() {
      _mode = StoryComposerMode.gallery;
      _selectedMediaPath = path;
      _selectedAssetIds.clear();
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

  Future<void> _openStoryPreview(StoryPreviewModel preview) async {
    final StoryModel? story = await Navigator.of(context).push<StoryModel>(
      MaterialPageRoute<StoryModel>(
        builder: (_) => StoryPreviewScreen(preview: preview),
      ),
    );
    if (!mounted || story == null) {
      return;
    }
    Navigator.of(context).pop(<StoryModel>[story]);
  }

  Future<void> _shareMultipleNow() async {
    if (_selectedAssetIds.isEmpty) {
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) {
      return;
    }

    final Map<String, AssetEntity> assetsById = <String, AssetEntity>{
      for (final AssetEntity asset in _galleryItems) asset.id: asset,
    };
    final List<StoryModel> stories = <StoryModel>[];
    for (final String assetId in _selectedAssetIds) {
      final AssetEntity? asset = assetsById[assetId];
      final File? file = await asset?.file;
      if (file == null) {
        continue;
      }
      stories.add(
        StoryModel(
            id: 'local_story_${DateTime.now().microsecondsSinceEpoch}_$assetId',
            userId: 'u1',
            media: file.path,
            isLocalFile: true,
          ),
      );
    }
    if (!mounted || stories.isEmpty) {
      return;
    }
    Navigator.of(context).pop(stories);
  }

  Future<void> _openTextComposer() async {
    final StoryModel? story = await Navigator.of(context).push<StoryModel>(
      MaterialPageRoute<StoryModel>(
        builder: (_) => const StoryTextComposerScreen(
          config: StoryTextComposerModel(),
        ),
      ),
    );
    if (!mounted || story == null) {
      return;
    }
    Navigator.of(context).pop(<StoryModel>[story]);
  }

  Future<void> _openMusicComposer() async {
    final StoryModel? story = await Navigator.of(context).push<StoryModel>(
      MaterialPageRoute<StoryModel>(
        builder: (_) => const StoryTextComposerScreen(
          config: StoryTextComposerModel(startWithMusic: true),
        ),
      ),
    );
    if (!mounted || story == null) {
      return;
    }
    Navigator.of(context).pop(<StoryModel>[story]);
  }
}
