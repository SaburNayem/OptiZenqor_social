import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/common_data/mock_data.dart';

class WalletPaymentsScreen extends StatelessWidget {
  const WalletPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = MockData.users.first;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Wallet',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {},
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.black87),
                onPressed: () {},
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
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
                  colors: [Color(0xFF26C6DA), Color(0xFF00838F)],
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Balance',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '\$2,450.00',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Active Status',
                          style: TextStyle(color: Colors.white, fontSize: 12),
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
                _buildActionButton(Icons.arrow_outward, 'Send', const Color(0xFFE0F7FA), const Color(0xFF00ACC1)),
                _buildActionButton(Icons.arrow_downward, 'Receive', const Color(0xFFE0F7FA), const Color(0xFF00ACC1)),
                _buildActionButton(Icons.add, 'Top Up', const Color(0xFFE0F7FA), const Color(0xFF00ACC1)),
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
                  style: TextStyle(color: const Color(0xFF00ACC1), fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Transactions List
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  _buildTransactionItem(
                    Icons.star_outline,
                    'Creator Payout',
                    'Today, 2:30 PM',
                    '+\$150.00',
                    true,
                    const Color(0xFFE8F5E9),
                    const Color(0xFF4CAF50),
                  ),
                  _buildTransactionItem(
                    Icons.credit_card,
                    'Premium Subscription',
                    'Yesterday',
                    '-\$9.99',
                    false,
                    const Color(0xFFF5F5F5),
                    const Color(0xFF424242),
                  ),
                  _buildTransactionItem(
                    Icons.shopping_bag_outlined,
                    'Marketplace Purchase',
                    'Oct 12, 2023',
                    '-\$24.99',
                    false,
                    const Color(0xFFF5F5F5),
                    const Color(0xFF424242),
                  ),
                  _buildTransactionItem(
                    Icons.card_giftcard,
                    'Tip Received',
                    'Oct 10, 2023',
                    '+\$5.00',
                    true,
                    const Color(0xFFE8F5E9),
                    const Color(0xFF4CAF50),
                  ),
                  _buildTransactionItem(
                    Icons.add,
                    'Wallet Top Up',
                    'Oct 01, 2023',
                    '+\$50.00',
                    true,
                    const Color(0xFFE0F7FA),
                    const Color(0xFF00ACC1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color bgColor, Color iconColor) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
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
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
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
                  color: isCredit ? const Color(0xFF4CAF50) : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Completed',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
