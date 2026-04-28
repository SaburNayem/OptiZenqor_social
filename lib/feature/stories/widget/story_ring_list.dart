import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/data/models/story_model.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/common_widget/app_avatar.dart';
import '../screen/story_view_screen.dart';
import '../screen/add_story_screen.dart';
import '../../../core/constants/app_colors.dart';

enum StoryRingListStyle { circles, facebookCards }

class StoryRingList extends StatelessWidget {
  const StoryRingList({
    required this.stories,
    required this.users,
    required this.currentUser,
    required this.onStoryAdded,
    required this.onStoriesSeen,
    required this.onStoryDeleted,
    this.showAddStory = true,
    this.showCurrentUserStory = true,
    this.onStoryLongPress,
    this.style = StoryRingListStyle.circles,
    super.key,
  });

  final List<StoryModel> stories;
  final List<UserModel> users;
  final UserModel? currentUser;
  final ValueChanged<List<StoryModel>> onStoryAdded;
  final ValueChanged<List<String>> onStoriesSeen;
  final Future<void> Function(String storyId) onStoryDeleted;
  final bool showAddStory;
  final bool showCurrentUserStory;
  final ValueChanged<UserModel>? onStoryLongPress;
  final StoryRingListStyle style;

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
    final List<Widget> storyTiles = style == StoryRingListStyle.facebookCards
        ? _buildFacebookCardTiles(
            context: context,
            sessionUser: sessionUser,
            currentUserStories: currentUserStories,
            otherStories: otherStories,
          )
        : _buildCircleTiles(
            context: context,
            sessionUser: sessionUser,
            currentUserStories: currentUserStories,
            otherStories: otherStories,
            users: users,
          );

    return SizedBox(
      height: style == StoryRingListStyle.facebookCards ? 132 : 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: style == StoryRingListStyle.facebookCards ? 12 : 16,
        ),
        itemBuilder: (_, index) => storyTiles[index],
        separatorBuilder: (context, index) =>
            SizedBox(width: style == StoryRingListStyle.facebookCards ? 8 : 15),
        itemCount: storyTiles.length,
      ),
    );
  }

  List<Widget> _buildCircleTiles({
    required BuildContext context,
    required UserModel? sessionUser,
    required List<StoryModel> currentUserStories,
    required List<StoryModel> otherStories,
    required List<UserModel> users,
  }) {
    return <Widget>[
      if (showAddStory) _buildAddStoryTile(context, sessionUser),
      if (showCurrentUserStory && currentUserStories.isNotEmpty)
        _buildCurrentUserStoryTile(context, currentUserStories, users),
      ...otherStories.map((StoryModel story) {
        final UserModel? user =
            story.author ??
            users.where((UserModel e) => e.id == story.userId).firstOrNull;
        if (user == null) {
          return const SizedBox.shrink();
        }
        return _buildOtherStoryTile(context, story, user, otherStories);
      }),
    ];
  }

  List<Widget> _buildFacebookCardTiles({
    required BuildContext context,
    required UserModel? sessionUser,
    required List<StoryModel> currentUserStories,
    required List<StoryModel> otherStories,
  }) {
    return <Widget>[
      if (showAddStory) _buildCreateStoryCard(context, sessionUser),
      if (showCurrentUserStory && currentUserStories.isNotEmpty)
        _buildStoryCard(
          context: context,
          story: currentUserStories.first,
          user: sessionUser,
          storiesForUser: currentUserStories,
          label: 'Your story',
        ),
      ...otherStories.map((StoryModel story) {
        final UserModel? user =
            story.author ??
            users.where((UserModel e) => e.id == story.userId).firstOrNull;
        if (user == null) {
          return const SizedBox.shrink();
        }
        final List<StoryModel> userStories = otherStories
            .where((StoryModel item) => item.userId == story.userId)
            .toList(growable: false);
        return _buildStoryCard(
          context: context,
          story: story,
          user: user,
          storiesForUser: userStories,
          label: _cardLabelForUser(user),
        );
      }),
    ];
  }

  Widget _buildCreateStoryCard(BuildContext context, UserModel? sessionUser) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        final List<StoryModel>? createdStories = await Navigator.of(context)
            .push<List<StoryModel>>(
              MaterialPageRoute<List<StoryModel>>(
                builder: (_) => AddStoryScreen(userId: sessionUser?.id ?? ''),
              ),
            );
        if (createdStories != null && createdStories.isNotEmpty) {
          onStoryAdded(createdStories);
        }
      },
      child: SizedBox(
        width: 78,
        height: 132,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.grey200),
          ),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  fit: StackFit.expand,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                      child: _buildCreateStoryProfileMedia(sessionUser),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: <Color>[
                              AppColors.black.withValues(alpha: 0.02),
                              AppColors.black.withValues(alpha: 0.18),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: -12,
                      child: Center(
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.hexFF1877F2,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.white,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: AppColors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(7, 18, 7, 8),
                child: Text(
                  'Create story',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateStoryProfileMedia(UserModel? sessionUser) {
    final String imageUrl = sessionUser?.avatar.trim() ?? '';
    if (imageUrl.isEmpty) {
      return Container(
        color: AppColors.grey100,
        child: const Center(
          child: Icon(Icons.person_rounded, color: AppColors.grey, size: 28),
        ),
      );
    }
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          color: AppColors.grey100,
          child: const Center(
            child: Icon(Icons.person_rounded, color: AppColors.grey, size: 28),
          ),
        ),
      );
    }
    return Image.file(
      File(imageUrl),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        color: AppColors.grey100,
        child: const Center(
          child: Icon(Icons.person_rounded, color: AppColors.grey, size: 28),
        ),
      ),
    );
  }

  Widget _buildStoryCard({
    required BuildContext context,
    required StoryModel story,
    required UserModel? user,
    required List<StoryModel> storiesForUser,
    required String label,
  }) {
    final String mediaPath = _thumbnailMediaFor(story);
    final bool seen = storiesForUser.every((StoryModel item) => item.seen);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: user == null || onStoryLongPress == null
          ? null
          : () => onStoryLongPress!(user),
      onTap: storiesForUser.isEmpty
          ? null
          : () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => StoryViewScreen(
                  stories: storiesForUser,
                  users: users,
                  initialStoryId: story.id,
                  onStoriesSeen: onStoriesSeen,
                  onStoryDeleted: onStoryDeleted,
                ),
              ),
            ),
      child: SizedBox(
        width: 78,
        height: 132,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              _buildStoryCardMedia(mediaPath, user),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        AppColors.black.withValues(alpha: 0.04),
                        AppColors.black.withValues(alpha: 0.72),
                      ],
                    ),
                  ),
                ),
              ),
              if (user != null)
                Positioned(
                  left: 7,
                  top: 7,
                  child: _buildFacebookCardAvatar(user, seen: seen),
                ),
              Positioned(
                left: 7,
                right: 7,
                bottom: 8,
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoryCardMedia(String mediaPath, UserModel? user) {
    if (mediaPath.isEmpty || _looksLikeVideo(mediaPath)) {
      return AppAvatar(
        imageUrl: user?.avatar ?? 'https://placehold.co/160x240',
        radius: 0,
      );
    }
    if (mediaPath.startsWith('http://') || mediaPath.startsWith('https://')) {
      return Image.network(
        mediaPath,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => AppAvatar(
          imageUrl: user?.avatar ?? 'https://placehold.co/160x240',
          radius: 0,
        ),
      );
    }
    return Image.file(
      File(mediaPath),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => AppAvatar(
        imageUrl: user?.avatar ?? 'https://placehold.co/160x240',
        radius: 0,
      ),
    );
  }

  Widget _buildFacebookCardAvatar(UserModel user, {required bool seen}) {
    return Container(
      width: 30,
      height: 30,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: seen ? AppColors.grey300 : AppColors.hexFF1877F2,
      ),
      child: ClipOval(child: AppAvatar(imageUrl: user.avatar, radius: 13)),
    );
  }

  Widget _buildAddStoryTile(BuildContext context, UserModel? sessionUser) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        final List<StoryModel>? createdStories = await Navigator.of(context)
            .push<List<StoryModel>>(
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
                imageUrl: sessionUser?.avatar ?? 'https://placehold.co/120x120',
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

  Widget _buildCurrentUserStoryTile(
    BuildContext context,
    List<StoryModel> currentUserStories,
    List<UserModel> users,
  ) {
    final UserModel? sessionUser = currentUser;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => StoryViewScreen(
            stories: currentUserStories,
            users: users,
            initialStoryId: currentUserStories.first.id,
            onStoriesSeen: onStoriesSeen,
            onStoryDeleted: onStoryDeleted,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildStoryRing(
            seen: currentUserStories.every((StoryModel story) => story.seen),
            child: AppAvatar(
              imageUrl: sessionUser?.avatar ?? 'https://placehold.co/120x120',
              radius: 26,
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

  Widget _buildOtherStoryTile(
    BuildContext context,
    StoryModel story,
    UserModel user,
    List<StoryModel> otherStories,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: onStoryLongPress == null
          ? null
          : () => onStoryLongPress!(user),
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
              onStoryDeleted: onStoryDeleted,
            ),
          ),
        );
      },
      child: Column(
        children: [
          _buildStoryRing(
            seen: story.seen,
            child: _buildOtherStoryThumbnail(story, user),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 66,
            child: Text(
              _displayNameForUser(user),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: AppColors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryRing({required bool seen, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: seen
            ? null
            : const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [AppColors.hexFFE91E63, AppColors.hexFFFFC107],
              ),
        border: seen ? Border.all(color: AppColors.grey300) : null,
      ),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
        ),
        child: child,
      ),
    );
  }

  String _displayNameForUser(UserModel user) {
    final String name = user.name.trim();
    if (name.isNotEmpty && name.toLowerCase() != 'unknown user') {
      return name;
    }
    return user.username.trim().isEmpty ? 'Story' : user.username.trim();
  }

  String _cardLabelForUser(UserModel user) {
    final String name = _displayNameForUser(user);
    final List<String> parts = name
        .split(RegExp(r'\s+'))
        .where((String part) => part.trim().isNotEmpty)
        .toList(growable: false);
    if (parts.length <= 1) {
      return name;
    }
    return '${parts.first}\n${parts.skip(1).join(' ')}';
  }

  Widget _buildOtherStoryThumbnail(StoryModel story, UserModel user) {
    final String mediaPath = _thumbnailMediaFor(story);
    if (mediaPath.isEmpty || _looksLikeVideo(mediaPath)) {
      return AppAvatar(imageUrl: user.avatar, radius: 26);
    }

    final Widget image = story.isLocalFile
        ? Image.file(
            File(mediaPath),
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                AppAvatar(imageUrl: user.avatar, radius: 26),
          )
        : Image.network(
            mediaPath,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                AppAvatar(imageUrl: user.avatar, radius: 26),
          );

    return ClipOval(child: SizedBox(width: 52, height: 52, child: image));
  }

  String _thumbnailMediaFor(StoryModel story) {
    if (story.mediaItems.isNotEmpty) {
      return story.mediaItems.first.trim();
    }
    return story.media.trim();
  }

  bool _looksLikeVideo(String path) {
    final String lower = path.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.m4v') ||
        lower.endsWith('.webm');
  }
}
