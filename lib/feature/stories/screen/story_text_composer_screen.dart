import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/data/mock/mock_data.dart';
import '../../../core/data/models/story_model.dart';
import '../../../core/functions/app_feedback.dart';
import '../controller/story_text_composer_controller.dart';
import '../model/story_text_composer_model.dart';

class StoryTextComposerScreen extends StatefulWidget {
  const StoryTextComposerScreen({required this.config, super.key});

  final StoryTextComposerModel config;

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
    return Scaffold(
      backgroundColor: Colors.black,
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
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          _buildTopColorTool(),
                          const Spacer(),
                          FilledButton(
                            onPressed: _isSharing ? null : _shareStory,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
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
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Share'),
                          ),
                        ],
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
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.music_note_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _controller.selectedMusic,
                                  style: const TextStyle(
                                    color: Colors.white,
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
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  const Spacer(),
                                  GestureDetector(
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
                                                  color: Colors.white70,
                                                  fontSize: 34,
                                                  fontWeight: FontWeight.w600,
                                                  height: 1.15,
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
                                      onTap: _focusTextInput,
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
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildSideTool(
                                    icon: Icons.palette_outlined,
                                    label: 'Theme',
                                    onTap: _controller.cycleBackground,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildSideTool(
                                    icon: Icons.text_fields_rounded,
                                    label: 'Text',
                                    onTap: _handleTextStyleTap,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildSideTool(
                                    icon: Icons.music_note_outlined,
                                    label: 'Music',
                                    onTap: _showMusicPicker,
                                  ),
                                ],
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
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 8),
            // Text(
            //   label,
            //   style: const TextStyle(
            //     color: Colors.white,
            //     fontWeight: FontWeight.w600,
            //   ),
            // ),
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
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
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
                border: Border.all(color: Colors.white, width: 1.4),
              ),
            ),
            
          ],
        ),
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
    if (!_controller.textFocusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          FocusScope.of(context).requestFocus(_controller.textFocusNode);
        }
      });
      return;
    }

    _controller.textFocusNode.unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).requestFocus(_controller.textFocusNode);
      }
    });
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
          backgroundColor: Colors.transparent,
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
                  color: Colors.black.withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints) {
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
                                          Color(0xFFFF0000),
                                          Color(0xFFFFFF00),
                                          Color(0xFF00FF00),
                                          Color(0xFF00FFFF),
                                          Color(0xFF0000FF),
                                          Color(0xFFFF00FF),
                                          Color(0xFFFF0000),
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
                                          Colors.transparent,
                                          Colors.black,
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: knobLeft.clamp(10, pickerWidth - 10) - 10,
                                    top: knobTop.clamp(10, pickerHeight - 10) - 10,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: tempColor.toColor(),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
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
                        border: Border.all(color: Colors.white, width: 2),
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
      userId: MockData.users.first.id,
      text: _controller.currentText,
      music: _controller.showMusic ? _controller.selectedMusic : null,
      backgroundColors: gradient,
      textColorValue: _controller.selectedTextColor.value,
    );
    Navigator.of(context).pop(story);
  }
}
