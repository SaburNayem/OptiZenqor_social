import 'package:flutter/material.dart';

import '../../../core/common_models/story_model.dart';
import '../../../core/common_models/user_model.dart';

class StoryViewScreen extends StatelessWidget {
  StoryViewScreen({
    required this.stories,
    required this.users,
    required this.initialStoryId,
    super.key,
  }) : _index = ValueNotifier<int>(
          stories.indexWhere((StoryModel story) => story.id == initialStoryId) >= 0
              ? stories.indexWhere((StoryModel story) => story.id == initialStoryId)
              : 0,
        ),
        _pageController = PageController(
          initialPage: stories.indexWhere((StoryModel story) => story.id == initialStoryId) >= 0
              ? stories.indexWhere((StoryModel story) => story.id == initialStoryId)
              : 0,
        );

  final List<StoryModel> stories;
  final List<UserModel> users;
  final String initialStoryId;
  final ValueNotifier<int> _index;
  final PageController _pageController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: ValueListenableBuilder<int>(
          valueListenable: _index,
          builder: (context, index, _) {
            return Text(_storyOwnerName(stories[index]));
          },
        ),
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: stories.length,
            onPageChanged: (int value) {
              _index.value = value;
            },
            itemBuilder: (BuildContext context, int index) {
              final story = stories[index];
              return InteractiveViewer(
                minScale: 1,
                maxScale: 3,
                child: Center(
                  child: Image.network(
                    story.media,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) {
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
                children: List<Widget>.generate(stories.length, (int i) {
                  final bool active = i == _index.value;
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
          Positioned(
            left: 12,
            right: 12,
            bottom: 20,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: const [
                  Chip(label: Text('Story stickers')),
                  SizedBox(width: 8),
                  Chip(label: Text('Poll sticker')),
                  SizedBox(width: 8),
                  Chip(label: Text('Question sticker')),
                  SizedBox(width: 8),
                  Chip(label: Text('Emoji slider')),
                  SizedBox(width: 8),
                  Chip(label: Text('Mention sticker')),
                  SizedBox(width: 8),
                  Chip(label: Text('Location sticker')),
                  SizedBox(width: 8),
                  Chip(label: Text('Music sticker')),
                  SizedBox(width: 8),
                  Chip(label: Text('Link sticker')),
                ],
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 72,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: const [
                  Chip(label: Text('Story archive list')),
                  SizedBox(width: 8),
                  Chip(label: Text('Memories placeholder')),
                  SizedBox(width: 8),
                  Chip(label: Text('Restore to highlights')),
                  SizedBox(width: 8),
                  Chip(label: Text('Re-share archived story')),
                  SizedBox(width: 8),
                  Chip(label: Text('Create close friends list')),
                  SizedBox(width: 8),
                  Chip(label: Text('Edit close friends list')),
                  SizedBox(width: 8),
                  Chip(label: Text('Preview close friends audience')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _storyOwnerName(StoryModel story) {
    final user = users.where((u) => u.id == story.userId).firstOrNull;
    return user?.name ?? 'Story';
  }
}
