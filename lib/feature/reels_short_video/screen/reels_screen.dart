import 'package:flutter/material.dart';

import '../../../core/common_data/mock_data.dart';
import '../../../core/helpers/format_helper.dart';
import '../controller/reels_controller.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final ReelsController _controller = ReelsController();

  @override
  void initState() {
    super.initState();
    _controller.load();
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
      builder: (context, child) {
        if (_controller.reels.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return PageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: _controller.reels.length,
          itemBuilder: (context, index) {
            final reel = _controller.reels[index];
            final user = MockData.users
                .where((item) => item.id == reel.authorId)
                .firstOrNull;

            return Stack(
              fit: StackFit.expand,
              children: [
                Image.network(reel.thumbnail, fit: BoxFit.cover),
                DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black54, Colors.black87],
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 90,
                  bottom: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '@${user?.username ?? 'unknown'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        reel.caption,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reel.audioName,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 12,
                  bottom: 24,
                  child: Column(
                    children: [
                      _ReelAction(
                        icon: _controller.isLiked(reel.id)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        label: _controller.likeCount(reel),
                        onTap: () {
                          _controller.toggleLike(reel.id);
                        },
                      ),
                      _ReelAction(
                        icon: Icons.mode_comment,
                        label: _controller.commentCount(reel),
                        onTap: () {
                          _controller.addComment(reel.id);
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              const SnackBar(content: Text('Comment action triggered')),
                            );
                        },
                      ),
                      _ReelAction(
                        icon: Icons.share,
                        label: _controller.shareCount(reel),
                        onTap: () {
                          _controller.addShare(reel.id);
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              const SnackBar(content: Text('Reel shared')),
                            );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ReelAction extends StatelessWidget {
  const _ReelAction({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final int label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white24,
            child: IconButton(
              onPressed: onTap,
              icon: Icon(icon, color: Colors.white),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            FormatHelper.formatCompactNumber(label),
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
