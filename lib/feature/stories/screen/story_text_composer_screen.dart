import 'package:flutter/material.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/functions/app_feedback.dart';
import '../controller/story_text_composer_controller.dart';
import '../model/story_text_composer_model.dart';

class StoryTextComposerScreen extends StatefulWidget {
  const StoryTextComposerScreen({
    required this.config,
    super.key,
  });

  final StoryTextComposerModel config;

  @override
  State<StoryTextComposerScreen> createState() => _StoryTextComposerScreenState();
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
      backgroundColor: AppColors.lightBackground,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, _) {
          final List<int> gradient =
              StoryTextComposerController.gradients[_controller.gradientIndex];
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _controller.textFocusNode.requestFocus(),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Color(0xFFF8FAFD),
                    AppColors.lightBackground,
                  ],
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
                            onPressed: () => AppGet.back<void>(),
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          FilledButton(
                            onPressed: _isSharing ? null : _shareStory,
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
                      const SizedBox(height: 12),
                      Expanded(
                        child: Center(
                          child: Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(maxWidth: 420),
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: <Color>[
                                  Color(gradient[0]),
                                  Color(gradient[1]),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 24,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    widget.config.startWithMusic
                                        ? 'Music story'
                                        : 'Text story',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                if (_controller.showMusic)
                                  Container(
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
                                const SizedBox(height: 18),
                                TextField(
                                  controller: _controller.textController,
                                  focusNode: _controller.textFocusNode,
                                  onTap: () => _controller.textFocusNode.requestFocus(),
                                  onChanged: (_) => _controller.onTextChanged(),
                                  maxLines: 6,
                                  minLines: 1,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    height: 1.15,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Share your story',
                                    hintStyle: TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: _controller.cycleBackground,
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          side: BorderSide(
                                            color: Colors.white.withValues(alpha: 0.4),
                                          ),
                                        ),
                                        icon: const Icon(Icons.palette_outlined),
                                        label: const Text('Background'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: _showMusicPicker,
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          side: BorderSide(
                                            color: Colors.white.withValues(alpha: 0.4),
                                          ),
                                        ),
                                        icon: const Icon(Icons.music_note_outlined),
                                        label: const Text('Music'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
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

  Future<void> _showMusicPicker() async {
    final String? next = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: StoryTextComposerController.musicOptions.map((String track) {
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
    AppFeedback.showSnackbar(
      title: 'Story shared',
      message: widget.config.startWithMusic
          ? 'Your text story with music is live.'
          : 'Your text story is live.',
    );
    AppGet.back<void>();
  }
}
