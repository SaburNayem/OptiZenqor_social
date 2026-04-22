import 'package:flutter/material.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../app_route/route_names.dart';
import '../controller/user_profile_controller.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key, this.userId, this.showAppBar = true});

  final String? userId;
  final bool showAppBar;

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late final UserProfileController _controller;

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
    final profileContent = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final user = _controller.user;

        if (_controller.state.isLoading && user == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
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

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 120,
                    width: double.infinity,
                    color: AppColors.hexFF26C6DA,
                  ),
                  Positioned(
                    bottom: -50,
                    left: 16,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(54),
                      onTap: () => AppGet.toNamed(RouteNames.mediaViewer),
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(user.avatar),
                            ),
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
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () =>
                          AppGet.toNamed(RouteNames.userProfileEdit),
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: AppColors.hexFF26C6DA,
                      ),
                      label: const Text(
                        'Edit',
                        style: TextStyle(color: AppColors.hexFF26C6DA),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 56),
                        side: const BorderSide(color: AppColors.hexFF26C6DA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () => AppGet.snackbar(
                        'Share Profile',
                        'Static share profile sheet opened',
                      ),
                      icon: const Icon(
                        Icons.share_outlined,
                        color: AppColors.grey,
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
                    Row(
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.hexFFE0F7FA,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'creator',
                            style: TextStyle(
                              color: AppColors.hexFF00ACC1,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '@${user.username}',
                      style: TextStyle(
                        color: AppColors.grey500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
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
                    '${user.followers}',
                    'Followers',
                    onTap: () => AppGet.snackbar(
                      'Followers',
                      'Static followers list opened',
                    ),
                  ),
                  _buildStatDivider(),
                  _buildStatColumn(
                    '${user.following}',
                    'Following',
                    onTap: () => AppGet.snackbar(
                      'Following',
                      'Static following list opened',
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
                      Icons.bookmark_border,
                      'Saved',
                      AppColors.hexFFE0F2F1,
                      AppColors.hexFF00897B,
                      onTap: () => AppGet.toNamed(RouteNames.bookmarks),
                    ),
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
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: 9,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemBuilder: (context, index) {
                  final List<String> images = [
                    'https://picsum.photos/seed/p1/400/400',
                    'https://picsum.photos/seed/p2/400/400',
                    'https://picsum.photos/seed/p3/400/400',
                    'https://picsum.photos/seed/p4/400/400',
                    'https://picsum.photos/seed/p5/400/400',
                    'https://picsum.photos/seed/p6/400/400',
                    'https://picsum.photos/seed/p7/400/400',
                    'https://picsum.photos/seed/p8/400/400',
                    'https://picsum.photos/seed/p9/400/400',
                  ];
                  final List<String> likes = [
                    '1k+',
                    '856',
                    '342',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '',
                  ];

                  return InkWell(
                    onTap: () => AppGet.toNamed(RouteNames.postDetail),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(images[index], fit: BoxFit.cover),
                        if (likes[index].isNotEmpty)
                          Positioned.fill(
                            child: Container(
                              alignment: Alignment.center,
                              color: AppColors.black.withValues(alpha: 0.1),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.favorite,
                                    color: AppColors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    likes[index],
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
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
              ),
            ],
          ),
        );
      },
    );

    if (!widget.showAppBar) {
      return profileContent;
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(title: const Text('Profile')),
      body: profileContent,
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

