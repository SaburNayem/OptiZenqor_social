import 'package:flutter/material.dart';

import '../model/community_group_model.dart';
import '../../../core/constants/app_colors.dart';

class FeaturedCommunityCard extends StatelessWidget {
  const FeaturedCommunityCard({
    required this.group,
    required this.onTap,
    required this.onJoinTap,
    super.key,
  });

  final CommunityGroupModel group;
  final VoidCallback onTap;
  final VoidCallback onJoinTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 270,
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: group.coverColors
                    .map(Color.new)
                    .toList(growable: false),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AvatarBadge(group: group, radius: 24),
                  const Spacer(),
                  Text(
                    group.name,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${group.memberCount} members • ${group.category}',
                    style: const TextStyle(color: AppColors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    group.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.white70),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 92,
                      child: FilledButton(
                        onPressed: onJoinTap,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 44),
                          backgroundColor: AppColors.white,
                          foregroundColor: AppColors.black87,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          group.joined ? 'Joined' : 'Join',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CommunityListTileCard extends StatelessWidget {
  const CommunityListTileCard({
    required this.group,
    required this.onTap,
    required this.onJoinTap,
    super.key,
  });

  final CommunityGroupModel group;
  final VoidCallback onTap;
  final VoidCallback onJoinTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              AvatarBadge(group: group, radius: 26),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${group.memberCount} members • ${group.category}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      group.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 92,
                child: FilledButton(
                  onPressed: onJoinTap,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    group.joined ? 'Joined' : 'Join',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AvatarBadge extends StatelessWidget {
  const AvatarBadge({required this.group, required this.radius, super.key});

  final CommunityGroupModel group;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Color(group.avatarColor),
      child: Text(
        group.name.characters.first.toUpperCase(),
        style: TextStyle(
          color: AppColors.white,
          fontSize: radius * 0.8,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class CommunitySectionTitle extends StatelessWidget {
  const CommunitySectionTitle(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
    );
  }
}
