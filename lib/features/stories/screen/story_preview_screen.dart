import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/data/mock/mock_data.dart';
import '../../../core/data/models/story_model.dart';
import '../controller/story_preview_controller.dart';
import '../model/story_preview_model.dart';

class StoryPreviewScreen extends StatefulWidget {
  const StoryPreviewScreen({required this.preview, super.key});

  final StoryPreviewModel preview;

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
    return Scaffold(
      backgroundColor: Colors.black,
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
                          Colors.black.withValues(alpha: 0.28),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.34),
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
                              _buildTopButton(
                                icon: Icons.arrow_back_ios_new_rounded,
                                onTap: () => Navigator.of(context).pop(),
                              ),
                              const Spacer(),
                              FilledButton(
                                onPressed: _isSharing ? null : _sharePreview,
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.splashBackground,
                                  foregroundColor: Colors.white,
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
                          const Spacer(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(child: _buildTextOverlay()),
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
    );
  }

  Widget _buildMedia() {
    if (widget.preview.isVideo) {
      return Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.videocam_rounded, color: Colors.white, size: 64),
            SizedBox(height: 12),
            Text(
              'Video preview coming soon',
              style: TextStyle(color: Colors.white, fontSize: 16),
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
          color: Colors.black.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                _controller.selectedMusic,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
                  color: Colors.white70,
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
    return Column(
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
      ],
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
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.28),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Future<void> _showMusicPicker() async {
    final String? next = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: StoryPreviewController.musicOptions.map((String track) {
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

  Future<void> _sharePreview() async {
    setState(() => _isSharing = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) {
      return;
    }
    setState(() => _isSharing = false);
    final StoryModel story = StoryModel(
      id: 'local_story_${DateTime.now().microsecondsSinceEpoch}',
      userId: MockData.users.first.id,
      media: widget.preview.mediaPath,
      isLocalFile: widget.preview.isLocalFile,
      text: _controller.hasText ? _controller.currentText : null,
      music: _controller.selectedMusic,
      textColorValue: _controller.selectedTextColor.toARGB32(),
    );
    Navigator.of(context).pop(story);
  }
}
