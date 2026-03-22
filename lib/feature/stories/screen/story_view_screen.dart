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
  late final PageController _pageController;
  late int _index;

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.stories.indexWhere(
      (StoryModel story) => story.id == widget.initialStoryId,
    );
    _index = initialIndex >= 0 ? initialIndex : 0;
    _pageController = PageController(initialPage: _index);
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(_storyOwnerName(widget.stories[_index])),
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.stories.length,
            onPageChanged: (int value) {
              setState(() {
                _index = value;
              });
            },
            itemBuilder: (BuildContext context, int index) {
              final story = widget.stories[index];
              return InteractiveViewer(
                minScale: 1,
                maxScale: 3,
                child: Center(
                  child: Image.network(
                    story.media,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) {
                      return const Text(
                        'Unable to load story media',
                        style: TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: List<Widget>.generate(widget.stories.length, (int i) {
                  final bool active = i == _index;
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 3,
                      decoration: BoxDecoration(
                        color: active
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _storyOwnerName(StoryModel story) {
    final user = widget.users.where((u) => u.id == story.userId).firstOrNull;
    return user?.name ?? 'Story';
  }
}
