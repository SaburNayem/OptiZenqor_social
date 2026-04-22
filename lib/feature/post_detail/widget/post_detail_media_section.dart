import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/common_widget/inline_video_player.dart';
import '../../../core/constants/app_colors.dart';
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
  Widget build(BuildContext context) {
    if (widget.media.isEmpty) {
      return const SizedBox.shrink();
    }

    final double size = MediaQuery.of(context).size.width;

    return Column(
      children: [
        SizedBox(
          height: size,
          width: double.infinity,
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
                        : _ImagePreview(source: source),
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
                          backgroundColor:
                              AppColors.black.withValues(alpha: 0.62),
                          foregroundColor: AppColors.white,
                        ),
                        icon: const Icon(Icons.open_in_full_rounded, size: 18),
                        label: const Text('Open video'),
                      ),
                    ),
                ],
              );
            },
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
                    color: isActive
                        ? AppColors.hexFF26C6DA
                        : AppColors.grey300,
                    borderRadius: BorderRadius.circular(99),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.source});

  final String source;

  @override
  Widget build(BuildContext context) {
    final bool isNetworkSource =
        source.startsWith('http://') || source.startsWith('https://');

    return isNetworkSource
        ? Image.network(source, fit: BoxFit.cover)
        : Image.file(File(source), fit: BoxFit.cover);
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
