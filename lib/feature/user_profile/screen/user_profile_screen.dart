import 'package:flutter/material.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../route/route_names.dart';
import '../controller/user_profile_controller.dart';

class UserProfileScreen extends StatelessWidget {
  UserProfileScreen({super.key, this.userId, this.showAppBar = true}) {
    _controller.load(userId: userId);
  }

  final String? userId;
  final bool showAppBar;
  final UserProfileController _controller = UserProfileController();

  @override
  Widget build(BuildContext context) {
    final profileContent = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final user = _controller.user;
        if (user == null) return const SizedBox.shrink();

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Image and Avatar
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 120,
                    width: double.infinity,
                    color: const Color(0xFF26C6DA),
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
                              color: Colors.white,
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
                                color: const Color(0xFF26C6DA),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
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

              // Edit/Share Buttons
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => AppGet.toNamed(
                        RouteNames.userProfileEdit,
                      ),
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: Color(0xFF26C6DA),
                      ),
                      label: const Text(
                        'Edit',
                        style: TextStyle(color: Color(0xFF26C6DA)),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF26C6DA)),
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
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Profile Info
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
                            color: const Color(0xFFE0F7FA),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'creator',
                            style: TextStyle(
                              color: Color(0xFF00ACC1),
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
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Digital nomad & visual storyteller. Exploring the world one pixel at a time. 📸✈️',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn(
                    '142',
                    'Posts',
                    onTap: () => _controller.selectTab(0),
                  ),
                  _buildStatDivider(),
                  _buildStatColumn(
                    '12.4 K',
                    'Followers',
                    onTap: () => AppGet.snackbar(
                      'Followers',
                      'Static followers list opened',
                    ),
                  ),
                  _buildStatDivider(),
                  _buildStatColumn(
                    '342',
                    'Following',
                    onTap: () => AppGet.snackbar(
                      'Following',
                      'Static following list opened',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Utility Icons Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildUtilityIcon(
                      Icons.bookmark_border,
                      'Saved',
                      const Color(0xFFE0F2F1),
                      const Color(0xFF00897B),
                      onTap: () => AppGet.toNamed(RouteNames.bookmarks),
                    ),
                    _buildUtilityIcon(
                      Icons.account_balance_wallet_outlined,
                      'Wallet',
                      const Color(0xFFE3F2FD),
                      const Color(0xFF1E88E5),
                      onTap: () => AppGet.toNamed(RouteNames.walletPayments),
                    ),
                    _buildUtilityIcon(
                      Icons.calendar_today_outlined,
                      'Events',
                      const Color(0xFFF3E5F5),
                      const Color(0xFF8E24AA),
                      onTap: () => AppGet.toNamed(RouteNames.events),
                    ),
                    _buildUtilityIcon(
                      Icons.bar_chart_outlined,
                      'Polls',
                      const Color(0xFFE1F5FE),
                      const Color(0xFF039BE5),
                      onTap: () => AppGet.toNamed(RouteNames.pollsSurveys),
                    ),
                    _buildUtilityIcon(
                      Icons.workspace_premium_outlined,
                      'Plans',
                      const Color(0xFFFFF3E0),
                      const Color(0xFFFB8C00),
                      onTap: () => AppGet.toNamed(RouteNames.premium),
                    ),
                    _buildUtilityIcon(
                      Icons.card_giftcard,
                      'Invite',
                      const Color(0xFFE8F5E9),
                      const Color(0xFF43A047),
                      onTap: () => AppGet.toNamed(RouteNames.inviteReferral),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Tab Selector
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

              // Content Grid
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
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              alignment: Alignment.center,
                              color: Colors.black.withOpacity(0.1),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.favorite,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    likes[index],
                                    style: const TextStyle(
                                      color: Colors.white,
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

    if (!showAppBar) return profileContent;

    return Scaffold(
      backgroundColor: Colors.white,
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
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(height: 24, width: 1, color: Colors.grey.shade200);
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
              color: isSelected
                  ? const Color(0xFF26C6DA)
                  : Colors.grey.shade400,
            ),
          ),
          if (isSelected)
            Container(
              height: 2,
              width: double.infinity,
              color: const Color(0xFF26C6DA),
            ),
        ],
      ),
    );
  }
}
