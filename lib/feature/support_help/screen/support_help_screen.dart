import 'package:flutter/material.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../route/route_names.dart';

class SupportHelpScreen extends StatelessWidget {
  const SupportHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.hexFFFBFBFB,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Help & Support',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.black54),
            onPressed: () {
              AppGet.snackbar('Search', 'Static help search opened');
            },
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_outlined,
                  color: AppColors.black54,
                ),
                onPressed: () {
                  AppGet.toNamed(RouteNames.notifications);
                },
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16.0, left: 8),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(
                'https://i.pravatar.cc/150?u=myprofile',
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.hexFFF5F5F5,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search help articles...',
                    hintStyle: TextStyle(color: AppColors.grey, fontSize: 14),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'How can we help?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Category Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.3,
                children: [
                  _buildCategoryCard(
                    'Getting Started',
                    Icons.book_outlined,
                    AppColors.blue100,
                    AppColors.blue,
                  ),
                  _buildCategoryCard(
                    'Account Issues',
                    Icons.person_outline,
                    AppColors.orange100,
                    AppColors.orange,
                  ),
                  _buildCategoryCard(
                    'Privacy & Safety',
                    Icons.shield_outlined,
                    AppColors.green100,
                    AppColors.green,
                  ),
                  _buildCategoryCard(
                    'Billing & Plans',
                    Icons.credit_card_outlined,
                    AppColors.purple100,
                    AppColors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Popular Articles',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Articles List
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.hexFFF0F0F0),
                ),
                child: Column(
                  children: [
                    _buildArticleTile(
                      'How to reset your password',
                      'Account',
                      AppColors.hexFFE0F2F1,
                    ),
                    const Divider(height: 1, color: AppColors.hexFFF0F0F0),
                    _buildArticleTile(
                      'Managing privacy settings',
                      'Privacy',
                      AppColors.hexFFE0F2F1,
                    ),
                    const Divider(height: 1, color: AppColors.hexFFF0F0F0),
                    _buildArticleTile(
                      'Setting up Two-Factor Authentication',
                      'Security',
                      AppColors.hexFFE0F2F1,
                    ),
                    const Divider(height: 1, color: AppColors.hexFFF0F0F0),
                    _buildArticleTile(
                      'Reporting inappropriate content',
                      'Safety',
                      AppColors.hexFFE0F2F1,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Need more help card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.hexFFF0F0F0),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.hexFFE0F2F1,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.headset_mic_outlined,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Need more help?',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Our team is here for you',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: () {
                          AppGet.snackbar(
                            'Support Chat',
                            'Static support chat opened',
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Chat with Us',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          AppGet.snackbar(
                            'Email Support',
                            'Static email support compose opened',
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.hexFFE0F2F1),
                          backgroundColor: AppColors.hexFFF4FDFA,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Email Support',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Average response time: ~2 hours',
                      style: TextStyle(fontSize: 12, color: AppColors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey,
        currentIndex: 0,
        onTap: _handleBottomNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline),
            label: 'Reels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 40, color: AppColors.primary),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _handleBottomNavTap(int index) {
    if (index == 2) {
      AppGet.toNamed(RouteNames.create);
      return;
    }

    final tabIndexMap = <int, int>{0: 0, 1: 1, 3: 3, 4: 4};
    final tabIndex = tabIndexMap[index];
    if (tabIndex == null) {
      return;
    }

    AppGet.offNamed(
      RouteNames.shell,
      arguments: <String, dynamic>{'tabIndex': tabIndex},
    );
  }

  Widget _buildCategoryCard(
    String title,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        AppGet.snackbar(title, 'Static $title help category opened');
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.hexFFF0F0F0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleTile(String title, String tag, Color tagBgColor) {
    return ListTile(
      onTap: () {
        AppGet.snackbar(title, 'Static article opened');
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.hexFFF5F5F5,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.article_outlined, color: AppColors.grey, size: 20),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: tagBgColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              tag,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: AppColors.grey,
      ),
    );
  }
}


