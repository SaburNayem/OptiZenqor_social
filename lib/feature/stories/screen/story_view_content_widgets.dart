part of 'story_view_screen.dart';

extension _StoryViewContentWidgets on _StoryViewScreenState {
  Widget _buildStoryContent(StoryModel story) {
    final List<String> mediaItems = story.mediaItems.isNotEmpty
        ? story.mediaItems
        : (story.media.trim().isNotEmpty ? <String>[story.media] : <String>[]);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Size canvasSize = constraints.biggest;

        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Positioned.fill(
              child: _buildStoryCanvasBackground(story, mediaItems),
            ),
            if (mediaItems.length == 1 && !_looksLikeVideo(mediaItems.first))
              Positioned.fill(
                child: _buildSinglePhotoStoryMedia(
                  story: story,
                  path: mediaItems.first,
                  bodySize: canvasSize,
                ),
              )
            else if (mediaItems.isNotEmpty)
              ...List<Widget>.generate(mediaItems.length, (int index) {
                final StoryMediaTransform transform =
                    index < story.mediaTransforms.length
                    ? story.mediaTransforms[index]
                    : (mediaItems.length == 1
                          ? const StoryMediaTransform(
                              widthFactor: 1,
                              heightFactor: 1,
                              borderRadius: 0,
                            )
                          : const StoryMediaTransform());

                return Positioned.fill(
                  child: _buildMoveableStoryMedia(
                    story: story,
                    path: mediaItems[index],
                    transform: transform,
                    bodySize: canvasSize,
                  ),
                );
              }),
            Positioned.fill(child: _buildStoryTextOverlay(story, canvasSize)),
          ],
        );
      },
    );
  }

  Widget _buildSinglePhotoStoryMedia({
    required StoryModel story,
    required String path,
    required Size bodySize,
  }) {
    final StoryMediaTransform transform = story.mediaTransforms.isNotEmpty
        ? story.mediaTransforms.first
        : const StoryMediaTransform(
            widthFactor: 1,
            heightFactor: 1,
            borderRadius: 0,
          );

    return Center(
      child: Transform.translate(
        offset: Offset(transform.offsetDx, transform.offsetDy),
        child: Transform.scale(
          scale: transform.scale,
          child: SizedBox(
            width: bodySize.width,
            height: bodySize.height,
            child: _buildStoryMediaItem(story, path, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  Widget _buildStoryCanvasBackground(
    StoryModel story,
    List<String> mediaItems,
  ) {
    if (mediaItems.isNotEmpty && !_looksLikeVideo(mediaItems.first)) {
      return Stack(
        fit: StackFit.expand,
        children: <Widget>[
          _buildStoryMediaItem(story, mediaItems.first, fit: BoxFit.cover),
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 22, sigmaY: 22),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.black.withValues(alpha: 0.18),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      AppColors.black.withValues(alpha: 0.10),
                      AppColors.black.withValues(alpha: 0.24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    final List<Color> backgroundColors = story.backgroundColors.isEmpty
        ? const <Color>[AppColors.black, AppColors.grey800]
        : story.backgroundColors
              .map((int color) => Color(color))
              .toList(growable: false);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: backgroundColors.length == 1
              ? <Color>[backgroundColors.first, backgroundColors.first]
              : backgroundColors,
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildStoryFixedMediaSection(
    StoryModel story,
    List<String> mediaItems,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.grey100,
          border: Border.all(color: AppColors.grey200),
        ),
        child: mediaItems.isEmpty
            ? const SizedBox.expand()
            : Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  _buildStoryHeroMedia(story, mediaItems.first),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Row(
                      children: <Widget>[
                        _buildStoryChip(
                          icon:
                              story.media.trim().toLowerCase().endsWith('.mp4')
                              ? Icons.videocam_rounded
                              : Icons.photo_rounded,
                          label:
                              story.media.trim().toLowerCase().endsWith('.mp4')
                              ? 'Video'
                              : 'Photo',
                        ),
                        if (mediaItems.length > 1) ...<Widget>[
                          const SizedBox(width: 8),
                          _buildStoryChip(
                            icon: Icons.layers_rounded,
                            label: '+${mediaItems.length - 1} moveable',
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildStoryBodyCanvas({
    required StoryModel story,
    required List<String> bodyMediaItems,
    required Size bodySize,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.grey200),
        ),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[AppColors.white, AppColors.hexFFF8FAFC],
                  ),
                ),
              ),
            ),
            for (int index = 0; index < bodyMediaItems.length; index++)
              Positioned.fill(
                child: _buildMoveableStoryMedia(
                  story: story,
                  path: bodyMediaItems[index],
                  transform: index < story.mediaTransforms.length
                      ? story.mediaTransforms[index]
                      : const StoryMediaTransform(),
                  bodySize: bodySize,
                ),
              ),
            Positioned.fill(child: _buildStoryTextOverlay(story, bodySize)),
          ],
        ),
      ),
    );
  }

  Widget _buildMoveableStoryMedia({
    required StoryModel story,
    required String path,
    required StoryMediaTransform transform,
    required Size bodySize,
  }) {
    return Center(
      child: Transform.translate(
        offset: Offset(transform.offsetDx, transform.offsetDy),
        child: Transform.scale(
          scale: transform.scale,
          child: SizedBox(
            width: bodySize.width * transform.widthFactor,
            height: bodySize.height * transform.heightFactor,
            child: ClipRect(
              child: _buildStoryMediaItem(story, path, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoryTextOverlay(StoryModel story, Size bodySize) {
    final bool hasMeta =
        (story.sticker ?? '').trim().isNotEmpty ||
        (story.mentionUsername ?? '').trim().isNotEmpty;
    final bool hasContent = story.hasText || hasMeta;

    if (!hasContent) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Transform.translate(
        offset: Offset(story.textOffsetDx, story.textOffsetDy),
        child: Transform.scale(
          alignment: Alignment.centerLeft,
          scale: story.textScale == 0 ? 1 : story.textScale,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if ((story.music ?? '').trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildStoryChip(
                      icon: Icons.music_note_rounded,
                      label: story.music!,
                    ),
                  ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    if ((story.sticker ?? '').trim().isNotEmpty)
                      _buildStoryChip(
                        icon: Icons.emoji_emotions_outlined,
                        label: story.sticker!,
                      ),
                    if ((story.mentionUsername ?? '').trim().isNotEmpty)
                      _buildStoryChip(
                        icon: Icons.alternate_email_rounded,
                        label: '@${story.mentionUsername!}',
                      ),
                  ],
                ),
                if (story.hasText) ...<Widget>[
                  const SizedBox(height: 14),
                  Text(
                    story.text!,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Color(story.textColorValue),
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      height: 1.12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoryHeroMedia(StoryModel story, String path) {
    if (_looksLikeVideo(path)) {
      return ColoredBox(
        color: AppColors.black,
        child: InlineVideoPlayer(
          filePath: story.isLocalFile ? path : null,
          networkUrl: story.isLocalFile ? null : path,
          autoPlay: true,
        ),
      );
    }

    return _buildStoryMediaItem(story, path);
  }

  bool _looksLikeVideo(String path) {
    final String normalized = path.trim().toLowerCase();
    return normalized.endsWith('.mp4') ||
        normalized.endsWith('.mov') ||
        normalized.endsWith('.m4v') ||
        normalized.endsWith('.webm');
  }

  // ignore: unused_element
  Widget _buildStoryMedia(StoryModel story, List<String> mediaItems) {
    return DecoratedBox(
      decoration: BoxDecoration(color: AppColors.black.withValues(alpha: 0.2)),
      child: mediaItems.length == 1
          ? _buildStoryMediaItem(story, mediaItems.first)
          : _buildStoryCollage(story, mediaItems),
    );
  }

  Widget _buildStoryCollage(StoryModel story, List<String> mediaItems) {
    switch (story.collageLayout) {
      case 'mosaic':
        return _buildMosaicStoryCollage(story, mediaItems);
      case 'stack':
        return _buildStackStoryCollage(story, mediaItems);
      case 'grid':
      default:
        return _buildGridStoryCollage(story, mediaItems);
    }
  }

  Widget _buildGridStoryCollage(StoryModel story, List<String> mediaItems) {
    final int count = mediaItems.length.clamp(1, 7);
    final int crossAxisCount = count <= 2
        ? 1
        : count <= 4
        ? 2
        : 3;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: count,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
          childAspectRatio: count == 1 ? 0.7 : 0.9,
        ),
        itemBuilder: (BuildContext context, int index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: _buildStoryMediaItem(story, mediaItems[index]),
          );
        },
      ),
    );
  }

  Widget _buildMosaicStoryCollage(StoryModel story, List<String> mediaItems) {
    final List<String> items = mediaItems.take(7).toList(growable: false);
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _buildStoryMediaItem(story, items.first),
                  ),
                ),
                if (items.length > 1) const SizedBox(width: 6),
                if (items.length > 1)
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: _buildStoryMediaItem(story, items[1]),
                          ),
                        ),
                        if (items.length > 2) const SizedBox(height: 6),
                        if (items.length > 2)
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: _buildStoryMediaItem(story, items[2]),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (items.length > 3) const SizedBox(height: 6),
          if (items.length > 3)
            Expanded(
              flex: 3,
              child: Row(
                children: List<Widget>.generate(items.length - 3, (int index) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: index == 0 ? 0 : 6),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: _buildStoryMediaItem(story, items[index + 3]),
                      ),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStackStoryCollage(StoryModel story, List<String> mediaItems) {
    final List<String> items = mediaItems.take(7).toList(growable: false);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: List<Widget>.generate(items.length, (int index) {
          final double inset = index * 16;
          return Positioned(
            left: inset,
            right: inset,
            top: inset + 24,
            bottom: inset + 40,
            child: Transform.rotate(
              angle: (index.isEven ? -1 : 1) * 0.035,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.7),
                      width: 2,
                    ),
                  ),
                  child: _buildStoryMediaItem(story, items[index]),
                ),
              ),
            ),
          );
        }).reversed.toList(growable: false),
      ),
    );
  }

  Widget _buildStoryMediaItem(
    StoryModel story,
    String path, {
    BoxFit fit = BoxFit.contain,
  }) {
    if (story.isLocalFile) {
      return Image.file(
        File(path),
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image_outlined, color: AppColors.white),
      );
    }
    return Image.network(
      path,
      fit: fit,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.broken_image_outlined, color: AppColors.white),
    );
  }

  Widget _buildStoryChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.white, size: 16),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  void _openStoryLink(StoryModel story) {
    final String target = (story.linkUrl ?? '').trim();
    if (target.isEmpty) {
      return;
    }
    if (target == RouteNames.privacySettings ||
        target.contains('privacySettings') ||
        target.contains('/settings/privacy')) {
      AppGet.toNamed(RouteNames.privacySettings);
      return;
    }
    Clipboard.setData(ClipboardData(text: target));
    AppFeedback.showSnackbar(
      title: 'Story link',
      message: 'Link copied to clipboard',
    );
  }

  Future<void> _shareCurrentStory() async {
    final StoryModel story = _controller.stories[_controller.currentIndex];
    final String shareText = (story.linkUrl ?? '').trim().isNotEmpty
        ? (story.linkLabel ?? '').trim().isNotEmpty
              ? '${story.linkLabel}: ${story.linkUrl}'
              : story.linkUrl!
        : story.text?.trim().isNotEmpty == true
        ? story.text!.trim()
        : 'Story shared from OptiZenqor';
    await Clipboard.setData(ClipboardData(text: shareText));
    AppFeedback.showSnackbar(
      title: 'Story',
      message:
          'Story share text copied. You can repost it to other chats or shorts.',
    );
  }

  String _timeLabelFor(StoryModel story) {
    final DateTime? createdAt = story.createdAt;
    if (createdAt == null) {
      return 'Now';
    }

    final Duration diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) {
      return 'Just now';
    }
    if (diff.inHours < 1) {
      return '${diff.inMinutes} min';
    }
    if (diff.inDays < 1) {
      return '${diff.inHours} h';
    }
    return '${diff.inDays} d';
  }
}
