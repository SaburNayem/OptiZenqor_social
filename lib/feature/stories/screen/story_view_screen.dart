import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app_route/route_names.dart';
import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/models/story_model.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/data/service/api_client_service.dart';
import '../../../core/functions/app_feedback.dart';
import '../../../core/navigation/app_get.dart';
import '../controller/stories_controller.dart';
import '../../../core/constants/app_colors.dart';

class StoryViewScreen extends StatefulWidget {
  const StoryViewScreen({
    required this.stories,
    required this.users,
    required this.initialStoryId,
    this.onStoriesSeen,
    super.key,
  });

  final List<StoryModel> stories;
  final List<UserModel> users;
  final String initialStoryId;
  final ValueChanged<List<String>>? onStoriesSeen;

  @override
  State<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen> {
  late StoriesController _controller;
  final ApiClientService _apiClient = ApiClientService();
  List<UserModel> _viewers = <UserModel>[];
  final Set<String> _seenStoryIds = <String>{};

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
    _markCurrentStorySeen();
    _loadViewersForCurrentStory();
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
                onPageChanged: (int index) {
                  _controller.onPageChanged(index);
                  _markCurrentStorySeen();
                  _loadViewersForCurrentStory();
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
                          IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              color: AppColors.white,
                            ),
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                          AppAvatar(
                            imageUrl:
                                _getUser(
                                  _controller.stories[_controller.currentIndex],
                                )?.avatar ??
                                '',
                            radius: 18,
                          ),
                          const SizedBox(width: 8),
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
                            _timeLabelFor(
                              _controller.stories[_controller.currentIndex],
                            ),
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
                          onPressed: _showViewersSheet,
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
                                'Reply to story',
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
    return story.author ??
        widget.users.where((u) => u.id == story.userId).firstOrNull;
  }

  void _markCurrentStorySeen() {
    final StoryModel story = _controller.stories[_controller.currentIndex];
    if (story.id.isEmpty || !_seenStoryIds.add(story.id)) {
      return;
    }
    widget.onStoriesSeen?.call(<String>[story.id]);
  }

  Future<void> _goPrevious() async {
    if (_controller.currentIndex <= 0) {
      return;
    }
    await _controller.pageController.previousPage(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }

  Future<void> _goNext() async {
    if (_controller.currentIndex >= _controller.stories.length - 1) {
      if (mounted) {
        Navigator.of(context).maybePop();
      }
      return;
    }
    await _controller.pageController.nextPage(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }

  Future<void> _loadViewersForCurrentStory() async {
    final StoryModel story = _controller.stories[_controller.currentIndex];
    try {
      final response = await _apiClient.get(ApiEndPoints.storyViewers(story.id));
      if (!response.isSuccess || response.data['success'] == false) {
        if (mounted) {
          setState(() {
            _viewers = <UserModel>[];
          });
        }
        return;
      }
      final List<UserModel> viewers = _readMapList(response.data)
          .map(UserModel.fromApiJson)
          .where((UserModel user) => user.id.isNotEmpty)
          .toList(growable: false);
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

  Future<void> _showViewersSheet() async {
    await _loadViewersForCurrentStory();
    if (!mounted) {
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        if (_viewers.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Text('No viewers yet.'),
          );
        }
        return ListView.separated(
          shrinkWrap: true,
          itemCount: _viewers.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (BuildContext context, int index) {
            final UserModel viewer = _viewers[index];
            return ListTile(
              leading: AppAvatar(
                imageUrl: viewer.avatar,
                radius: 18,
              ),
              title: Text(viewer.name),
              subtitle: Text('@${viewer.username}'),
            );
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _readMapList(Map<String, dynamic> payload) {
    for (final Object? raw in <Object?>[
      payload['data'],
      payload['items'],
      payload['results'],
      _readMap(payload['data'])?['items'],
      _readMap(payload['data'])?['results'],
    ]) {
      if (raw is! List) {
        continue;
      }
      return raw
          .whereType<Object>()
          .map((Object item) => item is Map<String, dynamic>
              ? item
              : Map<String, dynamic>.from(item as Map))
          .toList(growable: false);
    }
    return const <Map<String, dynamic>>[];
  }

  Map<String, dynamic>? _readMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  Widget _buildStoryContent(StoryModel story) {
    final List<Color> backgroundColors = story.backgroundColors.length >= 2
        ? story.backgroundColors.map(Color.new).toList(growable: false)
        : const <Color>[AppColors.hexFF1E40AF, AppColors.hexFF2BB0A1];
    final List<String> mediaItems = story.mediaItems.isNotEmpty
        ? story.mediaItems
        : (story.media.trim().isNotEmpty ? <String>[story.media] : <String>[]);

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
          if (mediaItems.isNotEmpty) _buildStoryMedia(story, mediaItems),
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
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildStoryChip(
                          icon: Icons.shield_outlined,
                          label: story.privacy,
                        ),
                        if ((story.effectName ?? '').trim().isNotEmpty)
                          _buildStoryChip(
                            icon: Icons.auto_awesome_rounded,
                            label: story.effectName!,
                          ),
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
                        if ((story.linkUrl ?? '').trim().isNotEmpty)
                          GestureDetector(
                            onTap: () => _openStoryLink(story),
                            child: _buildStoryChip(
                              icon: Icons.link_rounded,
                              label: (story.linkLabel ?? '').trim().isNotEmpty
                                  ? story.linkLabel!
                                  : story.linkUrl!,
                            ),
                          ),
                      ],
                    ),
                    if ((story.effectName ?? '').trim().isNotEmpty ||
                        (story.sticker ?? '').trim().isNotEmpty ||
                        (story.mentionUsername ?? '').trim().isNotEmpty ||
                        (story.linkUrl ?? '').trim().isNotEmpty)
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

  Widget _buildStoryMediaItem(StoryModel story, String path) {
    if (story.isLocalFile) {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image_outlined, color: AppColors.white),
      );
    }
    return Image.network(
      path,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.broken_image_outlined, color: AppColors.white),
    );
  }

  Widget _buildStoryChip({
    required IconData icon,
    required String label,
  }) {
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
      message: 'Story share text copied',
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
}

