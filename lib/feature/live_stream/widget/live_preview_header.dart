import 'package:flutter/material.dart';

import '../controller/live_stream_controller.dart';
import '../model/live_stream_model.dart';
import 'live_audience_chip.dart';

class LivePreviewHeader extends StatelessWidget {
  const LivePreviewHeader({
    required this.controller,
    required this.onBack,
    required this.onPrivacyTap,
    super.key,
  });

  final LiveStreamController controller;
  final VoidCallback onBack;
  final VoidCallback onPrivacyTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(
          children: [
            Row(
              children: [
                _TopIconButton(icon: Icons.arrow_back_ios_new_rounded, onTap: onBack),
                const Spacer(),
                const Text(
                  'Live video',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _TopIconButton(
                  icon: controller.frontCamera
                      ? Icons.cameraswitch_outlined
                      : Icons.camera_rear_outlined,
                  onTap: controller.toggleCamera,
                ),
                const SizedBox(width: 8),
                _TopIconButton(
                  icon: controller.flashEnabled
                      ? Icons.flash_on_rounded
                      : Icons.flash_off_rounded,
                  onTap: controller.toggleFlash,
                ),
                const SizedBox(width: 8),
                _TopIconButton(
                  icon: Icons.settings_outlined,
                  onTap: controller.pulseSettings,
                  active: controller.settingsHighlighted,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                LiveAudienceChip(
                  label: _audienceLabel(controller.audience),
                  leading: Icons.public_rounded,
                  onTap: onPrivacyTap,
                  selected: true,
                ),
                const SizedBox(width: 8),
                LiveAudienceChip(
                  label: '${controller.viewerCount} watching',
                  leading: Icons.visibility_outlined,
                  onTap: () {},
                ),
                const SizedBox(width: 8),
                if (controller.isLive)
                  _LiveBadge(duration: controller.formattedDuration),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _audienceLabel(LiveAudienceVisibility value) {
    switch (value) {
      case LiveAudienceVisibility.public:
        return 'Public';
      case LiveAudienceVisibility.friends:
        return 'Friends';
      case LiveAudienceVisibility.onlyMe:
        return 'Only me';
    }
  }
}

class _TopIconButton extends StatelessWidget {
  const _TopIconButton({
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active
          ? const Color(0xFF26C6DA).withValues(alpha: 0.24)
          : Colors.black.withValues(alpha: 0.28),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _LiveBadge extends StatefulWidget {
  const _LiveBadge({required this.duration});

  final String duration;

  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.55, end: 1).animate(_controller),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.fiber_manual_record, color: Colors.white, size: 10),
            const SizedBox(width: 6),
            const Text(
              'LIVE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.duration,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
