import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../model/live_stream_model.dart';

class LiveReactionOverlay extends StatefulWidget {
  const LiveReactionOverlay({
    required this.enabled,
    required this.active,
    required this.reactionBuilder,
    super.key,
  });

  final bool enabled;
  final bool active;
  final List<LiveReactionModel> Function() reactionBuilder;

  @override
  State<LiveReactionOverlay> createState() => _LiveReactionOverlayState();
}

class _LiveReactionOverlayState extends State<LiveReactionOverlay> {
  final Random _random = Random();
  final List<_FloatingReaction> _items = <_FloatingReaction>[];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _syncTimer();
  }

  @override
  void didUpdateWidget(covariant LiveReactionOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled || oldWidget.active != widget.active) {
      _syncTimer();
    }
  }

  void _syncTimer() {
    _timer?.cancel();
    if (!widget.enabled || !widget.active) {
      if (mounted) {
        setState(_items.clear);
      }
      return;
    }
    _timer = Timer.periodic(const Duration(milliseconds: 1400), (_) {
      final batch = widget.reactionBuilder();
      if (!mounted) {
        return;
      }
      setState(() {
        _items.addAll(
          batch.map(
            (item) => _FloatingReaction(
              id: item.id,
              type: item.type,
              leftFactor: 0.68 + (_random.nextDouble() * 0.24),
              size: 20 + _random.nextDouble() * 10,
            ),
          ),
        );
      });
      Future<void>.delayed(const Duration(milliseconds: 2600), () {
        if (!mounted) {
          return;
        }
        setState(() {
          _items.removeWhere((element) => batch.any((item) => item.id == element.id));
        });
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: _items.map((item) {
          return AnimatedPositioned(
            key: ValueKey(item.id),
            duration: const Duration(milliseconds: 2400),
            curve: Curves.easeOutCubic,
            left: MediaQuery.of(context).size.width * item.leftFactor,
            bottom: 20,
            top: 140,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 2600),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, -240 * value),
                  child: Opacity(
                    opacity: value < 0.2 ? value * 4 : (1 - value).clamp(0, 1),
                    child: child,
                  ),
                );
              },
              child: Icon(
                _iconFor(item.type),
                color: _colorFor(item.type),
                size: item.size,
              ),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }

  IconData _iconFor(LiveReactionType type) {
    switch (type) {
      case LiveReactionType.like:
        return Icons.thumb_up_alt_rounded;
      case LiveReactionType.love:
        return Icons.favorite_rounded;
      case LiveReactionType.wow:
        return Icons.emoji_emotions_rounded;
    }
  }

  Color _colorFor(LiveReactionType type) {
    switch (type) {
      case LiveReactionType.like:
        return const Color(0xFF4FC3F7);
      case LiveReactionType.love:
        return const Color(0xFFFF5A7A);
      case LiveReactionType.wow:
        return const Color(0xFFFFD54F);
    }
  }
}

class _FloatingReaction {
  const _FloatingReaction({
    required this.id,
    required this.type,
    required this.leftFactor,
    required this.size,
  });

  final String id;
  final LiveReactionType type;
  final double leftFactor;
  final double size;
}
