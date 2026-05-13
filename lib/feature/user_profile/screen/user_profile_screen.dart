import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../app_route/route_names.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/data/models/message_model.dart';
import '../../../core/data/models/post_model.dart';
import '../../../core/data/models/reel_model.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_shimmer.dart';
import '../../calls/screen/audio_call_screen.dart';
import '../../calls/screen/video_call_screen.dart';
import '../../chat/repository/chat_repository.dart';
import '../../chat/screen/chat_detail_screen.dart';
import '../../media_viewer/model/media_viewer_item_model.dart';
import '../../media_viewer/model/media_viewer_route_arguments.dart';
import '../../post_detail/screen/post_detail_screen.dart';
import '../controller/user_profile_controller.dart';
import '../repository/user_profile_repository.dart';
import 'edit_profile_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key, this.userId, this.showAppBar = true});

  final String? userId;
  final bool showAppBar;

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late final UserProfileController _controller;
  final ChatRepository _chatRepository = ChatRepository();
  bool _isOpeningMessage = false;

  @override
  void initState() {
    super.initState();
    _controller = UserProfileController();
    _controller.load(userId: widget.userId);
  }

  @override
  void didUpdateWidget(covariant UserProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      _controller.load(userId: widget.userId);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget profileContent = AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final UserModel? user = _controller.user;

        if (_controller.state.isLoading && user == null) {
          return const _ProfileShimmer();
        }

        if (_controller.state.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _controller.state.errorMessage ?? 'Unable to load profile',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton(
                    onPressed: () => _controller.load(userId: widget.userId),
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          );
        }

        if (user == null) {
          return const Center(
            child: Text(
              'Profile not found',
              style: TextStyle(
                color: AppColors.black87,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => _controller.load(userId: widget.userId),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_controller.state.isLoading)
                  const LinearProgressIndicator(minHeight: 2),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _buildCover(user),
                    Positioned(
                      bottom: -50,
                      left: 16,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(54),
                        onTap: _hasUsableNetworkImage(user.avatar)
                            ? () => AppGet.toNamed(
                                RouteNames.mediaViewer,
                                arguments: MediaViewerRouteArguments(
                                  items: <MediaViewerItemModel>[
                                    MediaViewerItemModel.fromSource(
                                      user.avatar,
                                    ),
                                  ],
                                  title: '${user.name} profile photo',
                                ),
                              )
                            : null,
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                              ),
                              child: _buildProfileAvatar(user),
                            ),
                            Positioned(
                              right: 4,
                              bottom: 4,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: AppColors.hexFF26C6DA,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.white,
                                    width: 3,
                                  ),
                                ),
                                child: Icon(
                                  _hasUsableNetworkImage(user.avatar)
                                      ? Icons.open_in_full_rounded
                                      : Icons.person_rounded,
                                  size: 11,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 58),
                if (_controller.isOwnProfile)
                  Padding(
                    padding: const EdgeInsets.only(right: 16, left: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildEditProfileButton(),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.grey200),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () => _showShareProfileSheet(user),
                            icon: const Icon(
                              Icons.share_outlined,
                              color: AppColors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _buildProfileTypeChip(user),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.bio.isNotEmpty
                            ? user.bio
                            : 'Profile bio is not available yet.',
                        style: TextStyle(
                          color: AppColors.grey700,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      if (user.website.trim().isNotEmpty ||
                          user.location.trim().isNotEmpty)
                        const SizedBox(height: 12),
                      if (user.website.trim().isNotEmpty)
                        _buildMetaRow(Icons.link_rounded, user.website.trim()),
                      if (user.location.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: _buildMetaRow(
                            Icons.location_on_outlined,
                            user.location.trim(),
                          ),
                        ),
                      if (!_controller.isOwnProfile) ...[
                        const SizedBox(height: 16),
                        _buildOtherProfileActions(user),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn(
                      '${_controller.postCount}',
                      'Posts',
                      onTap: () => _controller.selectTab(0),
                    ),
                    _buildStatDivider(),
                    _buildStatColumn(
                      '${_controller.followerCount}',
                      'Followers',
                      onTap: () => AppGet.toNamed(
                        RouteNames.userProfileFollowers,
                        parameters: <String, String>{'id': user.id},
                      ),
                    ),
                    _buildStatDivider(),
                    _buildStatColumn(
                      '${_controller.followingCount}',
                      'Following',
                      onTap: () => AppGet.toNamed(
                        RouteNames.userProfileFollowing,
                        parameters: <String, String>{'id': user.id},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildUtilityIcon(
                        Icons.account_balance_wallet_outlined,
                        'Wallet',
                        AppColors.hexFFE3F2FD,
                        AppColors.hexFF1E88E5,
                        onTap: () => AppGet.toNamed(RouteNames.walletPayments),
                      ),
                      _buildUtilityIcon(
                        Icons.calendar_today_outlined,
                        'Events',
                        AppColors.hexFFF3E5F5,
                        AppColors.hexFF8E24AA,
                        onTap: () => AppGet.toNamed(RouteNames.eventsCreate),
                      ),
                      _buildUtilityIcon(
                        Icons.bar_chart_outlined,
                        'Polls',
                        AppColors.hexFFE1F5FE,
                        AppColors.hexFF039BE5,
                        onTap: () => AppGet.toNamed(RouteNames.pollsSurveys),
                      ),
                      _buildUtilityIcon(
                        Icons.workspace_premium_outlined,
                        'Plans',
                        AppColors.hexFFFFF3E0,
                        AppColors.hexFFFB8C00,
                        onTap: () => AppGet.toNamed(RouteNames.premium),
                      ),
                      _buildUtilityIcon(
                        Icons.card_giftcard,
                        'Invite',
                        AppColors.hexFFE8F5E9,
                        AppColors.hexFF43A047,
                        onTap: () => AppGet.toNamed(RouteNames.inviteReferral),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _buildTabItem(
                      Icons.grid_view_rounded,
                      _controller.selectedTabIndex == 0,
                      () => _controller.selectTab(0),
                    ),
                    _buildTabItem(
                      Icons.play_circle_outline,
                      _controller.selectedTabIndex == 1,
                      () => _controller.selectTab(1),
                    ),
                    _buildTabItem(
                      Icons.person_pin_outlined,
                      _controller.selectedTabIndex == 2,
                      () => _controller.selectTab(2),
                    ),
                  ],
                ),
                _buildSelectedTabContent(),
              ],
            ),
          ),
        );
      },
    );

    if (!widget.showAppBar) {
      return profileContent;
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        automaticallyImplyLeading: !_controller.isOwnProfile,
        leading: _controller.isOwnProfile
            ? null
            : IconButton(
                onPressed: () => AppGet.back(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
        title: const Text('Profile'),
      ),
      body: profileContent,
    );
  }

  Widget _buildCover(UserModel user) {
    final String coverImageUrl = user.coverImageUrl.trim();
    if (!_hasUsableNetworkImage(coverImageUrl)) {
      return Container(
        height: 140,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[AppColors.hexFF26C6DA, AppColors.hexFF80DEEA],
          ),
        ),
      );
    }

    return SizedBox(
      height: 140,
      width: double.infinity,
      child: Image.network(coverImageUrl, fit: BoxFit.cover),
    );
  }

  Widget _buildProfileAvatar(UserModel user) {
    return CircleAvatar(
      radius: 50,
      backgroundColor: AppColors.hexFFF2F4F7,
      child: AppAvatar(imageUrl: user.avatar, radius: 46, verified: false),
    );
  }

  bool _hasUsableNetworkImage(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return false;
    }
    final Uri? uri = Uri.tryParse(trimmed);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  Widget _buildFollowActionButton() {
    if (_controller.followRequestPending) {
      return FilledButton.tonal(
        onPressed: _controller.toggleFollow,
        style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
        child: const Text('Requested'),
      );
    }
    if (_controller.isFollowing) {
      return OutlinedButton(
        onPressed: _controller.toggleFollow,
        style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
        child: const Text('Following'),
      );
    }
    return FilledButton(
      onPressed: _controller.toggleFollow,
      style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
      child: const Text('Follow'),
    );
  }

  Widget _buildEditProfileButton() {
    return OutlinedButton.icon(
      onPressed: _openEditProfile,
      icon: const Icon(
        Icons.edit_outlined,
        size: 18,
        color: AppColors.hexFF26C6DA,
      ),
      label: const Text(
        'Edit Profile',
        style: TextStyle(color: AppColors.hexFF26C6DA),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        side: const BorderSide(color: AppColors.hexFF26C6DA),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildMessageButton(UserModel user) {
    return OutlinedButton.icon(
      onPressed: _isOpeningMessage ? null : () => _openMessage(user),
      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
      label: Text(_isOpeningMessage ? 'Opening...' : 'Msg'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        side: const BorderSide(color: AppColors.hexFF26C6DA),
        foregroundColor: AppColors.hexFF26C6DA,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildOtherProfileActions(UserModel user) {
    return Row(
      children: [
        Expanded(flex: 11, child: _buildFollowActionButton()),
        const SizedBox(width: 8),
        Expanded(flex: 9, child: _buildMessageButton(user)),
        const SizedBox(width: 8),
        _buildMoreActionsButton(user),
      ],
    );
  }

  Widget _buildMoreActionsButton(UserModel user) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: PopupMenuButton<String>(
        onSelected: (String value) => _handleProfileMenuAction(value, user),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        enabled: !_controller.buddyActionInProgress,
        icon: Icon(
          _controller.buddyActionInProgress
              ? Icons.hourglass_top_rounded
              : Icons.more_horiz_rounded,
          color: AppColors.grey,
        ),
        itemBuilder: (BuildContext context) => _buildProfileMenuItems(),
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildProfileMenuItems() {
    final List<PopupMenuEntry<String>> items = <PopupMenuEntry<String>>[];
    if (_controller.buddyRequestReceived) {
      items.add(
        const PopupMenuItem<String>(
          value: 'accept_buddy',
          child: Text('Accept Buddy'),
        ),
      );
      items.add(
        const PopupMenuItem<String>(
          value: 'reject_buddy',
          child: Text('Reject Buddy'),
        ),
      );
    } else if (_controller.isBuddy) {
      items.add(
        const PopupMenuItem<String>(
          value: 'buddy_status',
          enabled: false,
          child: Text('Buddy'),
        ),
      );
      items.add(
        const PopupMenuItem<String>(
          value: 'unfollow_profile',
          child: Text('Unfollow'),
        ),
      );
      items.add(
        const PopupMenuItem<String>(
          value: 'remove_buddy',
          child: Text('Remove Buddy'),
        ),
      );
      items.add(
        const PopupMenuItem<String>(
          value: 'audio_call',
          child: Text('Audio Call'),
        ),
      );
      items.add(
        const PopupMenuItem<String>(
          value: 'video_call',
          child: Text('Video Call'),
        ),
      );
    } else {
      items.add(
        PopupMenuItem<String>(
          value: 'toggle_buddy',
          child: Text(
            _controller.buddyRequestSent ? 'Cancel Buddy Request' : 'Add Buddy',
          ),
        ),
      );
    }
    items.add(
      const PopupMenuItem<String>(
        value: 'copy_link',
        child: Text('Copy Profile Link'),
      ),
    );
    items.add(
      const PopupMenuItem<String>(
        value: 'copy_username',
        child: Text('Copy Username'),
      ),
    );
    return items;
  }

  Widget _buildProfileTypeChip(UserModel user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.hexFFE0F7FA,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _roleLabel(user),
        style: const TextStyle(
          color: AppColors.hexFF00ACC1,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSelectedTabContent() {
    switch (_controller.selectedTabIndex) {
      case 1:
        return _buildReelsGrid();
      case 2:
        return _buildTaggedGrid();
      case 0:
      default:
        return _buildPostsGrid();
    }
  }

  Widget _buildPostsGrid() {
    final List<PostModel> posts = _controller.posts;
    if (posts.isEmpty) {
      return _buildEmptyTabState(
        icon: Icons.grid_view_rounded,
        title: 'No posts yet',
        message: 'Posts from backend will appear here.',
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: posts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemBuilder: (BuildContext context, int index) {
        final PostModel post = posts[index];
        return InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  PostDetailScreen(postId: post.id, initialPost: post),
            ),
          ),
          child: _MediaTile(
            imageUrl: post.media.isNotEmpty ? post.media.first : null,
            title: post.caption,
            badge: post.likes > 0 ? '${post.likes}' : null,
            icon: Icons.favorite,
          ),
        );
      },
    );
  }

  Widget _buildReelsGrid() {
    final List<ReelModel> reels = _controller.reels;
    if (reels.isEmpty) {
      return _buildEmptyTabState(
        icon: Icons.play_circle_outline,
        title: 'No reels yet',
        message: 'Reels from backend will appear here.',
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: reels.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemBuilder: (BuildContext context, int index) {
        final ReelModel reel = reels[index];
        final String? imageUrl = reel.coverUrl?.trim().isNotEmpty == true
            ? reel.coverUrl!.trim()
            : reel.thumbnail.trim().isNotEmpty
            ? reel.thumbnail.trim()
            : null;
        return InkWell(
          onTap: () => AppGet.toNamed(RouteNames.reels),
          child: _MediaTile(
            imageUrl: imageUrl,
            title: reel.caption,
            badge: reel.likes > 0 ? '${reel.likes}' : null,
            icon: Icons.play_arrow_rounded,
          ),
        );
      },
    );
  }

  Widget _buildTaggedGrid() {
    final List<PostTagSummary> taggedPosts = _controller.taggedPosts;
    if (taggedPosts.isEmpty) {
      return _buildEmptyTabState(
        icon: Icons.alternate_email_rounded,
        title: 'No tagged posts',
        message: 'Tagged posts from backend will appear here.',
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(2),
      itemCount: taggedPosts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemBuilder: (BuildContext context, int index) {
        final PostTagSummary item = taggedPosts[index];
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.hexFFF2F4F7,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(
                Icons.alternate_email_rounded,
                color: AppColors.hexFF26C6DA,
              ),
              Text(
                item.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                item.location?.trim().isNotEmpty == true
                    ? item.location!.trim()
                    : '${item.mediaCount} media',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.grey, fontSize: 11),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyTabState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
      child: Column(
        children: [
          Icon(icon, size: 42, color: AppColors.grey400),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.grey,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.grey600),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  String _roleLabel(UserModel user) {
    final String role = user.role.name.trim();
    if (role.isEmpty) {
      return 'Member';
    }
    return role[0].toUpperCase() + role.substring(1);
  }

  Future<void> _openEditProfile() async {
    final bool? updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const EditProfileScreen(),
        settings: const RouteSettings(name: RouteNames.userProfileEdit),
      ),
    );
    if (updated == true) {
      await _controller.load(userId: widget.userId);
    }
  }

  Future<void> _openMessage(UserModel user) async {
    if (_isOpeningMessage) {
      return;
    }
    setState(() {
      _isOpeningMessage = true;
    });
    try {
      final thread = await _chatRepository.createThread(user.id);
      if (!mounted) {
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ChatDetailScreen(
            user: thread.user.id.isNotEmpty ? thread.user : user,
            initialMessage:
                thread.lastMessageModel ??
                MessageModel(
                  id: 'profile_msg_${DateTime.now().microsecondsSinceEpoch}',
                  chatId: thread.chatId,
                  senderId: user.id,
                  text: 'Start a conversation',
                  timestamp: DateTime.now(),
                  read: true,
                ),
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        AppGet.snackbar(
          'Chat',
          error.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningMessage = false;
        });
      }
    }
  }

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

class _ProfileShimmer extends StatelessWidget {
  const _ProfileShimmer();

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          ShimmerBox(height: 140, radius: 0),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                ShimmerBox(height: 96, width: 96, radius: 48),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(height: 18, width: 150),
                      SizedBox(height: 10),
                      ShimmerBox(height: 12, width: 100),
                      SizedBox(height: 16),
                      ShimmerBox(height: 42, radius: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: EdgeInsets.all(16), child: ShimmerBox(height: 14)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ShimmerBox(height: 14, width: 220),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ShimmerBox(height: 40, width: 60),
                ShimmerBox(height: 40, width: 60),
                ShimmerBox(height: 40, width: 60),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ShimmerBox(height: 220, radius: 16),
          ),
        ],
      ),
    );
  }
}

class _MediaTile extends StatelessWidget {
  const _MediaTile({
    this.imageUrl,
    required this.title,
    this.badge,
    required this.icon,
  });

  final String? imageUrl;
  final String title;
  final String? badge;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final Widget background = imageUrl != null && imageUrl!.trim().isNotEmpty
        ? Image.network(imageUrl!.trim(), fit: BoxFit.cover)
        : Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[AppColors.hexFF0284C7, AppColors.hexFF4FC3F7],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                title,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );

    return Stack(
      fit: StackFit.expand,
      children: [
        background,
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.black.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(icon, color: AppColors.white, size: 16),
          ),
        ),
        if (badge != null && badge!.trim().isNotEmpty)
          Positioned(
            left: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.black.withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                badge!,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
