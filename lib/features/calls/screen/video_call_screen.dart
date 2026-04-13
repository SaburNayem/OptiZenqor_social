import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class VideoCallScreen extends StatelessWidget {
  const VideoCallScreen({
    required this.name,
    required this.avatarUrl,
    super.key,
  });

  final String name;
  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              avatarUrl,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.black.withValues(alpha: 0.45),
                    AppColors.transparent,
                    AppColors.black.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.white,
                        ),
                      ),
                      const Spacer(),
                      Column(
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Video call • 01:08',
                            style: TextStyle(color: AppColors.white70),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      width: 110,
                      height: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.white24),
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.black.withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _VideoAction(
                          icon: Icons.mic_off_outlined,
                          backgroundColor: AppColors.white.withValues(alpha: 0.12),
                        ),
                        _VideoAction(
                          icon: Icons.videocam_off_outlined,
                          backgroundColor: AppColors.white.withValues(alpha: 0.12),
                        ),
                        _VideoAction(
                          icon: Icons.flip_camera_ios_outlined,
                          backgroundColor: AppColors.white.withValues(alpha: 0.12),
                        ),
                        const _VideoAction(
                          icon: Icons.call_end_rounded,
                          backgroundColor: AppColors.hexFFE53935,
                          size: 64,
                        ),
                      ],
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
}

class _VideoAction extends StatelessWidget {
  const _VideoAction({
    required this.icon,
    required this.backgroundColor,
    this.size = 54,
  });

  final IconData icon;
  final Color backgroundColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.white, size: size * 0.42),
    );
  }
}

