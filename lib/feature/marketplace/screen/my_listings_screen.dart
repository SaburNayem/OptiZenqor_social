import 'package:flutter/material.dart';

import '../../../core/navigation/app_get.dart';
import '../controller/marketplace_controller.dart';
import '../model/product_model.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key, required this.controller});

  final MarketplaceController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _moderationCard(context),
        const SizedBox(height: 16),
        for (final status in ListingStatus.values) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  status.label,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Text('${controller.listingsByStatus(status).length}'),
            ],
          ),
          const SizedBox(height: 10),
          ...controller
              .listingsByStatus(status)
              .map(
                (listing) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ListingCard(listing: listing, controller: controller),
                ),
              ),
          if (controller.listingsByStatus(status).isEmpty)
            _emptyBlock(
              context,
              'No ${status.label.toLowerCase()} listings yet',
            ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _moderationCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.surfaceContainerHighest,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Admin & moderation ready',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          const Text(
            'Listing approval toggle, review status, report queue, banned keywords, and seller warning state are surfaced here.',
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              Chip(
                label: Text(
                  'Approval: ${controller.listingApprovalEnabled ? 'On' : 'Off'}',
                ),
              ),
              Chip(
                label: Text(
                  'Auto-hide: ${controller.autoHideSuspiciousListings ? 'On' : 'Off'}',
                ),
              ),
              Chip(
                label: Text('Keywords: ${controller.blockedKeywords.length}'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyBlock(BuildContext context, String message) {
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

class _ListingCard extends StatelessWidget {
  const _ListingCard({required this.listing, required this.controller});

  final ProductModel listing;
  final MarketplaceController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(
                  listing.images.first,
                  width: 86,
                  height: 86,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('\$${listing.price.toStringAsFixed(0)}'),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: [
                        Chip(label: Text(listing.reviewStatus)),
                        Chip(label: Text('${listing.views} views')),
                        Chip(label: Text('${listing.chats} chats')),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: () =>
                    AppGet.snackbar('Marketplace', 'Edit listing opened'),
                child: const Text('Edit'),
              ),
              OutlinedButton(
                onPressed: () => controller.markAsSold(listing.id),
                child: const Text('Mark as sold'),
              ),
              OutlinedButton(
                onPressed: () => controller.pauseListing(listing.id),
                child: const Text('Pause listing'),
              ),
              OutlinedButton(
                onPressed: () async => controller.deleteListing(listing.id),
                child: const Text('Delete'),
              ),
              OutlinedButton(
                onPressed: () =>
                    AppGet.snackbar('Marketplace', 'Boost flow opened'),
                child: const Text('Promote / Boost'),
              ),
              OutlinedButton(
                onPressed: () => AppGet.snackbar(
                  'Analytics',
                  'Views ${listing.views} • Watchers ${listing.watchers}',
                ),
                child: const Text('View stats'),
              ),
              OutlinedButton(
                onPressed: () =>
                    AppGet.snackbar('Marketplace', 'Listing chats opened'),
                child: const Text('View chats'),
              ),
              OutlinedButton(
                onPressed: () => controller.repostListing(listing.id),
                child: const Text('Repost listing'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
