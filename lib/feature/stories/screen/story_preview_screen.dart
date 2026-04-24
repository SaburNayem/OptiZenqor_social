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
                children: [
                  Positioned.fill(child: _buildMedia()),
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
                  Positioned.fill(
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: _handleBack,
                                  style: IconButton.styleFrom(
                                    backgroundColor: AppColors.black.withValues(
                                      alpha: 0.28,
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: AppColors.white,
                                  ),
                                ),
                                const Spacer(),
                                OutlinedButton.icon(
                                  onPressed: _shareStoryLink,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.white,
                                    side: BorderSide(
                                      color: AppColors.white.withValues(
                                        alpha: 0.24,
                                      ),
                                    ),
                                  ),
                                  icon: const Icon(Icons.ios_share_rounded),
                                  label: const Text('Share'),
                                ),
                                const SizedBox(width: 10),
                                FilledButton(
                                  onPressed: _isSharing ? null : _sharePreview,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.splashBackground,
                                    foregroundColor: AppColors.white,
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
                                      : const Text('Post'),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildTextOverlay(),
                                      const SizedBox(height: 12),
                                      _buildOverlayChip(
                                        icon: Icons.shield_outlined,
                                        label: _controller.selectedPrivacy,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _buildRightTools(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMedia() {
    if (widget.preview.isVideo) {
      return Container(
        color: AppColors.black,
        alignment: Alignment.center,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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

    if (widget.preview.isLocalFile) {
      return Image.file(File(widget.preview.mediaPath), fit: BoxFit.cover);
    }

    return Image.network(widget.preview.mediaPath, fit: BoxFit.cover);
  }

  Widget _buildTextOverlay() {
    return GestureDetector(
      onTap: () {
        _controller.startTextEditing();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _controller.textFocusNode.requestFocus();
          }
        });
      },
      child: Container(
        constraints: const BoxConstraints(minHeight: 160),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.white.withValues(alpha: 0.24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildOverlayChip(
                  icon: Icons.music_note_rounded,
                  label: _controller.selectedMusic,
                ),
                _buildOverlayChip(
                  icon: Icons.auto_awesome_rounded,
                  label: _controller.selectedEffect,
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
              ],
            ),
            const SizedBox(height: 14),
            if (_controller.hasText)
              Text(
                _controller.currentText,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: _controller.selectedTextColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              )
            else
              const Text(
                'Add text',
                style: TextStyle(
                  color: AppColors.white70,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                ),
              ),
            Offstage(
              offstage: true,
              child: TextField(
                controller: _controller.textController,
                focusNode: _controller.textFocusNode,
                onTap: _controller.startTextEditing,
                onChanged: (_) => _controller.onTextChanged(),
                maxLines: 5,
                minLines: 1,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: _controller.selectedTextColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightTools() {
    return SizedBox(
      width: 76,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildToolButton(
              icon: Icons.text_fields_rounded,
              label: 'Text',
              onTap: () {
                _controller.startTextEditing();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _controller.textFocusNode.requestFocus();
                  }
                });
              },
            ),
            const SizedBox(height: 12),
            _buildToolButton(
              icon: Icons.palette_outlined,
              label: 'Color',
              onTap: _showTextColorPicker,
            ),
            const SizedBox(height: 12),
            _buildToolButton(
              icon: Icons.music_note_rounded,
              label: 'Music',
              onTap: _showMusicPicker,
            ),
            const SizedBox(height: 12),
            _buildToolButton(
              icon: Icons.auto_awesome_rounded,
              label: 'Effect',
              onTap: _showEffectPicker,
            ),
            const SizedBox(height: 12),
            _buildToolButton(
              icon: Icons.alternate_email_rounded,
              label: 'Mention',
              onTap: _showMentionDialog,
            ),
            const SizedBox(height: 12),
            _buildToolButton(
              icon: Icons.link_rounded,
              label: 'Link',
              onTap: _showLinkDialog,
            ),
            const SizedBox(height: 12),
            _buildToolButton(
              icon: Icons.privacy_tip_outlined,
              label: 'Privacy',
              onTap: _showPrivacyPicker,
            ),
          ],
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
        children: [
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
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.white.withValues(alpha: 0.16)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.white, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
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
            children: [
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
          actions: [
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
            children: [
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
          actions: [
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

  Future<void> _showTextColorPicker() async {
    HSVColor tempColor = HSVColor.fromColor(_controller.selectedTextColor);
    final Color? next = await showDialog<Color>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.transparent,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setPickerState) {
              void updateColor(Offset localPosition, Size size) {
                final double dx = localPosition.dx.clamp(0, size.width);
                final double dy = localPosition.dy.clamp(0, size.height);
                setPickerState(() {
                  tempColor = HSVColor.fromAHSV(
                    1,
                    (dx / size.width) * 360,
                    1,
                    1 - (dy / size.height),
                  );
                });
              }

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.black.withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                            const double pickerHeight = 180;
                            final double pickerWidth = constraints.maxWidth;
                            final double knobLeft =
                                (tempColor.hue / 360) * pickerWidth;
                            final double knobTop =
                                (1 - tempColor.value) * pickerHeight;

                            return GestureDetector(
                              onTapDown: (details) => updateColor(
                                details.localPosition,
                                Size(pickerWidth, pickerHeight),
                              ),
                              onPanDown: (details) => updateColor(
                                details.localPosition,
                                Size(pickerWidth, pickerHeight),
                              ),
                              onPanUpdate: (details) => updateColor(
                                details.localPosition,
                                Size(pickerWidth, pickerHeight),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: SizedBox(
                                  height: pickerHeight,
                                  width: double.infinity,
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: <Color>[
                                              AppColors.hexFFFF0000,
                                              AppColors.hexFFFFFF00,
                                              AppColors.hexFF00FF00,
                                              AppColors.hexFF00FFFF,
                                              AppColors.hexFF0000FF,
                                              AppColors.hexFFFF00FF,
                                              AppColors.hexFFFF0000,
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: <Color>[
                                              AppColors.transparent,
                                              AppColors.black,
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left:
                                            knobLeft.clamp(
                                              10,
                                              pickerWidth - 10,
                                            ) -
                                            10,
                                        top:
                                            knobTop.clamp(
                                              10,
                                              pickerHeight - 10,
                                            ) -
                                            10,
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: tempColor.toColor(),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppColors.white,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: tempColor.toColor(),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 2),
                      ),
                    ),
                    const SizedBox(height: 14),
                    FilledButton(
                      onPressed: () =>
                          Navigator.of(context).pop(tempColor.toColor()),
                      child: const Text('Done'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    if (next == null) {
      return;
    }
    _controller.setTextColor(next);
  }

  Future<void> _sharePreview() async {
    setState(() => _isSharing = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) {
      return;
    }
    setState(() => _isSharing = false);
    final StoryModel story = StoryModel(
      id: 'local_story_${DateTime.now().microsecondsSinceEpoch}',
      userId: widget.userId,
      media: widget.preview.mediaPath,
      isLocalFile: widget.preview.isLocalFile,
      text: _controller.hasText ? _controller.currentText : null,
      music: _controller.selectedMusic,
      textColorValue: _controller.selectedTextColor.toARGB32(),
      sticker: _controller.selectedSticker,
      effectName: _controller.selectedEffect,
      mentionUsername: _controller.hasMention
          ? _controller.mentionUsername
          : null,
      linkLabel: _controller.hasLink ? _controller.linkLabel : null,
      linkUrl: _controller.hasLink ? _controller.linkUrl : null,
      privacy: _controller.selectedPrivacy,
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
