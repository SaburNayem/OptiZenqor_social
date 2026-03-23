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
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          if (index == 0) {
            return Column(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                  child: const Icon(Icons.archive_outlined),
                ),
                const SizedBox(height: 6),
                Text(
                  'Archive',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            );
          }
          final story = stories[index - 1];
          final user = users.where((e) => e.id == story.userId).firstOrNull;
          if (user == null) {
            return const SizedBox.shrink();
          }
          return InkWell(
            borderRadius: BorderRadius.circular(30),
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
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: story.seen
                        ? null
                        : const LinearGradient(
                            colors: [Color(0xFF1D4ED8), Color(0xFF0EA5A4)],
                          ),
                    border: story.seen
                        ? Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          )
                        : null,
                  ),
                  child: AppAvatar(
                    imageUrl: user.avatar,
                    radius: 24,
                    verified: user.verified,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  user.username,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemCount: stories.length + 1,
      ),
    );
  }
}
