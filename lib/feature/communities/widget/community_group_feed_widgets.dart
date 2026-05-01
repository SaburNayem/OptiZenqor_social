import 'package:flutter/material.dart';

import '../model/community_group_model.dart';
import '../bloc/community_group_cubit.dart';
import 'community_group_common_widgets.dart';
import '../../../core/constants/app_colors.dart';

class CommunityComposerCard extends StatelessWidget {
  const CommunityComposerCard({
    required this.avatarColor,
    required this.onTap,
    super.key,
  });

  final int avatarColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CommunityPanel(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Color(avatarColor),
            child: const Icon(Icons.group_rounded, color: AppColors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              readOnly: true,
              onTap: onTap,
              decoration: InputDecoration(
                hintText: 'Write something...',
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CommunityQuickActions extends StatelessWidget {
  const CommunityQuickActions({required this.onAction, super.key});

  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final actions = <Map<String, dynamic>>[
      {'label': 'Post', 'icon': Icons.edit_note_rounded},
      {'label': 'Photo', 'icon': Icons.photo_library_outlined},
      {'label': 'Live', 'icon': Icons.videocam_outlined},
      {'label': 'Poll', 'icon': Icons.poll_outlined},
      {'label': 'Event', 'icon': Icons.event_outlined},
    ];

    return Row(
      children: actions
          .map(
            (item) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CommunityPanel(
                  onTap: () => onAction('${item['label']} action'),
                  child: Column(
                    children: [
                      Icon(item['icon'] as IconData),
                      const SizedBox(height: 6),
                      Text(item['label'] as String),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class CommunityPostCard extends StatelessWidget {
  const CommunityPostCard({
    required this.controller,
    required this.post,
    required this.onMediaTap,
    required this.onMessage,
    super.key,
    this.highlighted = false,
    this.adminTools = false,
  });

  final CommunityGroupCubit controller;
  final CommunityPostModel post;
  final void Function(String label, bool isVideo) onMediaTap;
  final ValueChanged<String> onMessage;
  final bool highlighted;
  final bool adminTools;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CommunityPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(post.authorAccent),
                  child: Text(
                    post.authorName.characters.first,
                    style: const TextStyle(color: AppColors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              post.authorName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          CommunityRoleBadge(post.authorRole),
                        ],
                      ),
                      Text(
                        post.timeLabel,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'save') {
                      controller.toggleSavePost(post.id);
                      return;
                    }
                    if (value == 'pin') {
                      controller.togglePinPost(post.id);
                      return;
                    }
                    onMessage('Reported locally');
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'save',
                      child: Text(post.saved ? 'Unsave' : 'Save'),
                    ),
                    const PopupMenuItem(value: 'report', child: Text('Report')),
                    if (adminTools)
                      PopupMenuItem(
                        value: 'pin',
                        child: Text(post.pinned ? 'Unpin' : 'Pin'),
                      ),
                  ],
                ),
              ],
            ),
            if (highlighted || post.highlight) ...[
              const SizedBox(height: 10),
              const Wrap(
                spacing: 8,
                children: [CommunityMiniPill('Announcement')],
              ),
            ],
            const SizedBox(height: 10),
            Text(post.content),
            if (post.mediaLabel != null) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => onMediaTap(
                  post.mediaLabel!,
                  post.type == CommunityPostType.video,
                ),
                child: Container(
                  height: 164,
                  decoration: BoxDecoration(
                    color: Color(post.authorAccent).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          post.type == CommunityPostType.video
                              ? Icons.play_circle_fill_rounded
                              : Icons.photo_outlined,
                          size: 42,
                        ),
                        const SizedBox(height: 8),
                        Text(post.mediaLabel!),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            if (post.type == CommunityPostType.poll &&
                post.pollOptions.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...post.pollOptions.map(
                (option) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: LinearProgressIndicator(
                    value: 0.2 + (post.pollOptions.indexOf(option) * 0.2),
                    borderRadius: BorderRadius.circular(999),
                    minHeight: 34,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(post.authorAccent).withValues(alpha: 0.72),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Text('${post.likes} likes'),
                const SizedBox(width: 12),
                Text('${post.comments} comments'),
                const SizedBox(width: 12),
                Text('${post.shares} shares'),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _CommunityPostAction(
                    icon: Icons.thumb_up_alt_outlined,
                    label: 'Like',
                    onTap: () => onMessage('Like'),
                  ),
                ),
                Expanded(
                  child: _CommunityPostAction(
                    icon: Icons.mode_comment_outlined,
                    label: 'Comment',
                    onTap: () => onMessage('Comment'),
                  ),
                ),
                Expanded(
                  child: _CommunityPostAction(
                    icon: Icons.share_outlined,
                    label: 'Share',
                    onTap: () => onMessage('Share'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CommunityActivityTile extends StatelessWidget {
  const CommunityActivityTile({required this.value, super.key});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CommunityPanel(
        child: Row(
          children: [
            const Icon(Icons.bolt_rounded),
            const SizedBox(width: 10),
            Expanded(child: Text(value)),
          ],
        ),
      ),
    );
  }
}

class CommunityGroupChatCard extends StatelessWidget {
  const CommunityGroupChatCard({
    required this.onOpenChat,
    required this.onAdminControls,
    super.key,
  });

  final VoidCallback onOpenChat;
  final VoidCallback onAdminControls;

  @override
  Widget build(BuildContext context) {
    return CommunityPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Group chat room',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Real-time group chat with reactions, media sharing, and admin controls.',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              FilledButton(
                onPressed: onOpenChat,
                child: const Text('Open chat'),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: onAdminControls,
                child: const Text('Admin controls'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CommunityMediaGrid extends StatelessWidget {
  const CommunityMediaGrid({
    required this.items,
    required this.onTap,
    super.key,
  });

  final List<CommunityMediaItem> items;
  final void Function(String label, bool isVideo) onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.12,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          onTap: () => onTap(item.label, item.isVideo),
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Color(item.color).withValues(alpha: 0.15),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    item.isVideo
                        ? Icons.videocam_outlined
                        : Icons.photo_outlined,
                    size: 40,
                    color: Color(item.color),
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CommunityPostAction extends StatelessWidget {
  const _CommunityPostAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}
