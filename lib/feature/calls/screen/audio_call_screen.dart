import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_avatar.dart';
import '../controller/call_session_controller.dart';
import '../model/call_item_model.dart';
import 'video_call_screen.dart';

class AudioCallScreen extends StatefulWidget {
  const AudioCallScreen({
    required this.name,
    required this.avatarUrl,
    super.key,
    this.recipientId,
    this.sessionId,
    this.connectedAt,
    this.controller,
  });

  final String name;
  final String avatarUrl;
  final String? recipientId;
  final String? sessionId;
  final DateTime? connectedAt;
  final CallSessionController? controller;

  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  late final CallSessionController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller =
        widget.controller ??
        CallSessionController(
          displayName: widget.name,
          avatarUrl: widget.avatarUrl,
          recipientId: widget.recipientId,
          sessionId: widget.sessionId,
          connectedAt: widget.connectedAt,
          mode: CallType.voice,
        );
    if (_ownsController) {
      unawaited(_controller.initialize());
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _endCall() async {
    await _controller.endCall();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, _) {
        return Scaffold(
          backgroundColor: AppColors.hexFF0E1A24,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        onPressed: _endCall,
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.white,
                        ),
                      ),
                      Text(
                        _controller.sessionId == null
                            ? 'Starting secure call'
                            : 'Call session live',
                        style: const TextStyle(
                          color: AppColors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const Spacer(),
                  Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      AppAvatar(imageUrl: widget.avatarUrl, radius: 72),
                      if (_controller.callState == 'ringing')
                        Container(
                          width: 176,
                          height: 176,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.hexFF26C6DA.withValues(
                                alpha: 0.25,
                              ),
                              width: 2,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.name,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _controller.statusLabel,
                    style: const TextStyle(color: AppColors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _controller.durationLabel,
                    style: const TextStyle(color: AppColors.white54, fontSize: 14),
                  ),
                  if (_controller.isRemoteMuted) ...<Widget>[
                    const SizedBox(height: 14),
                    const Text(
                      'Other microphone is muted',
                      style: TextStyle(color: AppColors.white54, fontSize: 12),
                    ),
                  ],
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        _CallControl(
                          icon: _controller.isMuted
                              ? Icons.mic_off_outlined
                              : Icons.mic_none_rounded,
                          label: 'Mute',
                          active: _controller.isMuted,
                          onTap: _controller.toggleMute,
                        ),
                        _CallControl(
                          icon: _controller.isSpeakerOn
                              ? Icons.volume_up_outlined
                              : Icons.hearing_outlined,
                          label: 'Speaker',
                          active: _controller.isSpeakerOn,
                          onTap: _controller.toggleSpeaker,
                        ),
                        _CallControl(
                          icon: Icons.graphic_eq_rounded,
                          label: _controller.callState == 'ringing'
                              ? 'Ringing'
                              : 'Live',
                          active: _controller.callState == 'connected',
                          onTap: null,
                        ),
                        _CallControl(
                          icon: Icons.videocam_outlined,
                          label: 'Video',
                          onTap: () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute<void>(
                              builder: (_) => VideoCallScreen(
                                name: widget.name,
                                avatarUrl: widget.avatarUrl,
                                recipientId: widget.recipientId,
                                sessionId: _controller.sessionId,
                                connectedAt: _controller.connectedAt,
                                controller: _controller,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _ActionButton(
                        icon: Icons.call_end_rounded,
                        backgroundColor: AppColors.hexFFE53935,
                        size: 72,
                        onTap: _endCall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CallControl extends StatelessWidget {
  const _CallControl({
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              color: active ? AppColors.hexFF26C6DA : AppColors.white,
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: active ? AppColors.hexFF26C6DA : AppColors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.backgroundColor,
    required this.onTap,
    this.size = 58,
  });

  final IconData icon;
  final Color backgroundColor;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.white, size: size * 0.4),
        ),
      ),
    );
  }
}
