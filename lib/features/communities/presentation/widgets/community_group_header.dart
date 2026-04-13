import 'package:flutter/material.dart';

import '../../model/community_group_model.dart';
import '../helpers/community_group_formatters.dart';
import '../../../../core/constants/app_colors.dart';

class CommunityGroupHeader extends StatelessWidget {
  const CommunityGroupHeader({
    required this.group,
    required this.onJoin,
    required this.onInvite,
    required this.onMore,
    super.key,
  });

  final CommunityGroupModel group;
  final VoidCallback onJoin;
  final VoidCallback onInvite;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final lightCoverColors = group.coverColors
        .map((value) => Color.alphaBlend(AppColors.white70, Color(value)))
        .toList(growable: false);

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
              colors: lightCoverColors,
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 68, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(group.avatarColor),
                  child: Text(
                    group.name.characters.first,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  group.name,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${privacyLabel(group.privacy)} • ${group.memberCount} members',
                  style: const TextStyle(color: AppColors.white70),
                ),
                const SizedBox(height: 6),
                Text(
                  group.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.white),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: onJoin,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(group.joined ? 'Joined' : 'Join'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onInvite,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          foregroundColor: AppColors.white,
                          side: const BorderSide(color: AppColors.white54),
                        ),
                        child: const Text('Invite'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: IconButton(
                        style: IconButton.styleFrom(
                          minimumSize: const Size(44, 44),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: onMore,
                        color: AppColors.white,
                        icon: const Icon(Icons.more_horiz_rounded),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

