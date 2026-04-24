import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app_route/route_names.dart';
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
  late final StoryPreviewController _controller;
  bool _isSharing = false;
  Offset _mediaOffset = Offset.zero;
  double _mediaScale = 1;
  Offset _mediaOffsetAtStart = Offset.zero;
  double _mediaScaleAtStart = 1;
  Offset _textOffset = const Offset(0, 0);
  double _textScale = 1;
  Offset _textOffsetAtStart = const Offset(0, 0);
  double _textScaleAtStart = 1;

  List<String> get _mediaPaths => widget.preview.resolvedMediaPaths;
  bool get _hasMultipleMedia => widget.preview.hasMultipleMedia;

  @override
  void initState() {
    super.initState();
    _controller = StoryPreviewController(widget.preview);
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
        backgroundColor: AppColors.black,
        body: SizedBox.expand(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, _) {
              return Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (_controller.isEditingText) {
                          _finishTextEditing();
                          return;
                        }
                        _openCanvasTextEditor();
                      },
                      onScaleStart: _hasMultipleMedia || widget.preview.isVideo
                          ? null
                          : (ScaleStartDetails details) {
                              _mediaOffsetAtStart = _mediaOffset;
                              _mediaScaleAtStart = _mediaScale;
                            },
                      onScaleUpdate: _hasMultipleMedia || widget.preview.isVideo
                          ? null
                          : (ScaleUpdateDetails details) {
                              setState(() {
                                _mediaScale = (_mediaScaleAtStart * details.scale)
                                    .clamp(0.7, 3.2);
                                _mediaOffset =
                                    _mediaOffsetAtStart + details.focalPointDelta;
                              });
                            },
                      child: _buildMediaCanvas(),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            AppColors.black.withValues(alpha: 0.28),
                            AppColors.transparent,
                            AppColors.black.withValues(alpha: 0.34),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(child: _buildEditorChrome()),
                  Positioned.fill(child: _buildInteractiveTextLayer()),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEditorChrome() {
    final double keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 14, 16, keyboardInset > 0 ? 8 : 20),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: _handleBack,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.black.withValues(alpha: 0.28),
                      ),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.white,
                      ),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: _isSharing ? null : _sharePreview,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.splashBackground,
                        foregroundColor: AppColors.white,
                        minimumSize: const Size(0, 44),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                      child: _isSharing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : const Text('Post story'),
                    ),
                  ],
                ),
                if (_controller.selectedMusic.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.topCenter,
                    child: _buildOverlayChip(
                      icon: Icons.music_note_rounded,
                      label: _controller.selectedMusic,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: constraints.maxHeight),
                      child: _buildRightTools(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMediaCanvas() {
    if (widget.preview.isVideo) {
      return Container(
        color: AppColors.black,
        alignment: Alignment.center,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.videocam_rounded, color: AppColors.white, size: 64),
            SizedBox(height: 12),
            Text(
              'Video preview coming soon',
              style: TextStyle(color: AppColors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_hasMultipleMedia) {
      return _buildCollageCanvas();
    }

    final Widget media = _buildMediaItem(_mediaPaths.first);
    return ClipRect(
      child: Transform.translate(
        offset: _mediaOffset,
        child: Transform.scale(
          alignment: Alignment.center,
          scale: _mediaScale,
          child: SizedBox.expand(child: media),
        ),
      ),
    );
  }

  Widget _buildCollageCanvas() {
    switch (_controller.selectedCollageLayout) {
      case 'mosaic':
        return _buildMosaicCollage();
      case 'stack':
        return _buildStackCollage();
      case 'grid':
      default:
        return _buildGridCollage();
    }
  }

  Widget _buildGridCollage() {
    final int count = _mediaPaths.length.clamp(1, 7);
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
            child: _buildMediaItem(_mediaPaths[index]),
          );
        },
      ),
    );
  }

  Widget _buildMosaicCollage() {
    final List<String> items = _mediaPaths.take(7).toList(growable: false);
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
                    child: _buildMediaItem(items.first),
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
                            child: _buildMediaItem(items[1]),
                          ),
                        ),
                        if (items.length > 2) const SizedBox(height: 6),
                        if (items.length > 2)
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: _buildMediaItem(items[2]),
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
                        child: _buildMediaItem(items[index + 3]),
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

  Widget _buildStackCollage() {
    final List<String> items = _mediaPaths.take(7).toList(growable: false);
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
                  child: _buildMediaItem(items[index]),
                ),
              ),
            ),
          );
        }).reversed.toList(growable: false),
      ),
    );
  }

  Widget _buildMediaItem(String path) {
    if (widget.preview.isLocalFile) {
      return Image.file(File(path), fit: BoxFit.cover);
    }
    return Image.network(path, fit: BoxFit.cover);
  }

  Widget _buildTextOverlay() {
    final List<Widget> chips = <Widget>[
      if (_hasMultipleMedia)
        _buildOverlayChip(
          icon: Icons.grid_view_rounded,
          label: '${_mediaPaths.length} photos',
        ),
      if (_controller.hasMention)
        _buildOverlayChip(
          icon: Icons.alternate_email_rounded,
          label: '@${_controller.mentionUsername}',
        ),
      if (_controller.hasLink)
        GestureDetector(
          onTap: _openStoryLink,
          child: _buildOverlayChip(
            icon: Icons.link_rounded,
            label: _controller.linkLabel.isNotEmpty
                ? _controller.linkLabel
                : _controller.linkUrl,
          ),
        ),
    ];

    return Container(
      constraints: const BoxConstraints(minWidth: 120, minHeight: 60),
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
          if (chips.isNotEmpty) const SizedBox(height: 14),
          if (_controller.hasText)
            Text(
              _controller.currentText,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: _controller.selectedTextColor,
                fontSize: 32,
                fontWeight: FontWeight.w700,
                height: 1.12,
              ),
            )
          else if (_controller.isEditingText)
            const Text(
              'Write your story',
              style: TextStyle(
                color: AppColors.white70,
                fontSize: 32,
                fontWeight: FontWeight.w700,
                height: 1.12,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInteractiveTextLayer() {
    final bool hasOverlayContent = _controller.hasText ||
        _controller.isEditingText ||
        _controller.hasMention ||
        _controller.hasLink ||
        _controller.selectedEffect.trim().isNotEmpty ||
        _controller.selectedPrivacy.trim().isNotEmpty ||
        _controller.selectedMusic.trim().isNotEmpty ||
        _hasMultipleMedia;

    if (!hasOverlayContent) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.fromLTRB(
          20,
          84,
          88,
          104 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Align(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            reverse: true,
            child: Transform.translate(
              offset: _textOffset,
              child: GestureDetector(
                behavior: HitTestBehavior.deferToChild,
                onTap: _controller.isEditingText ? null : _openCanvasTextEditor,
                onScaleStart: (ScaleStartDetails details) {
                  _textOffsetAtStart = _textOffset;
                  _textScaleAtStart = _textScale;
                },
                onScaleUpdate: (ScaleUpdateDetails details) {
                  setState(() {
                    _textScale =
                        (_textScaleAtStart * details.scale).clamp(0.7, 3.2);
                    _textOffset = _textOffsetAtStart + details.focalPointDelta;
                  });
                },
                child: Transform.scale(
                  alignment: Alignment.centerLeft,
                  scale: _textScale,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 240),
                    child: _controller.isEditingText
                          ? TextField(
                              controller: _controller.textController,
                              focusNode: _controller.textFocusNode,
                              onChanged: (_) => _controller.onTextChanged(),
                              onTapOutside: (_) => _finishTextEditing(),
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              textAlign: TextAlign.left,
                              cursorColor: _controller.selectedTextColor,
                              style: TextStyle(
                                color: _controller.selectedTextColor,
                                fontSize: 32,
                              fontWeight: FontWeight.w700,
                              height: 1.12,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Write your story',
                              hintStyle: TextStyle(
                                color: AppColors.white70,
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                isCollapsed: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            )
                        : _buildTextOverlay(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openCanvasTextEditor() {
    _controller.startTextEditing();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.textFocusNode.requestFocus();
        _controller.textController.selection = TextSelection.collapsed(
          offset: _controller.textController.text.length,
        );
      }
    });
  }

  void _finishTextEditing() {
    _controller.stopTextEditing();
  }

  Widget _buildRightTools() {
    final List<_StoryToolConfig> tools = <_StoryToolConfig>[
      _StoryToolConfig(
        icon: Icons.text_fields_rounded,
        label: 'Text',
        onTap: _openCanvasTextEditor,
      ),
      _StoryToolConfig(
        icon: Icons.palette_outlined,
        label: 'Color',
        onTap: _controller.cycleTextColor,
      ),
      _StoryToolConfig(
        icon: Icons.music_note_rounded,
        label: 'Music',
        onTap: () {
          _finishTextEditing();
          _showMusicPicker();
        },
      ),
      if (_hasMultipleMedia)
        _StoryToolConfig(
          icon: Icons.grid_view_rounded,
          label: 'Layout',
          onTap: () {
            _finishTextEditing();
            _showLayoutPicker();
          },
        ),
      _StoryToolConfig(
        icon: Icons.auto_awesome_rounded,
        label: 'Effect',
        onTap: () {
          _finishTextEditing();
          _showEffectPicker();
        },
      ),
      _StoryToolConfig(
        icon: Icons.alternate_email_rounded,
        label: 'Mention',
        onTap: () {
          _finishTextEditing();
          _showMentionDialog();
        },
      ),
      _StoryToolConfig(
        icon: Icons.link_rounded,
        label: 'Link',
        onTap: () {
          _finishTextEditing();
          _showLinkDialog();
        },
      ),
      _StoryToolConfig(
        icon: Icons.privacy_tip_outlined,
        label: 'Privacy',
        onTap: () {
          _finishTextEditing();
          _showPrivacyPicker();
        },
      ),
    ];

    return SizedBox(
      width: 62,
      child: SingleChildScrollView(
        reverse: true,
        padding: const EdgeInsets.only(bottom: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List<Widget>.generate(tools.length * 2 - 1, (int index) {
            if (index.isOdd) {
              return const SizedBox(height: 10);
            }
            final _StoryToolConfig tool = tools[index ~/ 2];
            return _buildToolButton(
              icon: tool.icon,
              label: tool.label,
              onTap: tool.onTap,
            );
          }),
        ),
      ),
    );
  }

  Widget _buildOverlayChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: AppColors.white, size: 16),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 170),
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

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 58,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.white.withValues(alpha: 0.16)),
        ),
        child: Column(
          children: <Widget>[
            Icon(icon, color: AppColors.white, size: 20),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBack() {
    if (_controller.isEditingText) {
      _controller.stopTextEditing();
      return;
    }
    Navigator.of(context).maybePop();
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

  Future<void> _showLayoutPicker() async {
    final String? next = await _showSimplePicker(
      title: 'Choose collage layout',
      options: StoryPreviewController.collageLayoutOptions,
      selected: _controller.selectedCollageLayout,
      icon: Icons.grid_view_rounded,
    );
    if (next != null) {
      _controller.setCollageLayout(next);
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
                      ? const Icon(Icons.check_rounded, color: AppColors.primary)
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
              onPressed: () => Navigator.of(context).pop(<String>[
                labelController.text,
                urlController.text,
              ]),
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
    final List<String> mediaItems = _mediaPaths.take(7).toList(growable: false);
    final StoryModel story = StoryModel(
      id: 'local_story_${DateTime.now().microsecondsSinceEpoch}',
      userId: widget.userId,
      media: mediaItems.isEmpty ? '' : mediaItems.first,
      mediaItems: mediaItems,
      isLocalFile: widget.preview.isLocalFile,
      text: _controller.hasText ? _controller.currentText : null,
      music: _controller.selectedMusic,
      textColorValue: _controller.selectedTextColor.toARGB32(),
      sticker: null,
      effectName: _controller.selectedEffect,
      mentionUsername: _controller.hasMention
          ? _controller.mentionUsername
          : null,
      linkLabel: _controller.hasLink ? _controller.linkLabel : null,
      linkUrl: _controller.hasLink ? _controller.linkUrl : null,
      privacy: _controller.selectedPrivacy,
      collageLayout: _controller.selectedCollageLayout,
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
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}
