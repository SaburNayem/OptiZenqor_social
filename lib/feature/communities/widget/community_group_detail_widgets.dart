import 'package:flutter/material.dart';

import '../model/community_group_model.dart';
import '../bloc/community_group_cubit.dart';
import 'community_group_common_widgets.dart';

class CommunityEventCard extends StatelessWidget {
  const CommunityEventCard({
    required this.controller,
    required this.event,
    required this.onInvite,
    super.key,
  });

  final CommunityGroupCubit controller;
  final CommunityEventModel event;
  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CommunityPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 132,
              decoration: BoxDecoration(
                color: Color(event.coverColor).withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Icon(
                  event.locationLabel == 'Online'
                      ? Icons.wifi_tethering_rounded
                      : Icons.location_on_outlined,
                  size: 42,
                  color: Color(event.coverColor),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              event.title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(event.dateLabel),
            const SizedBox(height: 4),
            Text(event.locationLabel),
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton(
                  onPressed: () => controller.toggleGoing(event.id),
                  child: Text(event.going ? 'Going' : 'Interested'),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: onInvite,
                  child: const Text('Invite'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CommunityMemberTile extends StatelessWidget {
  const CommunityMemberTile({
    required this.controller,
    required this.member,
    required this.onMessage,
    super.key,
  });

  final CommunityGroupCubit controller;
  final CommunityMemberModel member;
  final ValueChanged<String> onMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CommunityPanel(
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(member.accentColor),
              child: Text(member.name.characters.first),
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
                          member.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 6),
                      CommunityRoleBadge(member.role),
                    ],
                  ),
                  if (member.topContributor)
                    Text(
                      'Top contributor',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => onMessage('Message ${member.name}'),
              child: const Text('Message'),
            ),
            FilledButton(
              onPressed: () => controller.toggleFollowMember(member.id),
              child: Text(member.following ? 'Following' : 'Follow'),
            ),
          ],
        ),
      ),
    );
  }
}

class CommunityAboutCard extends StatelessWidget {
  const CommunityAboutCard({
    required this.title,
    required this.value,
    super.key,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CommunityPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(value),
          ],
        ),
      ),
    );
  }
}

class CommunityBottomBar extends StatelessWidget {
  const CommunityBottomBar({
    required this.notificationsEnabled,
    required this.onCreate,
    required this.onInvite,
    required this.onNotify,
    required this.onCustomize,
    super.key,
  });

  final bool notificationsEnabled;
  final VoidCallback onCreate;
  final VoidCallback onInvite;
  final VoidCallback onNotify;
  final VoidCallback onCustomize;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: _CommunityBottomAction(
                icon: Icons.edit_note_rounded,
                label: 'Create',
                onTap: onCreate,
              ),
            ),
            Expanded(
              child: _CommunityBottomAction(
                icon: Icons.person_add_alt_1_rounded,
                label: 'Invite',
                onTap: onInvite,
              ),
            ),
            Expanded(
              child: _CommunityBottomAction(
                icon: notificationsEnabled
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_off_rounded,
                label: 'Notify',
                onTap: onNotify,
              ),
            ),
            Expanded(
              child: _CommunityBottomAction(
                icon: Icons.tune_rounded,
                label: 'Customize',
                onTap: onCustomize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityBottomAction extends StatelessWidget {
  const _CommunityBottomAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}
