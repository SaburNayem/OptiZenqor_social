import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class InlineVideoPlayer extends StatefulWidget {
  const InlineVideoPlayer({
    super.key,
    this.networkUrl,
    this.filePath,
    this.autoPlay = false,
    this.looping = true,
  });

  final String? networkUrl;
  final String? filePath;
  final bool autoPlay;
  final bool looping;

  @override
  State<InlineVideoPlayer> createState() => _InlineVideoPlayerState();
}

class _InlineVideoPlayerState extends State<InlineVideoPlayer> {
  VideoPlayerController? _controller;
  bool _initializing = true;
  bool _muted = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final filePath = widget.filePath;
    final networkUrl = widget.networkUrl;

    if (filePath != null && filePath.isNotEmpty) {
      _controller = VideoPlayerController.file(File(filePath));
    } else if (networkUrl != null && networkUrl.isNotEmpty) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(networkUrl));
    }

    if (_controller == null) {
      if (mounted) {
        setState(() {
          _initializing = false;
        });
      }
      return;
    }

    await _controller!.initialize();
    await _controller!.setLooping(widget.looping);
    await _controller!.setVolume(0);
    if (widget.autoPlay) {
      await _controller!.play();
    }

    if (mounted) {
      setState(() {
        _initializing = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      return const Center(child: CircularProgressIndicator());
    }
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(child: Text('Video unavailable'));
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: VideoPlayer(controller),
        ),
        VideoProgressIndicator(
          controller,
          allowScrubbing: true,
          padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
        ),
        Positioned(
          left: 8,
          bottom: 26,
          child: IconButton(
            onPressed: () {
              if (controller.value.isPlaying) {
                controller.pause();
              } else {
                controller.play();
              }
              setState(() {});
            },
            icon: Icon(
              controller.value.isPlaying ? Icons.pause_circle : Icons.play_circle,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        Positioned(
          right: 8,
          bottom: 26,
          child: IconButton(
            onPressed: () {
              _muted = !_muted;
              controller.setVolume(_muted ? 0 : 1);
              setState(() {});
            },
            icon: Icon(
              _muted ? Icons.volume_off : Icons.volume_up,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
