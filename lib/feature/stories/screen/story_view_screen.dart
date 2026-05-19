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

part 'story_view_content_widgets.dart';

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
    return storyId.isNotEmpty;
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
