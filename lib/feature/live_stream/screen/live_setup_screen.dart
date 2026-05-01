import 'dart:io';

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'live_broadcast_screen.dart';

class LiveSetupScreen extends StatelessWidget {
  const LiveSetupScreen({
    required this.name,
    required this.avatarUrl,
    required this.privacy,
    required this.caption,
    this.photoPath,
    super.key,
  });

  final String name;
  final String avatarUrl;
  final String privacy;
  final String caption;
  final String? photoPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: photoPath != null
                ? Image.file(File(photoPath!), fit: BoxFit.cover)
                : Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.hexFF122033,
                          AppColors.hexFF1D6FA3,
                          AppColors.hexFF26C6DA,
                        ],
                      ),
                    ),
                  ),
          ),
          Positioned.fill(
            child: Container(color: AppColors.black.withValues(alpha: 0.28)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppColors.white,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.red,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'LIVE',
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(avatarUrl),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                            Text(
                              privacy,
                              style: const TextStyle(
                                color: AppColors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (caption.trim().isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.black.withValues(alpha: 0.32),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        caption,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                    ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.white,
                            side: const BorderSide(color: AppColors.white38),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(Icons.flip_camera_ios_outlined),
                          label: const Text('Flip'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.white,
                            side: const BorderSide(color: AppColors.white38),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(Icons.auto_awesome_outlined),
                          label: const Text('Effects'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => LiveBroadcastScreen(
                              initialTitle: caption,
                              initialPhotoPath: photoPath,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Start Live Video',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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
