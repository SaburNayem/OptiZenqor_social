import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/navigation/app_get.dart';
import '../controller/marketplace_controller.dart';
import '../model/product_model.dart';
import '../model/seller_model.dart';
import '../../../core/constants/app_colors.dart';

class MarketplaceSellerProfileScreen extends StatelessWidget {
  const MarketplaceSellerProfileScreen({
    super.key,
    required this.controller,
    required this.seller,
  });

  final MarketplaceController controller;
  final SellerModel seller;

  @override
  Widget build(BuildContext context) {
    final isFollowed = controller.followedSellerIds.contains(seller.id);
    final sellerListings = controller.allProducts
        .where((item) => item.sellerId == seller.id)
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller profile'),
        actions: [
          IconButton(
            onPressed: () => AppGet.snackbar('Seller', 'Seller reported'),
            icon: const Icon(Icons.flag_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundImage: NetworkImage(seller.avatar),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            seller.name,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        if (seller.isVerified) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.verified_rounded,
                            color: AppColors.blue,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${seller.sellerType.label} • Joined ${DateFormat('MMM y').format(seller.joinDate)}',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${seller.rating} rating • ${seller.followers} followers',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(seller.bio),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () => AppGet.snackbar(
                    'Marketplace',
                    'Message flow available from listing details',
                  ),
                  child: const Text('Message seller'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
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
                  child: Text(isFollowed ? 'Following' : 'Follow seller'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _StatGrid(seller: seller),
          const SizedBox(height: 20),
          _SectionCard(
            title: 'Reviews',
            child: Column(
              children: seller.reviews
                  .map(
                    (review) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('${review.buyerName} • ${review.rating}'),
                      subtitle: Text('${review.comment}\n${review.dateLabel}'),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Active listings',
            trailing: Text('${sellerListings.length}'),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: sellerListings
                  .map(
                    (item) => Chip(
                      label: Text(item.title),
                      avatar: const Icon(Icons.shopping_bag_outlined, size: 18),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Trust & moderation',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Response rate: ${seller.responseRate}%'),
                Text('Response time: ${seller.responseTime}'),
                Text('Seller strike status: ${seller.strikeStatus}'),
                Text('Completed orders: ${seller.completedOrders}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.seller});

  final SellerModel seller;

  @override
  Widget build(BuildContext context) {
    final stats = <MapEntry<String, String>>[
      MapEntry('Response rate', '${seller.responseRate}%'),
      MapEntry('Response time', seller.responseTime),
      MapEntry('Listings', '${seller.activeListings}'),
      MapEntry('Followers', '${seller.followers}'),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.4,
      ),
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(stat.value, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(stat.key),
            ],
          ),
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              ...(trailing == null ? const <Widget>[] : <Widget>[trailing!]),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
