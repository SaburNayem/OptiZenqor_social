import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app_route/route_names.dart';
import '../../../core/common_widget/inline_video_player.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/data/models/story_model.dart';
import '../../../core/functions/app_feedback.dart';
import '../../../core/navigation/app_get.dart';
import '../controller/story_preview_controller.dart';
import '../model/story_preview_model.dart';

class StoryPreviewScreen extends StatefulWidget {
  const StoryPreviewScreen({
    required this.preview,
    this.userId = '',
    super.key,
  });

  final StoryPreviewModel preview;
  final String userId;

  @override
  State<StoryPreviewScreen> createState() => _StoryPreviewScreenState();
}

class _StoryPreviewScreenState extends State<StoryPreviewScreen> {
  static const double _minCanvasMediaScale = 0.35;
  static const double _maxCanvasMediaScale = 5.0;
  static const double _minTextScale = 0.7;
  static const double _maxTextScale = 3.2;

  late final StoryPreviewController _controller;
  late final List<StoryMediaTransform> _mediaTransforms;

  bool _isSharing = false;
  Offset _textOffset = Offset.zero;
  double _textScale = 1;
  Offset _textOffsetAtStart = Offset.zero;
  double _textScaleAtStart = 1;
  Offset _textFocalPointAtStart = Offset.zero;

  final Map<int, StoryMediaTransform> _mediaTransformsAtStart =
      <int, StoryMediaTransform>{};
  final Map<int, Offset> _mediaFocalPointsAtStart = <int, Offset>{};

  List<String> get _mediaPaths => widget.preview.resolvedMediaPaths;

  @override
  void initState() {
    super.initState();
    _controller = StoryPreviewController(widget.preview);
    _mediaTransforms = _createInitialMediaTransforms();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSharing,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop || _isSharing) {
          return;
        }
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF101010),
        resizeToAvoidBottomInset: false,
        body: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, _) {
            return Stack(
              children: <Widget>[
                Positioned.fill(child: _buildFacebookPreviewScreen()),
                if (_controller.isEditingText)
                  Positioned.fill(child: _buildTextEditingOverlay()),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFacebookPreviewScreen() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            const Color(0xFF2E2E2E),
            const Color(0xFF3A3A3A),
            const Color(0xFF141414),
          ],
        ),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool compact = constraints.maxWidth < 380;

          return Stack(
            children: <Widget>[
              Positioned.fill(child: _buildFullScreenPreviewCanvas()),
              Positioned(
                left: 18,
                top: 14,
                right: compact ? 116 : 138,
                child: SafeArea(
                  bottom: false,
                  child: _buildTopBar(),
                ),
              ),
              Positioned(
                right: 18,
                top: 110,
                bottom: 96,
                width: compact ? 96 : 118,
                child: SafeArea(
                  left: false,
                  bottom: false,
                  child: _buildRightTools(),
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: SafeArea(
                  top: false,
                  child: _buildBottomBar(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar() {
    final bool hasMusic = _controller.selectedMusic.trim().isNotEmpty;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          onPressed: _handleBack,
          icon: const Icon(Icons.close_rounded, color: AppColors.white, size: 30),
          splashRadius: 24,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () {
              _finishTextEditing();
              _showMusicPicker();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.black.withValues(alpha: 0.38),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.music_note_rounded,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          hasMusic ? _controller.selectedMusic : 'Add music',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          hasMusic
                              ? 'Tap to change soundtrack'
                              : 'Discover suggestions',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.white.withValues(alpha: 0.82),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFullScreenPreviewCanvas() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Size canvasSize = constraints.biggest;

        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Positioned.fill(child: _buildCanvasBackground()),
            Positioned.fill(child: _buildInteractiveMediaCanvas(canvasSize)),
            Positioned.fill(child: _buildCanvasOverlayGradient()),
            Positioned.fill(child: _buildInteractiveTextLayer(canvasSize)),
          ],
        );
      },
    );
  }

  Widget _buildCanvasBackground() {
    if (_mediaPaths.isNotEmpty && !_looksLikeVideo(_mediaPaths.first)) {
      return Stack(
        fit: StackFit.expand,
        children: <Widget>[
          _buildMediaItem(
            _mediaPaths.first,
            targetWidth: MediaQuery.sizeOf(context).width,
            targetHeight: MediaQuery.sizeOf(context).height,
            fit: BoxFit.cover,
          ),
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

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _previewBackgroundColors,
        ),
      ),
    );
  }

  Widget _buildCanvasOverlayGradient() {
    switch (_controller.selectedEffect.toLowerCase()) {
      case 'glow':
        return IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.1, -0.55),
                radius: 1.15,
                colors: <Color>[
                  Colors.white.withValues(alpha: 0.14),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      case 'film':
        return IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFB98D57).withValues(alpha: 0.09),
            ),
          ),
        );
      case 'dream':
        return IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  const Color(0xFFDFB6FF).withValues(alpha: 0.10),
                  const Color(0xFFAEE4FF).withValues(alpha: 0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      case 'neon':
        return IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF18D9F2).withValues(alpha: 0.24),
                width: 2,
              ),
            ),
          ),
        );
      case 'clean':
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildInteractiveMediaCanvas(Size canvasSize) {
    if (_mediaPaths.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            'Choose a photo or video first.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.85),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    if (_mediaPaths.length == 1 && _looksLikeVideo(_mediaPaths.first)) {
      return _buildSingleVideoCanvas();
    }

    final List<int> sortedIndices = _sortedMediaIndices;

    return Stack(
      children: sortedIndices.map((int index) {
        return Positioned.fill(
          child: _buildMoveableMediaItem(
            index: index,
            path: _mediaPaths[index],
            canvasSize: canvasSize,
          ),
        );
      }).toList(growable: false),
    );
  }

  Widget _buildSingleVideoCanvas() {
    return ColoredBox(
      color: AppColors.black,
      child: InlineVideoPlayer(
        filePath: widget.preview.isLocalFile ? _mediaPaths.first : null,
        networkUrl: widget.preview.isLocalFile ? null : _mediaPaths.first,
        autoPlay: true,
      ),
    );
  }

  bool _looksLikeVideo(String path) {
    final String normalized = path.trim().toLowerCase();
    return normalized.endsWith('.mp4') ||
        normalized.endsWith('.mov') ||
        normalized.endsWith('.m4v') ||
        normalized.endsWith('.webm');
  }

  Widget _buildMoveableMediaItem({
    required int index,
    required String path,
    required Size canvasSize,
  }) {
    final StoryMediaTransform transform = _mediaTransforms[index];
    final bool singlePhoto = _mediaPaths.length == 1 && !_looksLikeVideo(path);
    final double itemWidth = singlePhoto
        ? canvasSize.width
        : canvasSize.width * transform.widthFactor;
    final double itemHeight = singlePhoto
        ? canvasSize.height
        : canvasSize.height * transform.heightFactor;

    return Center(
      child: Transform.translate(
        offset: Offset(transform.offsetDx, transform.offsetDy),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _bringMediaToFront(index),
          onScaleStart: (ScaleStartDetails details) {
            _mediaTransformsAtStart[index] = _mediaTransforms[index];
            _mediaFocalPointsAtStart[index] = details.focalPoint;
            _bringMediaToFront(index);
          },
          onScaleUpdate: (ScaleUpdateDetails details) {
            _updateMediaTransform(index, details, canvasSize);
          },
          child: Transform.scale(
            scale: transform.scale,
            child: SizedBox(
              width: itemWidth,
              height: itemHeight,
              child: RepaintBoundary(
                child: ClipRect(
                  child: _buildMediaItem(
                    path,
                    targetWidth: itemWidth,
                    targetHeight: itemHeight,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<int> get _sortedMediaIndices {
    final List<int> indices = List<int>.generate(
      _mediaTransforms.length,
      (int index) => index,
      growable: false,
    );

    indices.sort((int a, int b) {
      return _mediaTransforms[a].zIndex.compareTo(_mediaTransforms[b].zIndex);
    });

    return indices;
  }

  List<StoryMediaTransform> _createInitialMediaTransforms() {
    if (_mediaPaths.isEmpty) {
      return <StoryMediaTransform>[];
    }

    if (_mediaPaths.length == 1) {
      return <StoryMediaTransform>[
        const StoryMediaTransform(
          offsetDx: 0,
          offsetDy: 0,
          scale: 1,
          zIndex: 0,
          widthFactor: 1,
          heightFactor: 1,
          borderRadius: 0,
        ),
      ];
    }

    final int count = _mediaPaths.length;

    return List<StoryMediaTransform>.generate(count, (int index) {
      final int columnCount = math.min(3, math.max(1, math.sqrt(count).ceil()));
      final int row = index ~/ columnCount;
      final int column = index % columnCount;
      final int rowCount = (count / columnCount).ceil();
      final double widthFactor = count <= 2
          ? 0.72
          : count <= 4
          ? 0.48
          : count <= 6
          ? 0.38
          : 0.32;
      final double heightFactor = count <= 2
          ? 0.34
          : count <= 4
          ? 0.26
          : count <= 6
          ? 0.22
          : 0.18;
      final double spacingX = 118;
      final double spacingY = 150;
      final double offsetDx = (column - (columnCount - 1) / 2) * spacingX;
      final double offsetDy = (row - (rowCount - 1) / 2) * spacingY;

      return StoryMediaTransform(
        offsetDx: offsetDx,
        offsetDy: offsetDy,
        scale: 1,
        zIndex: index,
        widthFactor: widthFactor,
        heightFactor: heightFactor,
        borderRadius: 0,
      );
    }, growable: false);
  }

  void _bringMediaToFront(int index) {
    final int maxZ = _mediaTransforms.fold<int>(
      0,
      (int current, StoryMediaTransform item) => math.max(current, item.zIndex),
    );

    setState(() {
      _mediaTransforms[index] = _mediaTransforms[index].copyWith(zIndex: maxZ + 1);
    });
  }

  void _updateMediaTransform(
    int index,
    ScaleUpdateDetails details,
    Size canvasSize,
  ) {
    final StoryMediaTransform startTransform =
        _mediaTransformsAtStart[index] ?? _mediaTransforms[index];
    final Offset startFocalPoint =
        _mediaFocalPointsAtStart[index] ?? details.focalPoint;
    final Offset delta = details.focalPoint - startFocalPoint;
    final double nextScale = (startTransform.scale * details.scale)
        .clamp(_minCanvasMediaScale, _maxCanvasMediaScale)
        .toDouble();
    final int currentZ = _mediaTransforms[index].zIndex;
    final StoryMediaTransform nextTransform = _clampMediaTransform(
      startTransform.copyWith(
        offsetDx: startTransform.offsetDx + delta.dx,
        offsetDy: startTransform.offsetDy + delta.dy,
        scale: nextScale,
        zIndex: currentZ,
      ),
      canvasSize,
    );

    setState(() {
      _mediaTransforms[index] = nextTransform;
    });
  }

  StoryMediaTransform _clampMediaTransform(
    StoryMediaTransform transform,
    Size canvasSize,
  ) {
    final bool singleMedia = _mediaPaths.length <= 1;
    final double baseWidth = singleMedia
        ? canvasSize.width
        : canvasSize.width * transform.widthFactor;
    final double baseHeight = singleMedia
        ? canvasSize.height
        : canvasSize.height * transform.heightFactor;
    final double scaledWidth = baseWidth * transform.scale;
    final double scaledHeight = baseHeight * transform.scale;

    if (singleMedia) {
      final double overflowX = math.max(0, (scaledWidth - canvasSize.width) / 2);
      final double overflowY = math.max(0, (scaledHeight - canvasSize.height) / 2);
      final double maxX = math.max(overflowX, canvasSize.width * 0.22);
      final double maxY = math.max(overflowY, canvasSize.height * 0.22);

      return transform.copyWith(
        offsetDx: transform.offsetDx.clamp(-maxX, maxX).toDouble(),
        offsetDy: transform.offsetDy.clamp(-maxY, maxY).toDouble(),
      );
    }

    final double maxX = canvasSize.width / 2 + scaledWidth * 0.32;
    final double maxY = canvasSize.height / 2 + scaledHeight * 0.32;

    return transform.copyWith(
      offsetDx: transform.offsetDx.clamp(-maxX, maxX).toDouble(),
      offsetDy: transform.offsetDy.clamp(-maxY, maxY).toDouble(),
    );
  }

  Widget _buildMediaItem(
    String path, {
    double? targetWidth,
    double? targetHeight,
    BoxFit fit = BoxFit.contain,
  }) {
    if (_looksLikeVideo(path)) {
      return ColoredBox(
        color: AppColors.black,
        child: _mediaPaths.length == 1
            ? InlineVideoPlayer(
                filePath: widget.preview.isLocalFile ? path : null,
                networkUrl: widget.preview.isLocalFile ? null : path,
                autoPlay: true,
              )
            : const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.videocam_rounded, color: AppColors.white, size: 42),
                    SizedBox(height: 8),
                    Text(
                      'Video',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
      );
    }

    final int? cacheWidth = _resolveCacheDimension(targetWidth);
    final int? cacheHeight = _resolveCacheDimension(targetHeight);

    if (widget.preview.isLocalFile) {
      return Image.file(
        File(path),
        fit: fit,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
        filterQuality: FilterQuality.low,
        errorBuilder: (_, __, ___) => const ColoredBox(
          color: AppColors.black,
          child: Center(
            child: Icon(Icons.broken_image_outlined, color: AppColors.white),
          ),
        ),
      );
    }

    return Image.network(
      path,
      fit: fit,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      filterQuality: FilterQuality.low,
      errorBuilder: (_, __, ___) => const ColoredBox(
        color: AppColors.black,
        child: Center(
          child: Icon(Icons.broken_image_outlined, color: AppColors.white),
        ),
      ),
    );
  }

  int? _resolveCacheDimension(double? logicalSize) {
    if (logicalSize == null || logicalSize <= 0) {
      return null;
    }

    final double devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final double scaledSize = logicalSize * devicePixelRatio;
    return scaledSize.clamp(256, 1600).round();
  }

  Widget _buildInteractiveTextLayer(Size canvasSize) {
    final bool hasOverlayContent =
        _controller.hasText ||
        _controller.hasMention ||
        _controller.hasLink ||
        _controller.hasSticker;

    if (!hasOverlayContent || _controller.isEditingText) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Transform.translate(
        offset: _textOffset,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPress: _controller.hasText ? _openCanvasTextEditor : null,
          onScaleStart: (ScaleStartDetails details) {
            _textOffsetAtStart = _textOffset;
            _textScaleAtStart = _textScale;
            _textFocalPointAtStart = details.focalPoint;
          },
          onScaleUpdate: (ScaleUpdateDetails details) {
            final double nextScale = (_textScaleAtStart * details.scale)
                .clamp(_minTextScale, _maxTextScale)
                .toDouble();
            final Offset nextOffset =
                _textOffsetAtStart + (details.focalPoint - _textFocalPointAtStart);

            setState(() {
              _textScale = nextScale;
              _textOffset = _clampTextOffset(nextOffset, canvasSize, nextScale);
            });
          },
          child: Transform.scale(
            alignment: Alignment.center,
            scale: _textScale,
            child: _buildTextPreviewContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildTextPreviewContent() {
    final List<Widget> chips = <Widget>[
      if (_controller.hasSticker)
        _buildOverlayChip(
          icon: Icons.sell_outlined,
          label: _controller.selectedSticker,
        ),
      if (_controller.hasMention)
        _buildOverlayChip(
          icon: Icons.alternate_email_rounded,
          label: '@${_controller.mentionUsername}',
        ),
    ];

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 110,
        maxWidth: 260,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.black.withValues(
            alpha: _controller.hasText || chips.isNotEmpty ? 0.12 : 0,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(_controller.hasText || chips.isNotEmpty ? 8 : 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (chips.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: chips,
                ),
              if (chips.isNotEmpty && _controller.hasText)
                const SizedBox(height: 12),
              if (_controller.hasText)
                Text(
                  _controller.currentText,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: _controller.selectedTextColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.08,
                    shadows: <Shadow>[
                      Shadow(
                        color: AppColors.black.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextEditingOverlay() {
    final double keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.isEditingText) {
        return;
      }

      if (!_controller.textFocusNode.hasFocus) {
        _controller.textFocusNode.requestFocus();
      }

      final String text = _controller.textController.text;
      final int offset = text.length;
      final TextSelection selection = _controller.textController.selection;

      if (!selection.isValid || selection.baseOffset > text.length) {
        _controller.textController.selection = TextSelection.collapsed(
          offset: offset,
        );
      }
    });

    return ColoredBox(
      color: AppColors.black.withValues(alpha: 0.82),
      child: SafeArea(
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: keyboardInset > 0 ? keyboardInset + 20 : 28,
          ),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  TextButton(
                    onPressed: _finishTextEditing,
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _controller.cycleTextColor,
                    icon: const Icon(
                      Icons.palette_outlined,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    reverse: true,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.manual,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: TextField(
                        controller: _controller.textController,
                        focusNode: _controller.textFocusNode,
                        onChanged: (_) => _controller.onTextChanged(),
                        autofocus: true,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        textAlign: TextAlign.center,
                        cursorColor: _controller.selectedTextColor,
                        style: TextStyle(
                          color: _controller.selectedTextColor,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          height: 1.08,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Write text',
                          hintStyle: TextStyle(
                            color: AppColors.white70,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: StoryPreviewController.textColors.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (BuildContext context, int index) {
                    final Color color = StoryPreviewController.textColors[index];
                    final bool isSelected = color == _controller.selectedTextColor;

                    return GestureDetector(
                      onTap: () => _controller.setTextColor(color),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.white
                                : AppColors.white.withValues(alpha: 0.24),
                            width: isSelected ? 3 : 1.5,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRightTools() {
    final List<_StoryToolConfig> tools = <_StoryToolConfig>[
      _StoryToolConfig(
        label: 'Stickers',
        icon: Icons.sticky_note_2_outlined,
        onTap: () {
          _finishTextEditing();
          _showStickerPicker();
        },
      ),
      _StoryToolConfig(
        label: 'Text',
        textIcon: 'Aa',
        onTap: _openCanvasTextEditor,
      ),
      _StoryToolConfig(
        label: 'Music',
        icon: Icons.music_note_rounded,
        onTap: () {
          _finishTextEditing();
          _showMusicPicker();
        },
      ),
      _StoryToolConfig(
        label: 'Effects',
        icon: Icons.auto_awesome_rounded,
        onTap: () {
          _finishTextEditing();
          _showEffectPicker();
        },
      ),
      _StoryToolConfig(
        label: 'Mention',
        icon: Icons.alternate_email_rounded,
        onTap: () {
          _finishTextEditing();
          _showMentionDialog();
        },
      ),
      _StoryToolConfig(
        label: 'Link',
        icon: Icons.link_rounded,
        onTap: () {
          _finishTextEditing();
          _showLinkDialog();
        },
      ),
    ];

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List<Widget>.generate(tools.length * 2 - 1, (int index) {
          if (index.isOdd) {
            return const SizedBox(height: 18);
          }

          final _StoryToolConfig tool = tools[index ~/ 2];
          return _buildToolButton(tool);
        }),
      ),
    );
  }

  Widget _buildToolButton(_StoryToolConfig tool) {
    return InkWell(
      onTap: tool.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                tool.label,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 30,
              child: Center(
                child: tool.textIcon != null
                    ? Text(
                        tool.textIcon!,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : Icon(
                        tool.icon,
                        color: AppColors.white,
                        size: 26,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Row(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            _finishTextEditing();
            _showPrivacyPicker();
          },
          child: Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.92),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.settings_outlined,
              color: AppColors.primary,
              size: 24,
            ),
          ),
        ),
        const Spacer(),
        SizedBox(
          width: 136,
          height: 54,
          child: FilledButton(
            onPressed: _isSharing ? null : _sharePreview,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isSharing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : const Text(
                    'Share',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverlayChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: AppColors.white, size: 15),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Color> get _previewBackgroundColors {
    switch (_controller.selectedEffect.toLowerCase()) {
      case 'film':
        return const <Color>[Color(0xFF4A3930), Color(0xFF1C1612)];
      case 'dream':
        return const <Color>[Color(0xFF7155B8), Color(0xFF284A83)];
      case 'neon':
        return const <Color>[Color(0xFF022C3A), Color(0xFF111827)];
      case 'glow':
        return const <Color>[Color(0xFF6A6A6A), Color(0xFF202020)];
      case 'clean':
      default:
        return const <Color>[Color(0xFF4A4A4A), Color(0xFF232323)];
    }
  }

  Offset _clampTextOffset(Offset offset, Size viewport, double scale) {
    final double estimatedWidth = math.min(viewport.width * 0.84, 220 * scale);
    final double estimatedHeight = math.min(viewport.height * 0.42, 110 * scale);
    final double maxX = math.max(0, (viewport.width - estimatedWidth) / 2 - 8);
    final double maxY = math.max(0, (viewport.height - estimatedHeight) / 2 - 24);

    return Offset(
      offset.dx.clamp(-maxX, maxX).toDouble(),
      offset.dy.clamp(-maxY, maxY).toDouble(),
    );
  }

  void _openCanvasTextEditor() {
    _controller.startTextEditing();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _controller.textFocusNode.requestFocus();

      final int offset = _controller.textController.text.length;
      _controller.textController.selection = TextSelection.collapsed(
        offset: offset,
      );
    });
  }

  void _finishTextEditing() {
    _controller.textFocusNode.unfocus();
    _controller.stopTextEditing();
  }

  void _handleBack() {
    if (_controller.isEditingText) {
      _finishTextEditing();
      return;
    }

    Navigator.of(context).maybePop();
  }

  Future<void> _showStickerPicker() async {
    final String? next = await _showSimplePicker(
      title: 'Choose sticker',
      options: StoryPreviewController.stickerOptions,
      selected: _controller.selectedSticker,
      icon: Icons.sticky_note_2_outlined,
    );

    if (next != null) {
      _controller.setSticker(next);
    }
  }

  Future<void> _showMusicPicker() async {
    final String? next = await _showSimplePicker(
      title: 'Choose music',
      options: StoryPreviewController.musicOptions,
      selected: _controller.selectedMusic,
      icon: Icons.music_note_rounded,
    );

    if (next != null) {
      _controller.setMusic(next);
    }
  }

  Future<void> _showEffectPicker() async {
    final String? next = await _showSimplePicker(
      title: 'Choose effect',
      options: StoryPreviewController.effectOptions,
      selected: _controller.selectedEffect,
      icon: Icons.auto_awesome_rounded,
    );

    if (next != null) {
      _controller.setEffect(next);
    }
  }

  Future<void> _showPrivacyPicker() async {
    final String? next = await _showSimplePicker(
      title: 'Story privacy',
      options: StoryPreviewController.privacyOptions,
      selected: _controller.selectedPrivacy,
      icon: Icons.privacy_tip_outlined,
    );

    if (next != null) {
      _controller.setPrivacy(next);
    }
  }

  Future<String?> _showSimplePicker({
    required String title,
    required List<String> options,
    required String selected,
    required IconData icon,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              ListTile(
                title: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              ...options.map((String item) {
                return ListTile(
                  leading: Icon(icon),
                  title: Text(item),
                  trailing: item == selected
                      ? const Icon(
                          Icons.check_rounded,
                          color: AppColors.primary,
                        )
                      : null,
                  onTap: () => Navigator.of(context).pop(item),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showMentionDialog() async {
    final TextEditingController mentionController = TextEditingController(
      text: _controller.mentionUsername,
    );

    final String? mention = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add mention'),
          content: TextField(
            controller: mentionController,
            decoration: const InputDecoration(
              hintText: 'username',
              prefixText: '@',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(mentionController.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (mention != null) {
      _controller.setMention(mention);
    }
  }

  Future<void> _showLinkDialog() async {
    final TextEditingController labelController = TextEditingController(
      text: _controller.linkLabel,
    );
    final TextEditingController urlController = TextEditingController(
      text: _controller.linkUrl.isNotEmpty
          ? _controller.linkUrl
          : RouteNames.privacySettings,
    );

    final List<String>? result = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add link'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: labelController,
                decoration: const InputDecoration(
                  labelText: 'Link label',
                  hintText: 'Privacy settings',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'Link target',
                  hintText: '/settings/privacy',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(
                context,
              ).pop(<String>[labelController.text, urlController.text]),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == null || result.length < 2) {
      return;
    }

    _controller.setLink(label: result[0], url: result[1]);
  }

  Future<void> _sharePreview() async {
    setState(() => _isSharing = true);

    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (!mounted) {
      return;
    }

    setState(() => _isSharing = false);

    final List<String> mediaItems = List<String>.from(_mediaPaths, growable: false);

    final StoryModel story = StoryModel(
      id: 'local_story_${DateTime.now().microsecondsSinceEpoch}',
      userId: widget.userId,
      media: mediaItems.isEmpty ? '' : mediaItems.first,
      mediaItems: mediaItems,
      isLocalFile: widget.preview.isLocalFile,
      text: _controller.hasText ? _controller.currentText : null,
      music: _controller.selectedMusic,
      backgroundColors: _previewBackgroundColors
          .map((Color color) => color.toARGB32())
          .toList(growable: false),
      textColorValue: _controller.selectedTextColor.toARGB32(),
      sticker: _controller.hasSticker ? _controller.selectedSticker : null,
      effectName: _controller.selectedEffect,
      mentionUsername: _controller.hasMention
          ? _controller.mentionUsername
          : null,
      linkLabel: _controller.hasLink ? _controller.linkLabel : null,
      linkUrl: _controller.hasLink ? _controller.linkUrl : null,
      privacy: _controller.selectedPrivacy,
      collageLayout: _controller.selectedCollageLayout,
      textOffsetDx: _textOffset.dx,
      textOffsetDy: _textOffset.dy,
      textScale: _textScale,
      mediaTransforms: List<StoryMediaTransform>.generate(
        _mediaTransforms.length,
        (int index) => _mediaTransforms[index],
        growable: false,
      ),
    );

    Navigator.of(context).pop(story);
  }

  Future<void> _shareStoryLink() async {
    final String shareText = _controller.hasLink
        ? (_controller.linkLabel.isNotEmpty
              ? '${_controller.linkLabel}: ${_controller.linkUrl}'
              : _controller.linkUrl)
        : 'Story ready to share';

    await Clipboard.setData(ClipboardData(text: shareText));

    AppFeedback.showSnackbar(
      title: 'Story',
      message: 'Story share text copied',
    );
  }

  void _openStoryLink() {
    final String target = _controller.linkUrl.trim();

    if (target.isEmpty) {
      _shareStoryLink();
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
      message: 'Link target copied to clipboard',
    );
  }
}

class _StoryToolConfig {
  const _StoryToolConfig({
    required this.label,
    required this.onTap,
    this.icon,
    this.textIcon,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final String? textIcon;
}
