import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../controller/live_stream_controller.dart';
import '../model/live_stream_model.dart';
import '../widget/live_bottom_customize_sheet.dart';
import '../widget/live_comment_item.dart';
import '../widget/live_control_button.dart';
import '../widget/live_option_tile.dart';
import '../widget/live_preview_header.dart';
import '../widget/live_reaction_overlay.dart';
import '../../../core/constants/app_colors.dart';

class LiveBroadcastScreen extends StatefulWidget {
  const LiveBroadcastScreen({
    this.initialTitle,
    this.initialPhotoPath,
    this.initialAudience,
    super.key,
  });

  final String? initialTitle;
  final String? initialPhotoPath;
  final LiveAudienceVisibility? initialAudience;

  @override
  State<LiveBroadcastScreen> createState() => _LiveBroadcastScreenState();
}

class _LiveBroadcastScreenState extends State<LiveBroadcastScreen>
    with SingleTickerProviderStateMixin {
  late final LiveStreamController _controller;
  late final AnimationController _enter;

  @override
  void initState() {
    super.initState();
    _controller = LiveStreamController();
    unawaited(
      _controller.load(
        initialTitle: widget.initialTitle,
        initialPhotoPath: widget.initialPhotoPath,
        initialAudience: widget.initialAudience,
      ),
    );
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.hexFF090B10,
      body: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[_controller, _enter]),
        builder: (context, _) {
          if (_controller.errorMessage != null && _controller.live == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.live_tv_outlined, color: AppColors.white),
                    const SizedBox(height: 12),
                    Text(
                      _controller.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.white),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => unawaited(
                        _controller.load(
                          initialTitle: widget.initialTitle,
                          initialPhotoPath: widget.initialPhotoPath,
                          initialAudience: widget.initialAudience,
                        ),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (_controller.isLoading || _controller.live == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return FadeTransition(
            opacity: CurvedAnimation(parent: _enter, curve: Curves.easeOut),
            child: Stack(
              children: [
                Positioned.fill(child: _buildBackground()),
                Positioned.fill(child: _buildGradients()),
                Positioned.fill(
                  child: SafeArea(
                    child: Column(
                      children: [
                        LivePreviewHeader(
                          controller: _controller,
                          onBack: () => _handleBack(),
                          onPrivacyTap: () => _pickAudience(),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: _controller.isLive
                                      ? _buildActiveMode()
                                      : _buildPreLiveMode(),
                                ),
                                Positioned(
                                  top: 10,
                                  right: 0,
                                  child: _buildRightControls(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: LiveReactionOverlay(
                      enabled: _controller.showReactionOverlay,
                      active: _controller.isLive,
                      reactionBuilder: _controller.buildReactionBatch,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackground() {
    final String? path = _controller.previewPhotoPath;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (path != null && path.isNotEmpty)
          Image.file(File(path), fit: BoxFit.cover)
        else
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.hexFF07111F,
                  _controller.accentColor.withValues(alpha: 0.55),
                  AppColors.hexFF161C2B,
                ],
              ),
            ),
          ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(color: AppColors.black.withValues(alpha: 0.08)),
          ),
        ),
      ],
    );
  }

  Widget _buildGradients() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.black.withValues(alpha: 0.56),
            AppColors.transparent,
            AppColors.black.withValues(alpha: 0.25),
            AppColors.black.withValues(alpha: 0.82),
          ],
          stops: const [0, 0.22, 0.55, 1],
        ),
      ),
    );
  }

  Widget _buildPreLiveMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        _glass(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(_controller.avatarUrl),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _controller.creatorName,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          _controller.username,
                          style: TextStyle(
                            color: AppColors.white.withValues(alpha: 0.72),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Describe what your live video is about',
                style: TextStyle(
                  color: AppColors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              _editor(
                label: 'Live title',
                value: _controller.titleController.text,
                onTap: () => _editText(
                  title: 'Live title',
                  controller: _controller.titleController,
                  onSave: _controller.applyTitle,
                ),
              ),
              const SizedBox(height: 12),
              _editor(
                label: 'Add a description',
                value: _controller.descriptionController.text,
                onTap: () => _editText(
                  title: 'Live description',
                  controller: _controller.descriptionController,
                  onSave: _controller.applyDescription,
                  maxLines: 4,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip(Icons.category_outlined, _controller.category),
                  _chip(Icons.location_on_outlined, _controller.location),
                  _chip(Icons.sell_outlined, 'Tag people'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _openCustomizeSheet,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.white,
            side: BorderSide(color: AppColors.white.withValues(alpha: 0.15)),
            backgroundColor: AppColors.white.withValues(alpha: 0.05),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          icon: const Icon(Icons.tune_rounded),
          label: const Text('Customize'),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 88,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _controller.quickOptions.length,
            itemBuilder: (context, index) {
              final option = _controller.quickOptions[index];
              return LiveOptionTile(
                icon: option.icon,
                label: option.label,
                selected: option.selected,
                onTap: () => _controller.toggleQuickOption(option.id),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _controller.isStarting
              ? null
              : () async {
                  try {
                    await _controller.startLive();
                    if (!mounted) {
                      return;
                    }
                    _showSnack('Live video started');
                  } catch (_) {
                    if (!mounted) {
                      return;
                    }
                    _showSnack(
                      _controller.errorMessage ??
                          'Unable to start live stream.',
                    );
                  }
                },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            backgroundColor: _controller.accentColor,
            foregroundColor: AppColors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          child: const Text(
            'Start Live Video',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _smallAction('Schedule')),
            const SizedBox(width: 10),
            Expanded(child: _smallAction('Rehearsal mode')),
            const SizedBox(width: 10),
            Expanded(child: _smallAction('Use stream key')),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        if (_controller.live?.pinnedComment.isNotEmpty == true)
          _glass(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.push_pin_rounded,
                  color: _controller.accentColor,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _controller.live!.pinnedComment,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 13 * _controller.fontScale,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        if (_controller.commentsVisible)
          SizedBox(
            height: 260,
            child: ListView.separated(
              reverse: true,
              padding: EdgeInsets.zero,
              itemCount: _controller.visibleComments.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) => ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: LiveCommentItem(
                  comment: _controller.visibleComments[index],
                  fontScale: _controller.fontScale,
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
        _glass(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller.moderationReplyController,
                  style: const TextStyle(color: AppColors.white),
                  decoration: InputDecoration(
                    hintText: 'Reply or moderate the chat',
                    hintStyle: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.44),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Material(
                color: _controller.accentColor,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: () async {
                    try {
                      await _controller.sendModeratorReply();
                    } catch (_) {
                      if (!mounted) {
                        return;
                      }
                      _showSnack(
                        _controller.errorMessage ?? 'Unable to send comment.',
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: const SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(Icons.send_rounded, color: AppColors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _iconAction(
                Icons.mic_rounded,
                'Mute',
                _controller.toggleMic,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _iconAction(
                Icons.cameraswitch_outlined,
                'Flip',
                _controller.toggleCamera,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _iconAction(
                Icons.share_outlined,
                'Share',
                () => _showShareSheet(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _iconAction(
                Icons.push_pin_outlined,
                'Pin',
                () => _editPinned(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _iconAction(
                Icons.more_horiz_rounded,
                'More',
                () => _liveMoreMenu(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _controller.isEnding ? null : _confirmEndLive,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            backgroundColor: AppColors.hexFFFF5A5F,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'End Live',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _buildRightControls() {
    return Column(
      children: [
        LiveControlButton(
          icon: _controller.frontCamera
              ? Icons.cameraswitch_outlined
              : Icons.camera_rear_outlined,
          onTap: _controller.toggleCamera,
        ),
        const SizedBox(height: 10),
        LiveControlButton(
          icon: _controller.beautyEnabled
              ? Icons.face_retouching_natural_rounded
              : Icons.face_outlined,
          onTap: _controller.toggleBeauty,
          active: _controller.beautyEnabled,
        ),
        const SizedBox(height: 10),
        LiveControlButton(
          icon: _controller.micEnabled
              ? Icons.mic_rounded
              : Icons.mic_off_rounded,
          onTap: _controller.toggleMic,
          active: _controller.micEnabled,
        ),
        const SizedBox(height: 10),
        LiveControlButton(
          icon: _controller.commentsVisible
              ? Icons.mode_comment_outlined
              : Icons.comments_disabled_outlined,
          onTap: _controller.toggleComments,
          active: _controller.commentsVisible,
        ),
        const SizedBox(height: 10),
        LiveControlButton(
          icon: Icons.auto_awesome_outlined,
          onTap: _openCustomizeSheet,
          highlight: _controller.settingsHighlighted,
        ),
        const SizedBox(height: 10),
        LiveControlButton(
          icon: Icons.more_horiz_rounded,
          onTap: _openCustomizeSheet,
        ),
      ],
    );
  }

  Widget _glass({required Widget child, EdgeInsets? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding ?? const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.black.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.08)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _editor({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.56),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value.trim().isEmpty ? 'Tap to add' : value,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.edit_outlined,
                color: AppColors.white.withValues(alpha: 0.68),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallAction(String label) {
    return Material(
      color: AppColors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () => _showSnack(label),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconAction(IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: AppColors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.white, size: 18),
              const SizedBox(height: 6),
              Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAudience() async {
    final result = await showModalBottomSheet<LiveAudienceVisibility>(
      context: context,
      backgroundColor: AppColors.hexFF11151D,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: LiveAudienceVisibility.values
              .map((audience) {
                return ListTile(
                  leading: Icon(
                    _audienceIcon(audience),
                    color: AppColors.white,
                  ),
                  title: Text(
                    _audienceText(audience),
                    style: const TextStyle(color: AppColors.white),
                  ),
                  trailing: _controller.audience == audience
                      ? Icon(
                          Icons.check_rounded,
                          color: _controller.accentColor,
                        )
                      : null,
                  onTap: () => Navigator.of(context).pop(audience),
                );
              })
              .toList(growable: false),
        ),
      ),
    );
    if (result != null) {
      _controller.setAudience(result);
    }
  }

  Future<void> _openCustomizeSheet() async {
    await LiveBottomCustomizeSheet.show(
      context,
      controller: _controller,
      onApplyAndGoLive: () {
        Navigator.of(context).pop();
        _controller.startLive();
      },
    );
  }

  Future<void> _editText({
    required String title,
    required TextEditingController controller,
    required ValueChanged<String> onSave,
    int maxLines = 2,
  }) async {
    final draft = TextEditingController(text: controller.text);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.hexFF151922,
        title: Text(title, style: const TextStyle(color: AppColors.white)),
        content: TextField(
          controller: draft,
          maxLines: maxLines,
          style: const TextStyle(color: AppColors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white.withValues(alpha: 0.06),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(draft.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null) {
      onSave(result);
    }
  }

  Future<void> _editPinned() async {
    await _editText(
      title: 'Pin comment',
      controller: _controller.pinnedCommentController,
      onSave: _controller.updatePinnedComment,
      maxLines: 3,
    );
  }

  Future<void> _showShareSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.hexFF11151D,
      showDragHandle: true,
      builder: (context) => const SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.copy_rounded, color: AppColors.white),
              title: Text(
                'Copy live link',
                style: TextStyle(color: AppColors.white),
              ),
            ),
            ListTile(
              leading: Icon(Icons.group_outlined, color: AppColors.white),
              title: Text(
                'Share to followers',
                style: TextStyle(color: AppColors.white),
              ),
            ),
            ListTile(
              leading: Icon(Icons.send_outlined, color: AppColors.white),
              title: Text(
                'Send in message',
                style: TextStyle(color: AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _liveMoreMenu() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.hexFF11151D,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                _controller.commentsVisible
                    ? Icons.comments_disabled_outlined
                    : Icons.comment_outlined,
                color: AppColors.white,
              ),
              title: Text(
                _controller.commentsVisible ? 'Hide comments' : 'Show comments',
                style: const TextStyle(color: AppColors.white),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _controller.toggleComments();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.favorite_rounded,
                color: AppColors.white,
              ),
              title: Text(
                _controller.showReactionOverlay
                    ? 'Hide reactions overlay'
                    : 'Show reactions overlay',
                style: const TextStyle(color: AppColors.white),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _controller.setShowReactionOverlay(
                  !_controller.showReactionOverlay,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmEndLive() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.hexFF151922,
        title: const Text(
          'End live video?',
          style: TextStyle(color: AppColors.white),
        ),
        content: Text(
          'Your live video will end and the latest backend-backed setup state will remain available.',
          style: TextStyle(color: AppColors.white.withValues(alpha: 0.75)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.hexFFFF5A5F,
            ),
            child: const Text('End live'),
          ),
        ],
      ),
    );
    if (result == true) {
      try {
        await _controller.endLive();
        if (!mounted) {
          return;
        }
        _showSnack('Live video ended');
      } catch (_) {
        if (!mounted) {
          return;
        }
        _showSnack(_controller.errorMessage ?? 'Unable to end live stream.');
      }
    }
  }

  Future<void> _handleBack() async {
    if (_controller.isLive) {
      await _confirmEndLive();
      return;
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  IconData _audienceIcon(LiveAudienceVisibility value) {
    switch (value) {
      case LiveAudienceVisibility.public:
        return Icons.public_rounded;
      case LiveAudienceVisibility.friends:
        return Icons.people_alt_outlined;
      case LiveAudienceVisibility.onlyMe:
        return Icons.lock_outline_rounded;
    }
  }

  String _audienceText(LiveAudienceVisibility value) {
    switch (value) {
      case LiveAudienceVisibility.public:
        return 'Public';
      case LiveAudienceVisibility.friends:
        return 'Friends';
      case LiveAudienceVisibility.onlyMe:
        return 'Only me';
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
