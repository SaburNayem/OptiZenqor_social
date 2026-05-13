import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../../core/constants/app_colors.dart';
import '../controller/call_session_controller.dart';
import '../model/call_item_model.dart';
import 'audio_call_screen.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({
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
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
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
          mode: CallType.video,
        );
    if (_ownsController) {
      unawaited(_controller.initialize());
    } else {
      unawaited(_controller.enableVideoIfNeeded());
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
          backgroundColor: AppColors.black,
          body: Stack(
            children: <Widget>[
              Positioned.fill(
                child: _controller.remoteRenderer.srcObject != null
                    ? RTCVideoView(
                        _controller.remoteRenderer,
                        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      )
                    : Container(
                        color: AppColors.hexFF0E1A24,
                        alignment: Alignment.center,
                        child: Text(
                          _controller.callState == 'ringing'
                              ? 'Ringing...'
                              : 'Waiting for video',
                          style: const TextStyle(
                            color: AppColors.white70,
                            fontSize: 18,
                          ),
                        ),
                      ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
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
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          IconButton(
                            onPressed: _endCall,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.white,
                            ),
                          ),
                          const Spacer(),
                          Column(
                            children: <Widget>[
                              Text(
                                widget.name,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_controller.statusLabel} • ${_controller.durationLabel}',
                                style: const TextStyle(color: AppColors.white70),
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
                          width: 118,
                          height: 172,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: _controller.isCameraOff
                                ? AppColors.black.withValues(alpha: 0.55)
                                : AppColors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _controller.isFrontCamera
                                  ? AppColors.white24
                                  : AppColors.hexFF26C6DA,
                            ),
                          ),
                          child: _controller.isCameraOff ||
                                  _controller.localRenderer.srcObject == null
                              ? const Center(
                                  child: Icon(
                                    Icons.videocam_off_outlined,
                                    color: AppColors.white70,
                                    size: 32,
                                  ),
                                )
                              : RTCVideoView(
                                  _controller.localRenderer,
                                  mirror: _controller.isFrontCamera,
                                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                                ),
                        ),
                      ),
                      const Spacer(),
                      if (_controller.isRemoteCameraOff)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Other camera is off',
                            style: TextStyle(
                              color: AppColors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.black.withValues(alpha: 0.28),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            _VideoAction(
                              icon: _controller.isMuted
                                  ? Icons.mic_off_outlined
                                  : Icons.mic_none_rounded,
                              backgroundColor: _controller.isMuted
                                  ? AppColors.hexFF26C6DA
                                  : AppColors.white.withValues(alpha: 0.12),
                              onTap: _controller.toggleMute,
                            ),
                            _VideoAction(
                              icon: _controller.isCameraOff
                                  ? Icons.videocam_off_outlined
                                  : Icons.videocam_outlined,
                              backgroundColor: _controller.isCameraOff
                                  ? AppColors.hexFF26C6DA
                                  : AppColors.white.withValues(alpha: 0.12),
                              onTap: _controller.toggleCamera,
                            ),
                            _VideoAction(
                              icon: Icons.flip_camera_ios_outlined,
                              backgroundColor: !_controller.isFrontCamera
                                  ? AppColors.hexFF26C6DA
                                  : AppColors.white.withValues(alpha: 0.12),
                              onTap: _controller.switchCamera,
                            ),
                            _VideoAction(
                              icon: _controller.isSpeakerOn
                                  ? Icons.volume_up_outlined
                                  : Icons.hearing_outlined,
                              backgroundColor: _controller.isSpeakerOn
                                  ? AppColors.hexFF26C6DA
                                  : AppColors.white.withValues(alpha: 0.12),
                              onTap: _controller.toggleSpeaker,
                            ),
                            _VideoAction(
                              icon: Icons.call_rounded,
                              backgroundColor: AppColors.white.withValues(
                                alpha: 0.12,
                              ),
                              onTap: () => Navigator.of(context).pushReplacement(
                                MaterialPageRoute<void>(
                                  builder: (_) => AudioCallScreen(
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
                            _VideoAction(
                              icon: Icons.call_end_rounded,
                              backgroundColor: AppColors.hexFFE53935,
                              size: 64,
                              onTap: _endCall,
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
      },
    );
  }
}

class _VideoAction extends StatelessWidget {
  const _VideoAction({
    required this.icon,
    required this.backgroundColor,
    required this.onTap,
    this.size = 54,
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
          child: Icon(icon, color: AppColors.white, size: size * 0.42),
        ),
      ),
    );
  }
}
