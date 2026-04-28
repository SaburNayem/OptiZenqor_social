import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app_route/route_names.dart';
import '../../../core/data/models/story_model.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/common_widget/inline_video_player.dart';
import '../../../core/functions/app_feedback.dart';
import '../../../core/navigation/app_get.dart';
import '../controller/stories_controller.dart';
import '../repository/stories_repository.dart';
import '../../../core/constants/app_colors.dart';

class StoryViewScreen extends StatefulWidget {
  const StoryViewScreen({
    required this.stories,
    required this.users,
    required this.initialStoryId,
    this.onStoriesSeen,
    this.onStoryDeleted,
    super.key,
  });

  final List<StoryModel> stories;
  final List<UserModel> users;
  final String initialStoryId;
  final ValueChanged<List<String>>? onStoriesSeen;
  final Future<void> Function(String storyId)? onStoryDeleted;

  @override
  State<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen> {
  static const Duration _defaultStoryDuration = Duration(seconds: 5);
  static const Duration _storyTick = Duration(milliseconds: 50);

  late StoriesController _controller;
  final StoriesRepository _storiesRepository = StoriesRepository();
  List<UserModel> _viewers = <UserModel>[];
  final Set<String> _seenStoryIds = <String>{};
  UserModel? _currentUser;
  final Set<String> _likedStoryIds = <String>{};
  Timer? _storyTimer;
  double _storyProgress = 0;

  @override
  void initState() {
    super.initState();
    final int startIndex = widget.stories.indexWhere(
      (s) => s.id == widget.initialStoryId,
    );
    _controller = StoriesController(
      stories: widget.stories,
      startIndex: startIndex < 0 ? 0 : startIndex,
    );
    _loadCurrentUser();
    _markCurrentStorySeen();
    _loadViewersForCurrentStory();
    _restartStoryPlayback();
  }

  @override
  void dispose() {
    _storyTimer?.cancel();
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
          final StoryModel currentStory =
              _controller.stories[_controller.currentIndex];
          final bool isMyStory = _isMyStory(currentStory);
          return Stack(
            children: [
              // Story Content
              PageView.builder(
                controller: _controller.pageController,
                itemCount: _controller.stories.length,
                onPageChanged: (int index) {
                  _controller.onPageChanged(index);
                  _markCurrentStorySeen();
                  _loadViewersForCurrentStory();
                  _restartStoryPlayback();
                },
                itemBuilder: (context, index) {
                  final story = _controller.stories[index];
                  return _buildStoryContent(story);
                },
              ),
              Positioned.fill(
                top: 110,
                bottom: 120,
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: _goPrevious,
                        child: const SizedBox.expand(),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: _goNext,
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ],
                ),
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
                                color: AppColors.white.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(1),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: _progressForIndex(index),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
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
                          IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              color: AppColors.white,
                            ),
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                          _buildStoryHeaderAvatar(currentStory),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Row(
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    _displayNameForStory(currentStory),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _timeLabelFor(
                                    _controller.stories[_controller
                                        .currentIndex],
                                  ),
                                  style: TextStyle(
                                    color: AppColors.white.withValues(
                                      alpha: 0.6,
                                    ),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isMyStory)
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert,
                                color: AppColors.white,
                              ),
                              onSelected: (String value) async {
                                if (value != 'delete') {
                                  return;
                                }
                                final bool confirmed =
                                    await _confirmDeleteStory();
                                if (!mounted || !confirmed) {
                                  return;
                                }
                                await _deleteStory(currentStory);
                              },
                              itemBuilder: (BuildContext context) {
                                return const <PopupMenuEntry<String>>[
                                  PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Text('Delete story'),
                                  ),
                                ];
                              },
                            )
                          else
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert,
                                color: AppColors.white,
                              ),
                              onSelected: (String value) {
                                if (value == 'report') {
                                  _reportStory(currentStory);
                                }
                              },
                              itemBuilder: (BuildContext context) {
                                return const <PopupMenuEntry<String>>[
                                  PopupMenuItem<String>(
                                    value: 'report',
                                    child: Text('Report story'),
                                  ),
                                ];
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom UI
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isMyStory)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: _showViewersSheet,
                            child: Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.black.withValues(alpha: 0.34),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: AppColors.white.withValues(
                                    alpha: 0.18,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  const Icon(
                                    Icons.remove_red_eye_outlined,
                                    color: AppColors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    _viewers.isEmpty
                                        ? 'Views'
                                        : 'Views ${_viewers.length}',
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _replyToStory(currentStory),
                                child: Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.transparent,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: AppColors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Reply to ${_displayNameForStory(currentStory)}',
                                    style: TextStyle(
                                      color: AppColors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: () => _toggleStoryLike(currentStory),
                              child: Icon(
                                _likedStoryIds.contains(currentStory.id)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _likedStoryIds.contains(currentStory.id)
                                    ? AppColors.hexFFE91E63
                                    : AppColors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: _shareCurrentStory,
                              child: const Icon(
                                Icons.ios_share_rounded,
                                color: AppColors.white,
                                size: 28,
                              ),
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
    if (_currentUser != null &&
        (story.userId == _currentUser!.id ||
            story.author?.id == _currentUser!.id)) {
      return _currentUser;
    }

    return story.author ??
        widget.users.where((u) => u.id == story.userId).firstOrNull;
  }

  String _displayNameForStory(StoryModel story) {
    final UserModel? user = _getUser(story);
    final String name = user?.name.trim() ?? '';
    if (name.isNotEmpty && name.toLowerCase() != 'unknown user') {
      return name;
    }
    final String username = user?.username.trim() ?? '';
    return username.isEmpty ? 'Story' : username;
  }

  bool _isMyStory(StoryModel story) {
    final String currentUserId = _currentUser?.id ?? '';
    return currentUserId.isNotEmpty &&
        (story.userId == currentUserId || story.author?.id == currentUserId);
  }

  Future<void> _loadCurrentUser() async {
    final UserModel? user = await _storiesRepository.currentUser();
    if (!mounted) {
      return;
    }

    setState(() {
      _currentUser = user;
    });
  }

  Future<void> _toggleStoryLike(StoryModel story) async {
    final bool nextLiked = !_likedStoryIds.contains(story.id);
    setState(() {
      if (nextLiked) {
        _likedStoryIds.add(story.id);
      } else {
        _likedStoryIds.remove(story.id);
      }
    });

    try {
      await _storiesRepository.setStoryReaction(
        storyId: story.id,
        liked: nextLiked,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        if (nextLiked) {
          _likedStoryIds.remove(story.id);
        } else {
          _likedStoryIds.add(story.id);
        }
      });
    }
  }

  void _replyToStory(StoryModel story) {
    final UserModel? user = _getUser(story);
    final String displayName = _displayNameForStory(story);
    AppGet.toNamed(RouteNames.chat);
    AppFeedback.showSnackbar(
      title: 'Message',
      message: user == null
          ? 'Open chat to reply to this story.'
          : 'Reply to $displayName in messages.',
    );
  }

  void _markCurrentStorySeen() {
    final StoryModel story = _controller.stories[_controller.currentIndex];
    if (!_canLoadStoryInsights(story) || !_seenStoryIds.add(story.id)) {
      return;
    }
    widget.onStoriesSeen?.call(<String>[story.id]);
    unawaited(_storiesRepository.markStoryViewed(story.id).catchError((_) {}));
  }

  Future<void> _goPrevious() async {
    if (_controller.currentIndex <= 0) {
      return;
    }
    _storyTimer?.cancel();
    await _controller.pageController.previousPage(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }

  Future<void> _goNext() async {
    if (_controller.currentIndex >= _controller.stories.length - 1) {
      _storyTimer?.cancel();
      if (mounted) {
        Navigator.of(context).maybePop();
      }
      return;
    }
    _storyTimer?.cancel();
    await _controller.pageController.nextPage(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }

  Future<void> _loadViewersForCurrentStory() async {
    final StoryModel story = _controller.stories[_controller.currentIndex];
    if (!_canLoadStoryInsights(story)) {
      if (mounted) {
        setState(() {
          _viewers = <UserModel>[];
        });
      }
      return;
    }
    try {
      final List<UserModel> viewers = await _storiesRepository
          .fetchStoryViewers(story.id);
      if (mounted) {
        setState(() {
          _viewers = viewers;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _viewers = <UserModel>[];
        });
      }
    }
  }

  bool _canLoadStoryInsights(StoryModel story) {
    final String storyId = story.id.trim();
    return storyId.isNotEmpty && !storyId.startsWith('local_story_');
  }

  Future<void> _showViewersSheet() async {
    await _loadViewersForCurrentStory();
    if (!mounted) {
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _viewers.isEmpty ? 'Views' : 'Views ${_viewers.length}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 320),
                    child: _viewers.isEmpty
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 18,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.grey100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              'No viewers yet.',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: _viewers.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8),
                            itemBuilder: (BuildContext context, int index) {
                              final UserModel viewer = _viewers[index];
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.grey100,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    AppAvatar(
                                      imageUrl: viewer.avatar,
                                      radius: 18,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text(
                                            viewer.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Text(
                                            '@${viewer.username}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: AppColors.grey600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStoryHeaderAvatar(StoryModel story) {
    final List<String> mediaItems = story.mediaItems.isNotEmpty
        ? story.mediaItems
        : (story.media.trim().isNotEmpty ? <String>[story.media] : <String>[]);

    if (mediaItems.isNotEmpty && !_looksLikeVideo(mediaItems.first)) {
      final String path = mediaItems.first;
      final Widget image = story.isLocalFile
          ? Image.file(File(path), fit: BoxFit.cover)
          : Image.network(path, fit: BoxFit.cover);

      return ClipOval(child: SizedBox(width: 36, height: 36, child: image));
    }

    return AppAvatar(imageUrl: _getUser(story)?.avatar ?? '', radius: 18);
  }

  Future<bool> _confirmDeleteStory() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete story'),
          content: const Text('This story will be removed.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    return confirmed ?? false;
  }

  Future<void> _deleteStory(StoryModel story) async {
    try {
      await widget.onStoryDeleted?.call(story.id);
      if (!mounted) {
        return;
      }
      Navigator.of(context).maybePop();
      AppFeedback.showSnackbar(title: 'Story', message: 'Story deleted');
    } catch (error) {
      if (!mounted) {
        return;
      }
      AppFeedback.showSnackbar(
        title: 'Story',
        message: error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void _reportStory(StoryModel story) {
    final String label = _displayNameForStory(story);
    AppFeedback.showSnackbar(
      title: 'Story',
      message: 'Report sent for $label.',
    );
  }

  Widget _buildStoryContent(StoryModel story) {
    final List<String> mediaItems = story.mediaItems.isNotEmpty
        ? story.mediaItems
        : (story.media.trim().isNotEmpty ? <String>[story.media] : <String>[]);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Size canvasSize = constraints.biggest;

        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Positioned.fill(
              child: _buildStoryCanvasBackground(story, mediaItems),
            ),
            if (mediaItems.length == 1 && !_looksLikeVideo(mediaItems.first))
              Positioned.fill(
                child: _buildSinglePhotoStoryMedia(
                  story: story,
                  path: mediaItems.first,
                  bodySize: canvasSize,
                ),
              )
            else if (mediaItems.isNotEmpty)
              ...List<Widget>.generate(mediaItems.length, (int index) {
                final StoryMediaTransform transform =
                    index < story.mediaTransforms.length
                    ? story.mediaTransforms[index]
                    : (mediaItems.length == 1
                          ? const StoryMediaTransform(
                              widthFactor: 1,
                              heightFactor: 1,
                              borderRadius: 0,
                            )
                          : const StoryMediaTransform());

                return Positioned.fill(
                  child: _buildMoveableStoryMedia(
                    story: story,
                    path: mediaItems[index],
                    transform: transform,
                    bodySize: canvasSize,
                  ),
                );
              }),
            Positioned.fill(child: _buildStoryTextOverlay(story, canvasSize)),
          ],
        );
      },
    );
  }

  Widget _buildSinglePhotoStoryMedia({
    required StoryModel story,
    required String path,
    required Size bodySize,
  }) {
    final StoryMediaTransform transform = story.mediaTransforms.isNotEmpty
        ? story.mediaTransforms.first
        : const StoryMediaTransform(
            widthFactor: 1,
            heightFactor: 1,
            borderRadius: 0,
          );

    return Center(
      child: Transform.translate(
        offset: Offset(transform.offsetDx, transform.offsetDy),
        child: Transform.scale(
          scale: transform.scale,
          child: SizedBox(
            width: bodySize.width,
            height: bodySize.height,
            child: _buildStoryMediaItem(story, path, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  Widget _buildStoryCanvasBackground(
    StoryModel story,
    List<String> mediaItems,
  ) {
    if (mediaItems.isNotEmpty && !_looksLikeVideo(mediaItems.first)) {
      return Stack(
        fit: StackFit.expand,
        children: <Widget>[
          _buildStoryMediaItem(story, mediaItems.first, fit: BoxFit.cover),
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 22, sigmaY: 22),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.black.withValues(alpha: 0.18),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      AppColors.black.withValues(alpha: 0.10),
                      AppColors.black.withValues(alpha: 0.24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    final List<Color> backgroundColors = story.backgroundColors.isEmpty
        ? const <Color>[AppColors.black, AppColors.grey800]
        : story.backgroundColors
              .map((int color) => Color(color))
              .toList(growable: false);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: backgroundColors.length == 1
              ? <Color>[backgroundColors.first, backgroundColors.first]
              : backgroundColors,
        ),
      ),
    );
  }

  Widget _buildStoryFixedMediaSection(
    StoryModel story,
    List<String> mediaItems,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.grey100,
          border: Border.all(color: AppColors.grey200),
        ),
        child: mediaItems.isEmpty
            ? const SizedBox.expand()
            : Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  _buildStoryHeroMedia(story, mediaItems.first),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Row(
                      children: <Widget>[
                        _buildStoryChip(
                          icon:
                              story.media.trim().toLowerCase().endsWith('.mp4')
                              ? Icons.videocam_rounded
                              : Icons.photo_rounded,
                          label:
                              story.media.trim().toLowerCase().endsWith('.mp4')
                              ? 'Video'
                              : 'Photo',
                        ),
                        if (mediaItems.length > 1) ...<Widget>[
                          const SizedBox(width: 8),
                          _buildStoryChip(
                            icon: Icons.layers_rounded,
                            label: '+${mediaItems.length - 1} moveable',
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildStoryBodyCanvas({
    required StoryModel story,
    required List<String> bodyMediaItems,
    required Size bodySize,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.grey200),
        ),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[AppColors.white, AppColors.hexFFF8FAFC],
                  ),
                ),
              ),
            ),
            for (int index = 0; index < bodyMediaItems.length; index++)
              Positioned.fill(
                child: _buildMoveableStoryMedia(
                  story: story,
                  path: bodyMediaItems[index],
                  transform: index < story.mediaTransforms.length
                      ? story.mediaTransforms[index]
                      : const StoryMediaTransform(),
                  bodySize: bodySize,
                ),
              ),
            Positioned.fill(child: _buildStoryTextOverlay(story, bodySize)),
          ],
        ),
      ),
    );
  }

  Widget _buildMoveableStoryMedia({
    required StoryModel story,
    required String path,
    required StoryMediaTransform transform,
    required Size bodySize,
  }) {
    return Center(
      child: Transform.translate(
        offset: Offset(transform.offsetDx, transform.offsetDy),
        child: Transform.scale(
          scale: transform.scale,
          child: SizedBox(
            width: bodySize.width * transform.widthFactor,
            height: bodySize.height * transform.heightFactor,
            child: ClipRect(
              child: _buildStoryMediaItem(story, path, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoryTextOverlay(StoryModel story, Size bodySize) {
    final bool hasMeta =
        (story.sticker ?? '').trim().isNotEmpty ||
        (story.mentionUsername ?? '').trim().isNotEmpty;
    final bool hasContent = story.hasText || hasMeta;

    if (!hasContent) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Transform.translate(
        offset: Offset(story.textOffsetDx, story.textOffsetDy),
        child: Transform.scale(
          alignment: Alignment.centerLeft,
          scale: story.textScale == 0 ? 1 : story.textScale,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if ((story.music ?? '').trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildStoryChip(
                      icon: Icons.music_note_rounded,
                      label: story.music!,
                    ),
                  ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    if ((story.sticker ?? '').trim().isNotEmpty)
                      _buildStoryChip(
                        icon: Icons.emoji_emotions_outlined,
                        label: story.sticker!,
                      ),
                    if ((story.mentionUsername ?? '').trim().isNotEmpty)
                      _buildStoryChip(
                        icon: Icons.alternate_email_rounded,
                        label: '@${story.mentionUsername!}',
                      ),
                  ],
                ),
                if (story.hasText) ...<Widget>[
                  const SizedBox(height: 14),
                  Text(
                    story.text!,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Color(story.textColorValue),
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      height: 1.12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoryHeroMedia(StoryModel story, String path) {
    if (_looksLikeVideo(path)) {
      return ColoredBox(
        color: AppColors.black,
        child: InlineVideoPlayer(
          filePath: story.isLocalFile ? path : null,
          networkUrl: story.isLocalFile ? null : path,
          autoPlay: true,
        ),
      );
    }

    return _buildStoryMediaItem(story, path);
  }

  bool _looksLikeVideo(String path) {
    final String normalized = path.trim().toLowerCase();
    return normalized.endsWith('.mp4') ||
        normalized.endsWith('.mov') ||
        normalized.endsWith('.m4v') ||
        normalized.endsWith('.webm');
  }

  Widget _buildStoryMedia(StoryModel story, List<String> mediaItems) {
    return DecoratedBox(
      decoration: BoxDecoration(color: AppColors.black.withValues(alpha: 0.2)),
      child: mediaItems.length == 1
          ? _buildStoryMediaItem(story, mediaItems.first)
          : _buildStoryCollage(story, mediaItems),
    );
  }

  Widget _buildStoryCollage(StoryModel story, List<String> mediaItems) {
    switch (story.collageLayout) {
      case 'mosaic':
        return _buildMosaicStoryCollage(story, mediaItems);
      case 'stack':
        return _buildStackStoryCollage(story, mediaItems);
      case 'grid':
      default:
        return _buildGridStoryCollage(story, mediaItems);
    }
  }

  Widget _buildGridStoryCollage(StoryModel story, List<String> mediaItems) {
    final int count = mediaItems.length.clamp(1, 7);
    final int crossAxisCount = count <= 2
        ? 1
        : count <= 4
        ? 2
        : 3;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: count,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
          childAspectRatio: count == 1 ? 0.7 : 0.9,
        ),
        itemBuilder: (BuildContext context, int index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: _buildStoryMediaItem(story, mediaItems[index]),
          );
        },
      ),
    );
  }

  Widget _buildMosaicStoryCollage(StoryModel story, List<String> mediaItems) {
    final List<String> items = mediaItems.take(7).toList(growable: false);
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _buildStoryMediaItem(story, items.first),
                  ),
                ),
                if (items.length > 1) const SizedBox(width: 6),
                if (items.length > 1)
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: _buildStoryMediaItem(story, items[1]),
                          ),
                        ),
                        if (items.length > 2) const SizedBox(height: 6),
                        if (items.length > 2)
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: _buildStoryMediaItem(story, items[2]),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (items.length > 3) const SizedBox(height: 6),
          if (items.length > 3)
            Expanded(
              flex: 3,
              child: Row(
                children: List<Widget>.generate(items.length - 3, (int index) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: index == 0 ? 0 : 6),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: _buildStoryMediaItem(story, items[index + 3]),
                      ),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStackStoryCollage(StoryModel story, List<String> mediaItems) {
    final List<String> items = mediaItems.take(7).toList(growable: false);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: List<Widget>.generate(items.length, (int index) {
          final double inset = index * 16;
          return Positioned(
            left: inset,
            right: inset,
            top: inset + 24,
            bottom: inset + 40,
            child: Transform.rotate(
              angle: (index.isEven ? -1 : 1) * 0.035,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.7),
                      width: 2,
                    ),
                  ),
                  child: _buildStoryMediaItem(story, items[index]),
                ),
              ),
            ),
          );
        }).reversed.toList(growable: false),
      ),
    );
  }

  Widget _buildStoryMediaItem(
    StoryModel story,
    String path, {
    BoxFit fit = BoxFit.contain,
  }) {
    if (story.isLocalFile) {
      return Image.file(
        File(path),
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image_outlined, color: AppColors.white),
      );
    }
    return Image.network(
      path,
      fit: fit,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.broken_image_outlined, color: AppColors.white),
    );
  }

  Widget _buildStoryChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.white, size: 16),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openStoryLink(StoryModel story) {
    final String target = (story.linkUrl ?? '').trim();
    if (target.isEmpty) {
      return;
    }
    if (target == RouteNames.privacySettings ||
        target.contains('privacySettings') ||
        target.contains('/settings/privacy')) {
      AppGet.toNamed(RouteNames.privacySettings);
      return;
    }
    Clipboard.setData(ClipboardData(text: target));
    AppFeedback.showSnackbar(
      title: 'Story link',
      message: 'Link copied to clipboard',
    );
  }

  Future<void> _shareCurrentStory() async {
    final StoryModel story = _controller.stories[_controller.currentIndex];
    final String shareText = (story.linkUrl ?? '').trim().isNotEmpty
        ? (story.linkLabel ?? '').trim().isNotEmpty
              ? '${story.linkLabel}: ${story.linkUrl}'
              : story.linkUrl!
        : story.text?.trim().isNotEmpty == true
        ? story.text!.trim()
        : 'Story shared from OptiZenqor';
    await Clipboard.setData(ClipboardData(text: shareText));
    AppFeedback.showSnackbar(
      title: 'Story',
      message:
          'Story share text copied. You can repost it to other chats or shorts.',
    );
  }

  String _timeLabelFor(StoryModel story) {
    final DateTime? createdAt = story.createdAt;
    if (createdAt == null) {
      return 'Now';
    }

    final Duration diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) {
      return 'Just now';
    }
    if (diff.inHours < 1) {
      return '${diff.inMinutes} min';
    }
    if (diff.inDays < 1) {
      return '${diff.inHours} h';
    }
    return '${diff.inDays} d';
  }

  void _restartStoryPlayback() {
    _storyTimer?.cancel();
    if (!mounted || _controller.stories.isEmpty) {
      return;
    }

    setState(() {
      _storyProgress = 0;
    });

    final int durationMs = _storyDurationFor(
      _controller.stories[_controller.currentIndex],
    ).inMilliseconds;
    final int tickMs = _storyTick.inMilliseconds;
    int elapsedMs = 0;

    _storyTimer = Timer.periodic(_storyTick, (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      elapsedMs += tickMs;
      final double nextProgress = (elapsedMs / durationMs).clamp(0, 1);

      setState(() {
        _storyProgress = nextProgress;
      });

      if (nextProgress >= 1) {
        timer.cancel();
        unawaited(_goNext());
      }
    });
  }

  Duration _storyDurationFor(StoryModel story) {
    final List<String> mediaItems = story.mediaItems.isNotEmpty
        ? story.mediaItems
        : (story.media.trim().isNotEmpty ? <String>[story.media] : <String>[]);
    if (mediaItems.length == 1 && _looksLikeVideo(mediaItems.first)) {
      return const Duration(seconds: 8);
    }
    return _defaultStoryDuration;
  }

  double _progressForIndex(int index) {
    if (index < _controller.currentIndex) {
      return 1;
    }
    if (index > _controller.currentIndex) {
      return 0;
    }
    return _storyProgress.clamp(0, 1);
  }
}
