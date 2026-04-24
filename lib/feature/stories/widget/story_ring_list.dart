import 'package:flutter/material.dart';

import '../../../core/data/models/story_model.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/common_widget/app_avatar.dart';
import '../screen/story_view_screen.dart';
import '../screen/add_story_screen.dart';
import '../../../core/constants/app_colors.dart';

class StoryRingList extends StatelessWidget {
  const StoryRingList({
    required this.stories,
    required this.users,
    required this.currentUser,
    required this.onStoryAdded,
    required this.onStoriesSeen,
    super.key,
  });

  final List<StoryModel> stories;
  final List<UserModel> users;
  final UserModel? currentUser;
  final ValueChanged<List<StoryModel>> onStoryAdded;
  final ValueChanged<List<String>> onStoriesSeen;

  @override
  Widget build(BuildContext context) {
    final UserModel? sessionUser = currentUser;
    final List<StoryModel> currentUserStories = sessionUser == null
        ? const <StoryModel>[]
        : stories
              .where((StoryModel story) => story.userId == sessionUser.id)
              .toList(growable: false);
    final List<StoryModel> otherStories = sessionUser == null
        ? stories
        : stories
              .where((StoryModel story) => story.userId != sessionUser.id)
              .toList(growable: false);
    final int extraCurrentUserTileCount = currentUserStories.isEmpty ? 0 : 1;

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (_, index) {
          if (index == 0) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                final List<StoryModel>? createdStories =
                    await Navigator.of(context).push<List<StoryModel>>(
                  MaterialPageRoute<List<StoryModel>>(
                    builder: (_) => AddStoryScreen(userId: sessionUser?.id ?? ''),
                  ),
                );
                if (createdStories != null && createdStories.isNotEmpty) {
                  onStoryAdded(createdStories);
                }
              },
              child: Column(
                children: [
                  Stack(
                    children: [
                      AppAvatar(
                        imageUrl:
                            sessionUser?.avatar ??
                            'https://placehold.co/120x120',
                        radius: 30,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const CircleAvatar(
                            radius: 8,
                            backgroundColor: AppColors.hexFF26C6DA,
                            child: Icon(Icons.add, size: 12, color: AppColors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    sessionUser == null ? 'Add Story' : 'Your Story',
                    style: const TextStyle(fontSize: 11, color: AppColors.black87),
                  ),
                ],
              ),
            );
          }

          if (currentUserStories.isNotEmpty && index == 1) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => StoryViewScreen(
                    stories: currentUserStories,
                    users: users,
                    initialStoryId: currentUserStories.first.id,
                    onStoriesSeen: onStoriesSeen,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: currentUserStories.every((StoryModel story) => story.seen)
                          ? null
                          : const LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [
                                AppColors.hexFFE91E63,
                                AppColors.hexFFFFC107,
                              ],
                            ),
                      border: currentUserStories.every((StoryModel story) => story.seen)
                          ? Border.all(color: AppColors.grey300)
                          : null,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                      child: AppAvatar(
                        imageUrl:
                            sessionUser?.avatar ?? 'https://placehold.co/120x120',
                        radius: 26,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'My Story',
                    style: TextStyle(fontSize: 11, color: AppColors.black87),
                  ),
                ],
              ),
            );
          }

          final story = otherStories[index - 1 - extraCurrentUserTileCount];
          final user =
              story.author ??
              users.where((e) => e.id == story.userId).firstOrNull;
          if (user == null) {
            return const SizedBox.shrink();
          }

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              final List<StoryModel> userStories = otherStories
                  .where((StoryModel item) => item.userId == story.userId)
                  .toList(growable: false);
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => StoryViewScreen(
                    stories: userStories,
                    users: users,
                    initialStoryId: story.id,
                    onStoriesSeen: onStoriesSeen,
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
                            colors: [AppColors.hexFFE91E63, AppColors.hexFFFFC107],
                          ),
                    border: story.seen
                        ? Border.all(color: AppColors.grey300)
                        : null,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.white,
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
                  style: const TextStyle(fontSize: 11, color: AppColors.black87),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 15),
        itemCount: 1 + extraCurrentUserTileCount + otherStories.length,
      ),
    );
  }
}



