import 'dart:io';

import 'package:flutter/material.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/functions/app_feedback.dart';
import '../controller/story_preview_controller.dart';
import '../model/story_preview_model.dart';

class StoryPreviewScreen extends StatefulWidget {
  const StoryPreviewScreen({
    required this.preview,
    super.key,
  });

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
      body: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, _) {
          return Stack(
            fit: StackFit.expand,
            children: [
              _buildMedia(),
              DecoratedBox(
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
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildTopButton(
                            icon: Icons.arrow_back_ios_new_rounded,
                            onTap: () => AppGet.back<void>(),
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
                          Expanded(
                            child: _buildTextOverlay(),
                          ),
                          const SizedBox(width: 12),
                          _buildRightTools(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
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
      return Image.file(
        File(widget.preview.mediaPath),
        fit: BoxFit.cover,
      );
    }

    return Image.network(
      widget.preview.mediaPath,
      fit: BoxFit.cover,
    );
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
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
          ),
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
            TextField(
              controller: _controller.textController,
              focusNode: _controller.textFocusNode,
              onTap: _controller.startTextEditing,
              onChanged: (_) => _controller.onTextChanged(),
              maxLines: 5,
              minLines: 1,
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                height: 1.15,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: _controller.hasText ? null : 'Add text',
                hintStyle: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
                isCollapsed: true,
                suffixIcon: _controller.isEditingText
                    ? IconButton(
                        onPressed: _controller.stopTextEditing,
                        icon: const Icon(Icons.check_rounded, color: Colors.white),
                      )
                    : null,
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

  Future<void> _sharePreview() async {
    setState(() => _isSharing = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) {
      return;
    }
    setState(() => _isSharing = false);
    AppFeedback.showSnackbar(
      title: 'Story shared',
      message: _controller.hasText
          ? 'Your photo story with text and music is live.'
          : 'Your photo story is live.',
    );
    AppGet.back<void>();
    AppGet.back<void>();
  }
}
