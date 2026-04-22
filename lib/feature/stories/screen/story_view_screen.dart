import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/data/models/story_model.dart';
import '../../../core/data/models/user_model.dart';
import '../controller/stories_controller.dart';
import '../../../core/constants/app_colors.dart';

class StoryViewScreen extends StatefulWidget {
  const StoryViewScreen({
    required this.stories,
    required this.users,
    required this.initialStoryId,
    super.key,
  });

  final List<StoryModel> stories;
  final List<UserModel> users;
  final String initialStoryId;

  @override
  State<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen> {
  late StoriesController _controller;

  @override
  void initState() {
    super.initState();
    final startIndex = widget.stories.indexWhere(
      (s) => s.id == widget.initialStoryId,
    );
    _controller = StoriesController(
      stories: widget.stories,
      startIndex: startIndex < 0 ? 0 : startIndex,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            children: [
              // Story Content
              PageView.builder(
                controller: _controller.pageController,
                itemCount: _controller.stories.length,
                onPageChanged: _controller.onPageChanged,
                itemBuilder: (context, index) {
                  final story = _controller.stories[index];
                  return _buildStoryContent(story);
                },
              ),

              // Top UI (Progress bars & User info)
              SafeArea(
                child: Column(
                  children: [
                    // Progress Bars
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        children: List.generate(_controller.stories.length, (
                          index,
                        ) {
                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              height: 2,
                              decoration: BoxDecoration(
                                color: index <= _controller.currentIndex
                                    ? AppColors.white
                                    : AppColors.white.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    // User Info
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundImage: NetworkImage(
                              _getUser(
                                    _controller.stories[_controller
                                        .currentIndex],
                                  )?.avatar ??
                                  '',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _getUser(
                                  _controller.stories[_controller.currentIndex],
                                )?.name ??
                                '8Luck',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '25 min',
                            style: TextStyle(
                              color: AppColors.white.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(
                              Icons.more_vert,
                              color: AppColors.white,
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom UI (Input, Heart, Share)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '8LUCK.COM',
                        style: TextStyle(
                          color: AppColors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.transparent,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: AppColors.white.withValues(alpha: 0.3),
                                ),
                              ),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Send a message',
                                style: TextStyle(
                                  color: AppColors.white.withValues(alpha: 0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.favorite_border,
                            color: AppColors.white,
                            size: 28,
                          ),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.send_outlined,
                            color: AppColors.white,
                            size: 28,
                          ),
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

  UserModel? _getUser(StoryModel story) {
    return widget.users.where((u) => u.id == story.userId).firstOrNull;
  }

  Widget _buildStoryContent(StoryModel story) {
    final List<Color> backgroundColors = story.backgroundColors.length >= 2
        ? story.backgroundColors.map(Color.new).toList(growable: false)
        : const <Color>[AppColors.hexFF1E40AF, AppColors.hexFF2BB0A1];

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: backgroundColors,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (story.hasMedia) _buildStoryMedia(story),
          if (story.hasText || (story.music ?? '').trim().isNotEmpty)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 120, 24, 140),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if ((story.music ?? '').trim().isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.black.withValues(alpha: 0.28),
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
                            Flexible(
                              child: Text(
                                story.music!,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if ((story.music ?? '').trim().isNotEmpty)
                      const SizedBox(height: 20),
                    if (story.hasText)
                      Text(
                        story.text!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(story.textColorValue),
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStoryMedia(StoryModel story) {
    final Widget child;
    if (story.isLocalFile) {
      child = Image.file(
        File(story.media),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image_outlined, color: AppColors.white),
      );
    } else {
      child = Image.network(
        story.media,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image_outlined, color: AppColors.white),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(color: AppColors.black.withValues(alpha: 0.2)),
      child: child,
    );
  }
}

