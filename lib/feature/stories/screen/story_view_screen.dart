import 'package:flutter/material.dart';

import '../../../core/common_models/story_model.dart';
import '../../../core/common_models/user_model.dart';

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
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.stories.indexWhere((s) => s.id == widget.initialStoryId);
    if (_currentIndex < 0) _currentIndex = 0;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Story Content
          PageView.builder(
            controller: _pageController,
            itemCount: widget.stories.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              final story = widget.stories[index];
              return Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(color: Color(0xFF6A1B9A)), // Purple background from screenshot
                child: Center(
                  child: Image.network(
                    story.media,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(Icons.error, color: Colors.white),
                  ),
                ),
              );
            },
          ),

          // Top UI (Progress bars & User info)
          SafeArea(
            child: Column(
              children: [
                // Progress Bars
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: List.generate(widget.stories.length, (index) {
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          height: 2,
                          decoration: BoxDecoration(
                            color: index <= _currentIndex ? Colors.white : Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                // User Info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(_getUser(widget.stories[_currentIndex])?.avatar ?? ''),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _getUser(widget.stories[_currentIndex])?.name ?? '8Luck',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '25 min',
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
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
                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Send a message',
                            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.favorite_border, color: Colors.white, size: 28),
                      const SizedBox(width: 16),
                      const Icon(Icons.send_outlined, color: Colors.white, size: 28),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  UserModel? _getUser(StoryModel story) {
    return widget.users.where((u) => u.id == story.userId).firstOrNull;
  }
}
