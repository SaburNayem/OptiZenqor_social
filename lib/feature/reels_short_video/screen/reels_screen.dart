import 'package:flutter/material.dart';

import '../../../core/common_widget/inline_video_player.dart';
import '../controller/reels_controller.dart';
import '../../../core/constants/app_colors.dart';

class ReelsScreen extends StatelessWidget {
  ReelsScreen({super.key}) {
    _controller.load();
  }

  final ReelsController _controller = ReelsController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Following',
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.7),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              width: 1,
              height: 16,
              color: AppColors.white30,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'For You',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: AppColors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          if (_controller.reels.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: _controller.reels.length,
            itemBuilder: (context, index) {
              final reel = _controller.reels[index];
              final String authorLabel = reel.authorId.trim().isEmpty
                  ? 'Creator'
                  : reel.authorId;

              return Stack(
                fit: StackFit.expand,
                children: [
                  // Video Background
                  if (reel.videoUrl != null && reel.videoUrl!.isNotEmpty)
                    InlineVideoPlayer(networkUrl: reel.videoUrl, autoPlay: true)
                  else
                    Image.network(reel.thumbnail, fit: BoxFit.cover),

                  // Overlay Gradient
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.black.withValues(alpha: 0.3),
                          AppColors.transparent,
                          AppColors.transparent,
                          AppColors.black.withValues(alpha: 0.5),
                        ],
                        stops: const [0.0, 0.2, 0.7, 1.0],
                      ),
                    ),
                  ),

                  // Content (Username, Caption)
                  Positioned(
                    left: 16,
                    right: 80,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '@$authorLabel',
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.hexFF26C6DA,
                              size: 18,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          reel.caption.isEmpty
                              ? 'No caption available for this reel.'
                              : reel.caption,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right Side Actions
                  Positioned(
                    right: 12,
                    bottom: 40,
                    child: Column(
                      children: [
                        // Profile with plus icon
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.white,
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 22,
                                backgroundImage: NetworkImage(
                                  'https://placehold.co/120x120',
                                ),
                                backgroundColor: AppColors.black,
                                child: const Text(
                                  'C',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -8,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: AppColors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: AppColors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _ReelAction(
                          icon: Icons.favorite,
                          label: '${_controller.likeCount(reel)}',
                          onTap: () => _controller.toggleLike(reel.id),
                        ),
                        _ReelAction(
                          icon: Icons.chat_bubble_outline,
                          label: '${_controller.commentCount(reel)}',
                          onTap: () => _controller.addComment(reel.id),
                        ),
                        _ReelAction(
                          icon: Icons.share_outlined,
                          label: '${_controller.shareCount(reel)}',
                          onTap: () => _controller.addShare(reel.id),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _ReelAction extends StatelessWidget {
  const _ReelAction({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          IconButton(
            onPressed: onTap,
            icon: Icon(icon, color: AppColors.white, size: 32),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
