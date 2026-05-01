import 'package:flutter/material.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../live_stream/screen/live_broadcast_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../controller/create_post_controller.dart';
import '../widget/create_post_action_tile.dart';
import '../widget/create_post_bottom_toolbar.dart';
import '../widget/create_post_composer_card.dart';
import '../widget/create_post_media_preview.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  late final CreatePostController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CreatePostController();
    _controller.loadContext();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final currentUser = _controller.currentUser;
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
              'New Post',
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
                    onPressed: _controller.canShare ? _submit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.hexFF26C6DA,
                      foregroundColor: AppColors.white,
                      disabledBackgroundColor: AppColors.hexFF26C6DA.withValues(
                        alpha: 0.32,
                      ),
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
                      attachmentPreview: _controller.mediaPaths.isEmpty
                          ? null
                          : CreatePostMediaPreview(
                              mediaPaths: _controller.mediaPaths,
                              hasAnyVideo: _controller.hasAnyVideo,
                              isVideoPath: _isVideoPath,
                              onReplaceTap: () =>
                                  _controller.showMediaPickerSheet(context),
                              onRemoveTap: _controller.clearMedia,
                            ),
                    ),
                    const SizedBox(height: 20),
                    CreatePostActionTile(
                      icon: Icons.add_photo_alternate,
                      label: _controller.mediaPaths.isEmpty
                          ? 'Photo / Video'
                          : 'Add more photo / video',
                      bgColor: AppColors.hexFFE8F5E9,
                      iconColor: AppColors.hexFF4CAF50,
                      onTap: () => _controller.showMediaPickerSheet(context),
                    ),
                    CreatePostActionTile(
                      icon: Icons.wifi_tethering_outlined,
                      label: 'Go Live',
                      bgColor: AppColors.hexFFFFF3E0,
                      iconColor: AppColors.hexFFFF7043,
                      onTap: _goLive,
                    ),
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
                    if (_controller.mediaPaths.isNotEmpty &&
                        !_controller.hasAnyVideo)
                      CreatePostActionTile(
                        icon: Icons.image_search_outlined,
                        label: _controller.altText == null
                            ? 'Add alt text'
                            : 'Alt text added',
                        bgColor: AppColors.hexFFFFF3E0,
                        iconColor: AppColors.hexFFFB8C00,
                        onTap: () => _controller.editAltText(context),
                      ),
                  ],
                ),
              ),
              CreatePostBottomToolbar(
                captionLength: _controller.captionController.text.length,
                onMediaTap: () => _controller.showMediaPickerSheet(context),
                onTagTap: () => _controller.pickTaggedPeople(context),
                onFeelingTap: () => _controller.pickFeeling(context),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isVideoPath(String path) {
    return path.toLowerCase().endsWith('.mp4') ||
        path.toLowerCase().endsWith('.mov') ||
        path.toLowerCase().endsWith('.m4v') ||
        path.toLowerCase().endsWith('.webm');
  }

  void _submit() {
    if (!_controller.canShare) {
      return;
    }
    AppGet.back(result: _controller.buildResult());
  }

  Future<void> _goLive() async {
    if (_controller.mediaPaths.length > 1) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Go Live allows only one photo.')),
        );
      return;
    }
    if (_controller.hasAnyVideo) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Video is not allowed for Go Live.')),
        );
      return;
    }
    final currentUser = _controller.currentUser;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LiveBroadcastScreen(
          initialTitle: _controller.liveTitleFor(currentUser.name),
          initialPhotoPath: _controller.mediaPaths.isEmpty
              ? null
              : _controller.mediaPaths.first,
          initialAudience: _controller.liveAudienceVisibility,
        ),
      ),
    );
  }
}
