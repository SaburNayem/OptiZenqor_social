import 'package:flutter/material.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../app_route/route_names.dart';
import '../../../core/constants/app_colors.dart';
import '../controller/support_help_controller.dart';
import '../model/faq_item_model.dart';

class SupportHelpScreen extends StatefulWidget {
  const SupportHelpScreen({super.key});

  @override
  State<SupportHelpScreen> createState() => _SupportHelpScreenState();
}

class _SupportHelpScreenState extends State<SupportHelpScreen> {
  late final SupportHelpController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SupportHelpController()..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.black54),
            onPressed: () {
              AppGet.snackbar(
                'Search',
                'Use the FAQ list below to browse support topics.',
              );
            },
          ),
          Stack(
            alignment: Alignment.center,
            children: <Widget>[
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
      body: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, _) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_controller.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(
                      Icons.support_agent_outlined,
                      size: 36,
                      color: AppColors.grey,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _controller.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.grey),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _controller.load,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _controller.load,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.hexFFF5F5F5,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Support content is synced from the backend.',
                    style: TextStyle(color: AppColors.grey, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'How can we help?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildSummaryCard(),
                const SizedBox(height: 32),
                const Text(
                  'Popular Articles',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (_controller.faqs.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.hexFFF0F0F0),
                    ),
                    child: const Text(
                      'No support articles have been published yet.',
                      style: TextStyle(color: AppColors.grey),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.hexFFF0F0F0),
                    ),
                    child: Column(
                      children: <Widget>[
                        for (
                          int index = 0;
                          index < _controller.faqs.length;
                          index++
                        ) ...<Widget>[
                          _buildArticleTile(_controller.faqs[index]),
                          if (index < _controller.faqs.length - 1)
                            const Divider(
                              height: 1,
                              color: AppColors.hexFFF0F0F0,
                            ),
                        ],
                      ],
                    ),
                  ),
                const SizedBox(height: 32),
                _buildSupportActionsCard(),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey,
        currentIndex: 0,
        onTap: _handleBottomNavTap,
        items: const <BottomNavigationBarItem>[
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

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.hexFFF0F0F0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '${_controller.faqs.length} published support articles',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _controller.ticketCount > 0
                ? 'You have ${_controller.ticketCount} support ticket(s) on file.'
                : 'No support tickets found for this account yet.',
            style: const TextStyle(color: AppColors.grey),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              _buildBadge(
                label: _controller.hasChatThread
                    ? 'Chat ready'
                    : 'No chat thread yet',
              ),
              _buildBadge(
                label: _controller.responseTime.isNotEmpty
                    ? _controller.responseTime
                    : 'Response time unavailable',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSupportActionsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.hexFFF0F0F0),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
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
                children: <Widget>[
                  Text(
                    'Need more help?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Support options are now coming from the backend',
                    style: TextStyle(fontSize: 12, color: AppColors.grey),
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
                final String label = _controller.hasChatThread
                    ? 'Support chat is available in your synced account state.'
                    : 'Open a support ticket first to start a chat thread.';
                AppGet.snackbar('Support Chat', label);
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
                final String email = _controller.contactEmail.isNotEmpty
                    ? _controller.contactEmail
                    : _controller.escalationEmail;
                AppGet.snackbar(
                  'Email Support',
                  email.isEmpty ? 'No support email configured.' : email,
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
          Text(
            _controller.responseTime.isEmpty
                ? 'Average response time unavailable'
                : 'Average response time: ${_controller.responseTime}',
            style: const TextStyle(fontSize: 12, color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.hexFFF5F5F5,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildArticleTile(FaqItemModel item) {
    return ListTile(
      onTap: () {
        AppGet.snackbar(item.question, item.answer);
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.hexFFF5F5F5,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.article_outlined,
          color: AppColors.grey,
          size: 20,
        ),
      ),
      title: Text(
        item.question,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          item.answer,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: AppColors.grey),
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: AppColors.grey,
      ),
    );
  }

  void _handleBottomNavTap(int index) {
    if (index == 2) {
      AppGet.toNamed(RouteNames.create);
      return;
    }

    final Map<int, int> tabIndexMap = <int, int>{0: 0, 1: 1, 3: 3, 4: 4};
    final int? tabIndex = tabIndexMap[index];
    if (tabIndex == null) {
      return;
    }

    AppGet.offNamed(
      RouteNames.shell,
      arguments: <String, dynamic>{'tabIndex': tabIndex},
    );
  }
}
