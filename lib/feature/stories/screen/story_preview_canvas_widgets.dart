// ignore_for_file: invalid_use_of_protected_member

part of 'story_preview_screen.dart';

extension _StoryPreviewCanvasWidgets on _StoryPreviewScreenState {
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
                    Icon(
                      Icons.videocam_rounded,
                      color: AppColors.white,
                      size: 42,
                    ),
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

    if (widget.preview.isLocalFile) {
      return Image.file(
        File(path),
        fit: fit,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, _, _) => const ColoredBox(
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
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, _, _) => const ColoredBox(
        color: AppColors.black,
        child: Center(
          child: Icon(Icons.broken_image_outlined, color: AppColors.white),
        ),
      ),
    );
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
                .clamp(
                  _StoryPreviewScreenState._minTextScale,
                  _StoryPreviewScreenState._maxTextScale,
                )
                .toDouble();
            final Offset nextOffset =
                _textOffsetAtStart +
                (details.focalPoint - _textFocalPointAtStart);

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
      constraints: const BoxConstraints(minWidth: 110, maxWidth: 260),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.black.withValues(
            alpha: _controller.hasText || chips.isNotEmpty ? 0.12 : 0,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(
            _controller.hasText || chips.isNotEmpty ? 8 : 0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (chips.isNotEmpty)
                Wrap(spacing: 8, runSpacing: 8, children: chips),
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
                    final Color color =
                        StoryPreviewController.textColors[index];
                    final bool isSelected =
                        color == _controller.selectedTextColor;

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
                    : Icon(tool.icon, color: AppColors.white, size: 26),
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
}
