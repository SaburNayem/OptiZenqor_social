import 'package:flutter/material.dart';

import '../../../core/common_data/mock_data.dart';
import '../../../core/helpers/format_helper.dart';
import '../../../core/widgets/inline_video_player.dart';
import '../controller/reels_controller.dart';

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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {},
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Following',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              width: 1,
              height: 16,
              color: Colors.white30,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'For You',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
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
              final user = MockData.users
                  .where((item) => item.id == reel.authorId)
                  .firstOrNull;

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
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
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
                              '@${user?.name.split(' ').first ?? 'Sara'}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFF26C6DA),
                              size: 18,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${user?.name ?? 'Sara'} is an Indian Model with impressive portfolio and was best model and ramp walk in 2018.',
                          style: const TextStyle(
                            color: Colors.white,
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
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: CircleAvatar(
                                radius: 22,
                                backgroundImage: NetworkImage(user?.avatar ?? ''),
                                backgroundColor: Colors.black,
                                child: user?.avatar == null 
                                  ? const Text('S', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                                  : null,
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
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
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
                          label: '143.5k',
                          onTap: () {},
                        ),
                        _ReelAction(
                          icon: Icons.chat_bubble_outline,
                          label: '42.6k',
                          onTap: () {},
                        ),
                        _ReelAction(
                          icon: Icons.share_outlined,
                          label: '3.2k',
                          onTap: () {},
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
  const _ReelAction({
    required this.icon,
    required this.label,
    this.onTap,
  });

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
            icon: Icon(icon, color: Colors.white, size: 32),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
