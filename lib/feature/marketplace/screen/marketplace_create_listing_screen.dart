import 'package:flutter/material.dart';

import '../../../core/data/models/user_model.dart';
import '../controller/marketplace_controller.dart';
import 'sell_product_screen.dart';

class MarketplaceCreateListingScreen extends StatelessWidget {
  const MarketplaceCreateListingScreen({
    super.key,
    required this.controller,
    required this.activeUser,
  });

  final MarketplaceController controller;
  final UserModel activeUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add product')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(activeUser.avatar),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selling as ${activeUser.name}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Verified seller access is ready for this account.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Chip(
                    avatar: Icon(Icons.verified_rounded, size: 18),
                    label: Text('Verified'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SellProductScreen(
              controller: controller,
              activeUser: activeUser,
              onPublished: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
