import 'package:flutter/material.dart';

import '../../../core/common_models/story_model.dart';
import '../../../core/common_models/user_model.dart';
import '../../../core/widgets/app_avatar.dart';
import '../screen/story_view_screen.dart';

class StoryRingList extends StatelessWidget {
  const StoryRingList({
    required this.stories,
    required this.users,
    super.key,
  });

  final List<StoryModel> stories;
  final List<UserModel> users;

  @override
  Widget build(BuildContext context) {
    final currentUser = users.first; // Assuming first is current user for demo

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (_, index) {
          if (index == 0) {
            // Your Story
            return Column(
              children: [
                Stack(
                  children: [
                    AppAvatar(
                      imageUrl: currentUser.avatar,
                      radius: 30,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const CircleAvatar(
                          radius: 8,
                          backgroundColor: Color(0xFF26C6DA),
                          child: Icon(Icons.add, size: 12, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Your Story',
                  style: TextStyle(fontSize: 11, color: Colors.black87),
                ),
              ],
            );
          }

          final story = stories[index - 1];
          final user = users.where((e) => e.id == story.userId).firstOrNull;
          if (user == null) return const SizedBox.shrink();

          return InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => StoryViewScreen(
                    stories: stories,
                    users: users,
                    initialStoryId: story.id,
                  ),
                ),
              );
            },
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: story.seen
                        ? null
                        : const LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [Color(0xFFE91E63), Color(0xFFFFC107)],
                          ),
                    border: story.seen
                        ? Border.all(color: Colors.grey.shade300)
                        : null,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: AppAvatar(
                      imageUrl: user.avatar,
                      radius: 26,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  user.name.split(' ').first,
                  style: const TextStyle(fontSize: 11, color: Colors.black87),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 15),
        itemCount: stories.length + 1,
      ),
    );
  }
}
