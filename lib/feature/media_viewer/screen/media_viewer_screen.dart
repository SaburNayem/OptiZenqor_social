import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/common_widget/inline_video_player.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/navigation/app_get.dart';
import '../controller/media_viewer_controller.dart';
import '../model/media_viewer_item_model.dart';
import '../model/media_viewer_route_arguments.dart';

class MediaViewerScreen extends StatefulWidget {
  const MediaViewerScreen({super.key, this.arguments});

  final MediaViewerRouteArguments? arguments;

  @override
  State<MediaViewerScreen> createState() => _MediaViewerScreenState();
}

class _MediaViewerScreenState extends State<MediaViewerScreen> {
  late final MediaViewerController _controller;
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _controller = MediaViewerController.fromArguments(widget.arguments);
    _currentIndex = _controller.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _shareCurrentItem() {
    final item = _controller.itemAt(_currentIndex);
    AppGet.snackbar(
      'Share media',
      item.isVideo
          ? 'Static share sheet opened for this video'
          : 'Static share sheet opened for this photo',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _controller.items.length,
              onPageChanged: (value) {
                setState(() {
                  _currentIndex = value;
                });
              },
              itemBuilder: (context, index) {
                return _MediaViewerPage(item: _controller.items[index]);
              },
            ),
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  _ViewerIconButton(icon: Icons.arrow_back, onTap: AppGet.back),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _controller.title ?? 'Media viewer',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${_currentIndex + 1} of ${_controller.items.length}',
                          style: const TextStyle(
                            color: AppColors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _ViewerIconButton(
                    icon: Icons.share_outlined,
                    onTap: _shareCurrentItem,
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 28,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(_controller.items.length, (
                  index,
                ) {
                  final bool isActive = index == _currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.white : AppColors.white54,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaViewerPage extends StatelessWidget {
  const _MediaViewerPage({required this.item});

  final MediaViewerItemModel item;

  @override
  Widget build(BuildContext context) {
    if (item.isVideo) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: InlineVideoPlayer(
            networkUrl: item.isNetworkSource ? item.source : null,
            filePath: item.isNetworkSource ? null : item.source,
            autoPlay: true,
            looping: true,
          ),
        ),
      );
    }

    return InteractiveViewer(
      minScale: 1,
      maxScale: 4,
      child: Center(child: _ViewerPhoto(item: item)),
    );
  }
}

class _ViewerPhoto extends StatefulWidget {
  const _ViewerPhoto({required this.item});

  final MediaViewerItemModel item;

  @override
  State<_ViewerPhoto> createState() => _ViewerPhotoState();
}

class _ViewerPhotoState extends State<_ViewerPhoto> {
  ImageStream? _imageStream;
  ImageStreamListener? _imageStreamListener;
  double? _aspectRatio;

  @override
  void initState() {
    super.initState();
    _resolveAspectRatio();
  }

  @override
  void didUpdateWidget(covariant _ViewerPhoto oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.source != widget.item.source) {
      _aspectRatio = null;
      _resolveAspectRatio();
    }
  }

  @override
  void dispose() {
    _removeImageStreamListener();
    super.dispose();
  }

  void _resolveAspectRatio() {
    _removeImageStreamListener();
    final ImageProvider provider = widget.item.isNetworkSource
        ? NetworkImage(widget.item.source)
        : FileImage(File(widget.item.source));
    final ImageStream stream = provider.resolve(const ImageConfiguration());
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (ImageInfo imageInfo, bool synchronousCall) {
        final int width = imageInfo.image.width;
        final int height = imageInfo.image.height;
        if (width > 0 && height > 0 && mounted) {
          setState(() {
            _aspectRatio = width / height;
          });
        }
        stream.removeListener(listener);
        if (_imageStream == stream) {
          _imageStream = null;
          _imageStreamListener = null;
        }
      },
      onError: (_, _) {
        stream.removeListener(listener);
        if (_imageStream == stream) {
          _imageStream = null;
          _imageStreamListener = null;
        }
      },
    );
    _imageStream = stream;
    _imageStreamListener = listener;
    stream.addListener(listener);
  }

  void _removeImageStreamListener() {
    final ImageStream? stream = _imageStream;
    final ImageStreamListener? listener = _imageStreamListener;
    if (stream != null && listener != null) {
      stream.removeListener(listener);
    }
    _imageStream = null;
    _imageStreamListener = null;
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);
    final double devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final double aspectRatio = _aspectRatio ?? 1;
    final double maxImageHeight = screenSize.height * 0.82;
    final double imageHeight = (screenSize.width / aspectRatio).clamp(
      1,
      maxImageHeight,
    );
    final int cacheWidth = (screenSize.width * devicePixelRatio).round();

    return SizedBox(
      width: screenSize.width,
      height: imageHeight,
      child: widget.item.isNetworkSource
          ? Image.network(
              widget.item.source,
              fit: BoxFit.contain,
              cacheWidth: cacheWidth,
            )
          : Image.file(
              File(widget.item.source),
              fit: BoxFit.contain,
              cacheWidth: cacheWidth,
            ),
    );
  }
}

class _ViewerIconButton extends StatelessWidget {
  const _ViewerIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.45),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: AppColors.white),
      ),
    );
  }
}
