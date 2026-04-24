import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../core/constants/app_colors.dart';
import '../../home_feed/controller/main_shell_controller.dart';

class WalletPaymentsScreen extends StatelessWidget {
  const WalletPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainShellController, int>(
      builder: (context, _) {
        final currentUser = context.read<MainShellController>().currentUser;
        return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black87),
          onPressed: () => AppGet.back(),
        ),
        title: const Text(
          'Wallet',
          style: TextStyle(color: AppColors.black87, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.black87),
            onPressed: () {},
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none,
                  color: AppColors.black87,
                ),
                onPressed: () {},
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(currentUser.avatar),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.hexFF26C6DA, AppColors.hexFF00838F],
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Balance',
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '\$2,450.00',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.hexFF4CAF50,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Active Status',
                          style: TextStyle(color: AppColors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  Icons.arrow_outward,
                  'Send',
                  AppColors.hexFFE0F7FA,
                  AppColors.hexFF00ACC1,
                ),
                _buildActionButton(
                  Icons.arrow_downward,
                  'Receive',
                  AppColors.hexFFE0F7FA,
                  AppColors.hexFF00ACC1,
                ),
                _buildActionButton(
                  Icons.add,
                  'Top Up',
                  AppColors.hexFFE0F7FA,
                  AppColors.hexFF00ACC1,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Recent Transactions Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Transactions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'See All',
                  style: TextStyle(
                    color: AppColors.hexFF00ACC1,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Transactions List
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.grey100),
              ),
              child: Column(
                children: [
                  _buildTransactionItem(
                    Icons.star_outline,
                    'Creator Payout',
                    'Today, 2:30 PM',
                    '+\$150.00',
                    true,
                    AppColors.hexFFE8F5E9,
                    AppColors.hexFF4CAF50,
                  ),
                  _buildTransactionItem(
                    Icons.credit_card,
                    'Premium Subscription',
                    'Yesterday',
                    '-\$9.99',
                    false,
                    AppColors.hexFFF5F5F5,
                    AppColors.hexFF424242,
                  ),
                  _buildTransactionItem(
                    Icons.shopping_bag_outlined,
                    'Marketplace Purchase',
                    'Oct 12, 2023',
                    '-\$24.99',
                    false,
                    AppColors.hexFFF5F5F5,
                    AppColors.hexFF424242,
                  ),
                  _buildTransactionItem(
                    Icons.card_giftcard,
                    'Tip Received',
                    'Oct 10, 2023',
                    '+\$5.00',
                    true,
                    AppColors.hexFFE8F5E9,
                    AppColors.hexFF4CAF50,
                  ),
                  _buildTransactionItem(
                    Icons.add,
                    'Wallet Top Up',
                    'Oct 01, 2023',
                    '+\$50.00',
                    true,
                    AppColors.hexFFE0F7FA,
                    AppColors.hexFF00ACC1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
        );
      },
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    Color bgColor,
    Color iconColor,
  ) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            color: AppColors.grey600,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(
    IconData icon,
    String title,
    String date,
    String amount,
    bool isCredit,
    Color iconBgColor,
    Color iconColor,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(color: AppColors.grey500, fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isCredit ? AppColors.hexFF4CAF50 : AppColors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Completed',
                  style: TextStyle(color: AppColors.grey500, fontSize: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


