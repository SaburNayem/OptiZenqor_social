import 'package:flutter/material.dart';

class AudioCallScreen extends StatelessWidget {
  const AudioCallScreen({
    required this.name,
    required this.avatarUrl,
    super.key,
  });

  final String name;
  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1A24),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.white),
                  ),
                  const Text(
                    'End-to-end encrypted',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const Spacer(),
              CircleAvatar(
                radius: 72,
                backgroundImage: NetworkImage(avatarUrl),
              ),
              const SizedBox(height: 24),
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Calling...',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 12),
              const Text(
                '00:14',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _CallControl(icon: Icons.mic_off_outlined, label: 'Mute'),
                    _CallControl(icon: Icons.volume_up_outlined, label: 'Speaker'),
                    _CallControl(icon: Icons.bluetooth_audio_outlined, label: 'Audio'),
                    _CallControl(icon: Icons.add_reaction_outlined, label: 'React'),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionButton(
                    icon: Icons.message_outlined,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                  ),
                  _ActionButton(
                    icon: Icons.call_end_rounded,
                    backgroundColor: const Color(0xFFE53935),
                    size: 72,
                  ),
                  _ActionButton(
                    icon: Icons.videocam_outlined,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CallControl extends StatelessWidget {
  const _CallControl({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.backgroundColor,
    this.size = 58,
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
      child: Icon(icon, color: Colors.white, size: size * 0.4),
    );
  }
}
