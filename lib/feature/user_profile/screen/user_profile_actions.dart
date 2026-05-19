part of 'user_profile_screen.dart';

extension _UserProfileActions on _UserProfileScreenState {
  void _openAudioCall(UserModel user) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AudioCallScreen(
          name: user.name,
          avatarUrl: user.avatar,
          recipientId: user.id,
        ),
      ),
    );
  }

  void _openVideoCall(UserModel user) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VideoCallScreen(
          name: user.name,
          avatarUrl: user.avatar,
          recipientId: user.id,
        ),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: AppColors.grey500, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(height: 24, width: 1, color: AppColors.grey200);
  }

  Future<void> _showShareProfileSheet(UserModel user) async {
    final String profileUrl = user.publicProfileUrl.isNotEmpty
        ? user.publicProfileUrl
        : 'https://optizenqor.app/@${user.username}';

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.link_rounded),
                title: const Text('Copy profile link'),
                subtitle: Text(profileUrl),
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: profileUrl));
                  if (sheetContext.mounted) {
                    Navigator.of(sheetContext).pop();
                  }
                  AppGet.snackbar('Share Profile', 'Profile link copied');
                },
              ),
              ListTile(
                leading: const Icon(Icons.alternate_email_rounded),
                title: const Text('Copy username'),
                subtitle: Text('@${user.username}'),
                onTap: () async {
                  await Clipboard.setData(
                    ClipboardData(text: '@${user.username}'),
                  );
                  if (sheetContext.mounted) {
                    Navigator.of(sheetContext).pop();
                  }
                  AppGet.snackbar('Share Profile', 'Username copied');
                },
              ),
              ListTile(
                leading: const Icon(Icons.qr_code_rounded),
                title: const Text('Copy public profile URL'),
                subtitle: const Text('Use this link to share the profile'),
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: profileUrl));
                  if (sheetContext.mounted) {
                    Navigator.of(sheetContext).pop();
                  }
                  AppGet.snackbar('Share Profile', 'Public URL copied');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleProfileMenuAction(String value, UserModel user) async {
    final String profileUrl = user.publicProfileUrl.isNotEmpty
        ? user.publicProfileUrl
        : 'https://optizenqor.app/@${user.username}';

    switch (value) {
      case 'accept_buddy':
        final String acceptMessage = await _controller.acceptBuddyRequest();
        if (acceptMessage.trim().isNotEmpty) {
          AppGet.snackbar('Buddy', acceptMessage);
        }
        return;
      case 'reject_buddy':
        final String rejectMessage = await _controller.rejectBuddyRequest();
        if (rejectMessage.trim().isNotEmpty) {
          AppGet.snackbar('Buddy', rejectMessage);
        }
        return;
      case 'remove_buddy':
        final String removeMessage = await _controller.removeBuddy();
        if (removeMessage.trim().isNotEmpty) {
          AppGet.snackbar('Buddy', removeMessage);
        }
        return;
      case 'unfollow_profile':
        if (_controller.isFollowing || _controller.followRequestPending) {
          await _controller.toggleFollow();
          AppGet.snackbar('Profile', 'Unfollowed successfully');
        }
        return;
      case 'toggle_buddy':
        final String message = await _controller.toggleBuddyRequest();
        if (message.trim().isNotEmpty) {
          AppGet.snackbar('Buddy', message);
        }
        return;
      case 'audio_call':
        _openAudioCall(user);
        return;
      case 'video_call':
        _openVideoCall(user);
        return;
      case 'buddy_status':
        return;
      case 'copy_link':
        await Clipboard.setData(ClipboardData(text: profileUrl));
        AppGet.snackbar('Profile', 'Profile link copied');
        return;
      case 'copy_username':
        await Clipboard.setData(ClipboardData(text: '@${user.username}'));
        AppGet.snackbar('Profile', 'Username copied');
        return;
    }
  }

  Widget _buildUtilityIcon(
    IconData icon,
    String label,
    Color bgColor,
    Color iconColor, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(IconData icon, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: Column(
        children: [
          IconButton(
            onPressed: onTap,
            icon: Icon(
              icon,
              color: isSelected ? AppColors.hexFF26C6DA : AppColors.grey400,
            ),
          ),
          if (isSelected)
            Container(
              height: 2,
              width: double.infinity,
              color: AppColors.hexFF26C6DA,
            ),
        ],
      ),
    );
  }
}
