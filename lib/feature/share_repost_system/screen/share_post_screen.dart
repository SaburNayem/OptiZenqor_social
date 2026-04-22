import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../core/data/mock/mock_data.dart';
import '../../../core/data/models/post_model.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../home_feed/controller/create_post_controller.dart';
import '../../home_feed/controller/home_feed_controller.dart';
import '../../home_feed/widget/create_post_action_tile.dart';
import '../../home_feed/widget/create_post_composer_card.dart';
import '../widget/share_source_post_card.dart';

class SharePostScreen extends StatefulWidget {
  const SharePostScreen({
    super.key,
    required this.post,
    required this.author,
  });

  final PostModel post;
  final UserModel author;

  @override
  State<SharePostScreen> createState() => _SharePostScreenState();
}

class _SharePostScreenState extends State<SharePostScreen> {
  late final CreatePostController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CreatePostController()
      ..mediaPaths = List<String>.from(widget.post.media)
      ..isVideo = widget.post.media.length == 1 && _isVideoPath(widget.post.media.firstOrNull ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserModel currentUser = MockData.users.first;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: AppColors.black87),
              onPressed: AppGet.back,
            ),
            title: const Text(
              'Share Post',
              style: TextStyle(
                color: AppColors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
                child: SizedBox(
                  width: 88,
                  child: ElevatedButton(
                    onPressed: _submitShare,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.hexFF26C6DA,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      'Share',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    CreatePostComposerCard(
                      avatarUrl: currentUser.avatar,
                      userName: currentUser.name,
                      audience: _controller.audience,
                      captionController: _controller.captionController,
                      onAudienceTap: () => _controller.pickPrivacy(context),
                    ),
                    const SizedBox(height: 18),
                    ShareSourcePostCard(
                      post: widget.post,
                      author: widget.author,
                    ),
                    const SizedBox(height: 24),
                    CreatePostActionTile(
                      icon: Icons.location_on_outlined,
                      label: _controller.location == null
                          ? 'Check in'
                          : 'Location: ${_controller.location}',
                      bgColor: AppColors.hexFFE3F2FD,
                      iconColor: AppColors.hexFF42A5F5,
                      onTap: () => _controller.pickLocation(context),
                    ),
                    CreatePostActionTile(
                      icon: Icons.sentiment_satisfied_alt_outlined,
                      label: _controller.feeling == null
                          ? 'Feeling / Activity'
                          : 'Feeling: ${_controller.feeling}',
                      bgColor: AppColors.hexFFFFFDE7,
                      iconColor: AppColors.hexFFFFD600,
                      onTap: () => _controller.pickFeeling(context),
                    ),
                    CreatePostActionTile(
                      icon: Icons.person_add_alt_1_outlined,
                      label: _controller.taggedPeople.isEmpty
                          ? 'Tag People'
                          : 'Tagged: ${_controller.taggedPeople.join(', ')}',
                      bgColor: AppColors.hexFFF3E5F5,
                      iconColor: AppColors.hexFF8E24AA,
                      onTap: () => _controller.pickTaggedPeople(context),
                    ),
                    CreatePostActionTile(
                      icon: Icons.group_add_outlined,
                      label: _controller.coAuthors.isEmpty
                          ? 'Add collaborators'
                          : 'Collaborators: ${_controller.coAuthors.join(', ')}',
                      bgColor: AppColors.hexFFE0F7FA,
                      iconColor: AppColors.hexFF00ACC1,
                      onTap: () => _controller.pickCoAuthors(context),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border(top: BorderSide(color: AppColors.grey100)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.hexFF26C6DA,
                      ),
                      onPressed: () => _controller.pickLocation(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.tag, color: AppColors.hexFF26C6DA),
                      onPressed: () => _controller.pickTaggedPeople(context),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.sentiment_satisfied_alt_outlined,
                        color: AppColors.hexFF26C6DA,
                      ),
                      onPressed: () => _controller.pickFeeling(context),
                    ),
                    const Spacer(),
                    Text(
                      '${_controller.captionController.text.length} / 280',
                      style: const TextStyle(
                        color: AppColors.grey,
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
    );
  }

  Future<void> _submitShare() async {
    final HomeFeedController homeFeedController = context.read<HomeFeedController>();
    final String note = _controller.captionController.text.trim();
    final String sourceCaption = widget.post.caption.trim();
    final String mergedCaption = note.isEmpty
        ? 'Shared from @${widget.author.username}: $sourceCaption'
        : '$note\n\nShared from @${widget.author.username}: $sourceCaption';

    await homeFeedController.createLocalPost(
      caption: mergedCaption,
      mediaPaths: widget.post.media,
      isVideo: widget.post.media.length == 1 && _isVideoPath(widget.post.media.firstOrNull ?? ''),
      audience: _controller.audience,
      location: _controller.location,
      taggedPeople: _controller.taggedPeople,
      coAuthors: _controller.coAuthors,
      altText: widget.post.altText,
      editHistory: <String>[
        'Shared from @${widget.author.username}',
        if (_controller.feeling != null) 'Feeling: ${_controller.feeling}',
      ],
    );
    if (!mounted) {
      return;
    }
    AppGet.back();
    AppGet.snackbar('Shared', 'Post shared to your feed');
  }

  bool _isVideoPath(String path) {
    final String lower = path.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.m4v') ||
        lower.endsWith('.webm');
  }
}
