import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/data/models/story_model.dart';
import '../../../core/functions/app_feedback.dart';
import '../controller/story_text_composer_controller.dart';
import '../model/story_text_composer_model.dart';

class StoryTextComposerScreen extends StatefulWidget {
  const StoryTextComposerScreen({
    required this.config,
    this.userId = '',
    super.key,
  });

  final StoryTextComposerModel config;
  final String userId;

  @override
  State<StoryTextComposerScreen> createState() =>
      _StoryTextComposerScreenState();
}

class _StoryTextComposerScreenState extends State<StoryTextComposerScreen> {
  late final StoryTextComposerController _controller;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _controller = StoryTextComposerController(widget.config);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.textFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      backgroundColor: AppColors.black,
      resizeToAvoidBottomInset: true,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, _) {
          final List<int> gradient =
              StoryTextComposerController.gradients[_controller.gradientIndex];
          final TextStyle composerTextStyle = _composerTextStyle();
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _focusTextInput,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Color(gradient[0]), Color(gradient[1])],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 14, 16, keyboardInset > 0 ? 12 : 24),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          _buildTopColorTool(),
                          const Spacer(),
                          FilledButton(
                            onPressed: _isSharing ? null : _shareStory,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.white,
                              foregroundColor: AppColors.primary,
                              minimumSize: const Size(0, 40),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 10,
                              ),
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
                                : const Text('Share'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildOverlayChip(
                              icon: Icons.shield_outlined,
                              label: _controller.selectedPrivacy,
                            ),
                            if (_controller.hasMention)
                              _buildOverlayChip(
                                icon: Icons.alternate_email_rounded,
                                label: '@${_controller.mentionUsername}',
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_controller.showMusic)
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.music_note_rounded,
                                  color: AppColors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _controller.selectedMusic,
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (_controller.showMusic) const SizedBox(height: 18),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  const Spacer(),
                                  Flexible(
                                    child: SingleChildScrollView(
                                      reverse: true,
                                      child: GestureDetector(
                                        onTap: _focusTextInput,
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            minHeight: 120,
                                          ),
                                          child: Center(
                                            child: _controller.hasText
                                                ? Text(
                                                    _controller.currentText,
                                                    textAlign: TextAlign.center,
                                                    style: composerTextStyle,
                                                  )
                                                : const Text(
                                                    'Share your story',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: AppColors.white70,
                                                      fontSize: 34,
                                                      fontWeight: FontWeight.w600,
                                                      height: 1.15,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 1,
                                    height: 1,
                                    child: Opacity(
                                      opacity: 0,
                                      child: TextField(
                                        controller: _controller.textController,
                                        focusNode: _controller.textFocusNode,
                                        onChanged: (_) =>
                                            _controller.onTextChanged(),
                                        maxLines: 6,
                                        minLines: 1,
                                        textAlign: TextAlign.center,
                                        style: composerTextStyle,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: SingleChildScrollView(
                                reverse: true,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildSideTool(
                                      icon: Icons.palette_outlined,
                                      onTap: _controller.cycleBackground,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildSideTool(
                                      icon: Icons.text_fields_rounded,
                                      onTap: _handleTextStyleTap,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildSideTool(
                                      icon: Icons.music_note_outlined,
                                      onTap: _showMusicPicker,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildSideTool(
                                      icon: Icons.alternate_email_rounded,
                                      onTap: _showMentionDialog,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildSideTool(
                                      icon: Icons.privacy_tip_outlined,
                                      onTap: _showPrivacyPicker,
                                    ),
                                  ],
                                ),
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
          );
        },
      ),
    );
  }

  Widget _buildSideTool({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.white.withValues(alpha: 0.22)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.white, size: 18),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildTopColorTool() {
    return InkWell(
      onTap: _showTextColorPicker,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.white.withValues(alpha: 0.24)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: _controller.selectedTextColor,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 1.4),
              ),
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
        color: AppColors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.24)),
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

  TextStyle _composerTextStyle() {
    return TextStyle(
      color: _controller.selectedTextColor,
      fontSize: 34,
      fontWeight: _controller.selectedFontWeight,
      fontStyle: _controller.selectedFontStyle,
      fontFamily: _controller.selectedFontFamily,
      letterSpacing: _controller.selectedLetterSpacing,
      height: 1.15,
    );
  }

  void _focusTextInput() {
    if (mounted) {
      FocusScope.of(context).requestFocus(_controller.textFocusNode);
    }
  }

  void _handleTextStyleTap() {
    _controller.cycleTextStyle();
    _focusTextInput();
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

  Future<void> _showMusicPicker() async {
    final String? next = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: StoryTextComposerController.musicOptions.map((
              String track,
            ) {
              return ListTile(
                leading: const Icon(Icons.music_note_rounded),
                title: Text(track),
                trailing: track == _controller.selectedMusic
                    ? const Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.of(context).pop(track),
              );
            }).toList(),
          ),
        );
      },
    );

    if (next == null) {
      return;
    }
    _controller.setMusic(next);
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

  Future<void> _showPrivacyPicker() async {
    final String? next = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: StoryTextComposerController.privacyOptions.map((
              String value,
            ) {
              return ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: Text(value),
                trailing: value == _controller.selectedPrivacy
                    ? const Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.of(context).pop(value),
              );
            }).toList(),
          ),
        );
      },
    );
    if (next != null) {
      _controller.setPrivacy(next);
    }
  }

  Future<void> _shareStory() async {
    if (!_controller.hasText) {
      AppFeedback.showSnackbar(
        title: 'Write something',
        message: 'Add text before sharing your story.',
      );
      _controller.textFocusNode.requestFocus();
      return;
    }

    setState(() => _isSharing = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) {
      return;
    }
    setState(() => _isSharing = false);
    final List<int> gradient =
        StoryTextComposerController.gradients[_controller.gradientIndex];
    final StoryModel story = StoryModel(
      id: 'local_story_${DateTime.now().microsecondsSinceEpoch}',
      userId: widget.userId,
      createdAt: DateTime.now(),
      text: _controller.currentText,
      music: _controller.showMusic ? _controller.selectedMusic : null,
      backgroundColors: gradient,
      textColorValue: _controller.selectedTextColor.toARGB32(),
      mentionUsername: _controller.hasMention
          ? _controller.mentionUsername
          : null,
      privacy: _controller.selectedPrivacy,
    );
    Navigator.of(context).pop(story);
  }
}
