import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/common_widget/inline_video_player.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/platform/device_settings_service.dart';
import '../../media_viewer/model/media_viewer_item_model.dart';

class PostDetailMediaSection extends StatefulWidget {
  const PostDetailMediaSection({
    super.key,
    required this.media,
    required this.onMediaTap,
  });

  final List<String> media;
  final ValueChanged<int> onMediaTap;

  @override
  State<PostDetailMediaSection> createState() => _PostDetailMediaSectionState();
}

class _PostDetailMediaSectionState extends State<PostDetailMediaSection> {
  late final PageController _pageController;
  final Map<String, double> _aspectRatios = <String, double>{};
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PostDetailMediaSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.media != widget.media) {
      _currentIndex = 0;
      _aspectRatios.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.media.isEmpty) {
      return const SizedBox.shrink();
    }

    final Size screenSize = MediaQuery.sizeOf(context);
    final String activeSource = widget.media[_currentIndex];
    final double? activeAspectRatio = _aspectRatios[activeSource];
    final double maxMediaHeight = screenSize.height * 0.72;
    final double mediaHeight = activeAspectRatio == null
        ? screenSize.width
        : (screenSize.width / activeAspectRatio).clamp(1, maxMediaHeight);

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: mediaHeight,
          width: double.infinity,
          child: ColoredBox(
            color: const Color(0xFFF2F5F7),
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.media.length,
              onPageChanged: (value) {
                setState(() {
                  _currentIndex = value;
                });
              },
              itemBuilder: (context, index) {
                final String source = widget.media[index];
                final MediaViewerItemModel item =
                    MediaViewerItemModel.fromSource(source);

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    InkWell(
                      onTap: () => widget.onMediaTap(index),
                      child: item.isVideo
                          ? _VideoPreview(item: item)
                          : _ImagePreview(
                              source: source,
                              onAspectRatioResolved: (aspectRatio) =>
                                  _setAspectRatio(source, aspectRatio),
                            ),
                    ),
                    if (widget.media.length > 1)
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            '${index + 1}/${widget.media.length}',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    if (item.isVideo)
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: FilledButton.icon(
                          onPressed: () => widget.onMediaTap(index),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.black.withValues(
                              alpha: 0.62,
                            ),
                            foregroundColor: AppColors.white,
                          ),
                          icon: const Icon(
                            Icons.open_in_full_rounded,
                            size: 18,
                          ),
                          label: const Text('Open video'),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
        if (widget.media.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(widget.media.length, (index) {
                final bool isActive = index == _currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: isActive ? 20 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.hexFF26C6DA : AppColors.grey300,
                    borderRadius: BorderRadius.circular(99),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  void _setAspectRatio(String source, double aspectRatio) {
    if (!mounted || aspectRatio <= 0 || _aspectRatios[source] == aspectRatio) {
      return;
    }
    setState(() {
      _aspectRatios[source] = aspectRatio;
    });
  }
}

class _ImagePreview extends StatefulWidget {
  const _ImagePreview({
    required this.source,
    required this.onAspectRatioResolved,
  });

  final String source;
  final ValueChanged<double> onAspectRatioResolved;

  @override
  State<_ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<_ImagePreview> {
  static const Duration _slowNetworkDelay = Duration(seconds: 30);

  Timer? _slowNetworkTimer;
  bool _showSlowNetworkActions = false;
  int _retryToken = 0;
  ImageStream? _imageStream;
  ImageStreamListener? _imageStreamListener;

  bool get _isNetworkSource =>
      widget.source.startsWith('http://') ||
      widget.source.startsWith('https://');

  @override
  void initState() {
    super.initState();
    if (_isNetworkSource) {
      _startSlowNetworkTimer();
    }
    _resolveAspectRatio();
  }

  @override
  void didUpdateWidget(covariant _ImagePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) {
      _showSlowNetworkActions = false;
      _slowNetworkTimer?.cancel();
      if (_isNetworkSource) {
        _startSlowNetworkTimer();
      }
      _resolveAspectRatio();
    }
  }

  @override
  void dispose() {
    _slowNetworkTimer?.cancel();
    _removeImageStreamListener();
    super.dispose();
  }

  void _startSlowNetworkTimer() {
    _slowNetworkTimer?.cancel();
    _slowNetworkTimer = Timer(_slowNetworkDelay, () {
      if (!mounted) {
        return;
      }
      setState(() {
        _showSlowNetworkActions = true;
      });
    });
  }

  void _retryImage() {
    setState(() {
      _retryToken += 1;
      _showSlowNetworkActions = false;
    });
    _startSlowNetworkTimer();
  }

  Future<void> _openNetworkSettings() async {
    final bool opened = await DeviceSettingsService.openNetworkSettings();
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open device network settings.'),
        ),
      );
    }
  }

  void _resolveAspectRatio() {
    _removeImageStreamListener();
    final ImageProvider provider = _isNetworkSource
        ? NetworkImage(widget.source)
        : FileImage(File(widget.source));
    final ImageStream stream = provider.resolve(const ImageConfiguration());
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (ImageInfo imageInfo, bool synchronousCall) {
        final int width = imageInfo.image.width;
        final int height = imageInfo.image.height;
        if (width > 0 && height > 0) {
          widget.onAspectRatioResolved(width / height);
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
    final double devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final Size screenSize = MediaQuery.sizeOf(context);
    final int cacheWidth = (screenSize.width * devicePixelRatio).round();

    return _isNetworkSource
        ? Image.network(
            widget.source,
            key: ValueKey<String>('${widget.source}-$_retryToken'),
            fit: BoxFit.contain,
            cacheWidth: cacheWidth,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                _slowNetworkTimer?.cancel();
                return child;
              }
              if (_showSlowNetworkActions) {
                return _NetworkRetryPanel(
                  title: 'Image is taking too long to load.',
                  onRetry: _retryImage,
                  onOpenSettings: _openNetworkSettings,
                );
              }
              return const ColoredBox(
                color: Color(0xFFF2F5F7),
                child: Center(child: CircularProgressIndicator()),
              );
            },
            errorBuilder: (context, error, stackTrace) => _NetworkRetryPanel(
              title: 'Unable to load this image.',
              onRetry: _retryImage,
              onOpenSettings: _openNetworkSettings,
            ),
          )
        : Image.file(
            File(widget.source),
            fit: BoxFit.contain,
            cacheWidth: cacheWidth,
          );
  }
}

class _NetworkRetryPanel extends StatelessWidget {
  const _NetworkRetryPanel({
    required this.title,
    required this.onRetry,
    required this.onOpenSettings,
  });

  final String title;
  final VoidCallback onRetry;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF2F5F7),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 44,
                color: AppColors.primary,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Check Wi-Fi or mobile data, then try again.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.grey600),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Retry'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onOpenSettings,
                    icon: const Icon(Icons.settings_outlined, size: 18),
                    label: const Text('Network settings'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoPreview extends StatelessWidget {
  const _VideoPreview({required this.item});

  final MediaViewerItemModel item;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          color: AppColors.black,
          child: AbsorbPointer(
            child: InlineVideoPlayer(
              networkUrl: item.isNetworkSource ? item.source : null,
              filePath: item.isNetworkSource ? null : item.source,
              autoPlay: false,
              looping: false,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                AppColors.transparent,
                AppColors.black.withValues(alpha: 0.18),
                AppColors.black.withValues(alpha: 0.52),
              ],
            ),
          ),
        ),
        const Center(
          child: Icon(
            Icons.play_circle_fill_rounded,
            size: 72,
            color: AppColors.white,
          ),
        ),
      ],
    );
  }
}
