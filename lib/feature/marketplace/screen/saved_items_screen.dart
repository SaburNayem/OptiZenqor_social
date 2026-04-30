import 'package:flutter/material.dart';

import '../../../core/navigation/app_get.dart';
import '../controller/marketplace_controller.dart';
import '../widget/product_card.dart';
import 'product_details_screen.dart';

class SavedItemsScreen extends StatelessWidget {
  const SavedItemsScreen({super.key, required this.controller});

  final MarketplaceController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text('Saved items', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (controller.savedItems.isEmpty)
          _emptyCard(context, 'Save items to compare or revisit later.')
        else
          ...controller.savedItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ProductCard(
                product: item,
                compact: true,
                controller: controller,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ProductDetailsScreen(
                        controller: controller,
                        productId: item.id,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        const SizedBox(height: 20),
        Text('Saved searches', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: controller.savedSearches
              .map((search) => Chip(label: Text(search)))
              .toList(),
        ),
        const SizedBox(height: 20),
        Text('Followed sellers', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        ...controller.sellers
            .where((seller) => controller.followedSellerIds.contains(seller.id))
            .map(
              (seller) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(seller.avatar),
                ),
                title: Text(seller.name),
                subtitle: Text(
                  '${seller.rating} rating • ${seller.responseTime}',
                ),
                trailing: FilledButton.tonal(
                  onPressed: () async {
                    final bool updated = await controller.toggleFollowSeller(
                      seller.id,
                    );
                    if (!context.mounted || updated) {
                      return;
                    }
                    AppGet.snackbar(
                      'Marketplace',
                      controller.errorMessage ??
                          'Unable to update seller follow state.',
                    );
                  },
                  child: const Text('Following'),
                ),
              ),
            ),
        const SizedBox(height: 20),
        Text(
          'Price drop alerts',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        ...controller.savedItems
            .where((item) => item.hasPriceDrop)
            .map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.notifications_active_outlined),
                title: Text(item.title),
                subtitle: const Text('Price dropped on a saved item'),
                trailing: Text('\$${item.price.toStringAsFixed(0)}'),
              ),
            ),
      ],
    );
  }

  Widget _emptyCard(BuildContext context, String message) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(message),
    );
  }
}
