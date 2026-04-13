import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/navigation/app_get.dart';
import '../controller/marketplace_controller.dart';
import '../model/marketplace_order_model.dart';
import '../model/product_model.dart';
import '../widget/product_card.dart';
import 'marketplace_chat_screen.dart';
import 'seller_profile_screen.dart';
import '../../../core/constants/app_colors.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({
    super.key,
    required this.controller,
    required this.productId,
  });

  final MarketplaceController controller;
  final String productId;

  @override
  Widget build(BuildContext context) {
    final product = controller.productById(productId);
    controller.markViewed(product.id);
    final seller = controller.sellerById(product.sellerId);
    final similar = controller.similarProducts(product);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            pinned: true,
            title: const Text('Listing details'),
            actions: [
              IconButton(
                onPressed: () => controller.toggleSave(product.id),
                icon: Icon(
                  controller.savedItemIds.contains(product.id)
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                ),
              ),
              IconButton(
                onPressed: () =>
                    AppGet.snackbar('Share listing', 'Share sheet opened'),
                icon: const Icon(Icons.share_outlined),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 280,
              child: PageView.builder(
                itemCount: product.images.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.network(
                        product.images[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  product.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  NumberFormat.currency(symbol: '\$').format(product.price),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (product.isNegotiable) _pill(context, 'Negotiable'),
                    _pill(context, product.condition.label),
                    _pill(
                      context,
                      '${product.category} / ${product.subcategory}',
                    ),
                    _pill(context, product.location),
                    _pill(
                      context,
                      'Posted ${DateFormat('MMM d').format(product.timePosted)}',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _sectionCard(
                  context,
                  'Delivery & availability',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.deliveryOptions
                            .map((item) => item.label)
                            .join(' • '),
                      ),
                      const SizedBox(height: 8),
                      Text(product.distanceLabel),
                      if (product.isAuction) ...[
                        const SizedBox(height: 8),
                        const Text('Auction listing enabled'),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _sectionCard(context, 'Description', Text(product.description)),
                const SizedBox(height: 16),
                _sectionCard(
                  context,
                  'Product attributes / specifications',
                  Column(
                    children: product.attributes.entries.map((entry) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(entry.key),
                        trailing: Text(entry.value),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => MarketplaceSellerProfileScreen(
                          controller: controller,
                          seller: seller,
                        ),
                      ),
                    );
                  },
                  child: _sectionCard(
                    context,
                    'Seller info',
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(seller.avatar),
                          radius: 26,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    seller.name,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  if (seller.isVerified) ...[
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Icons.verified_rounded,
                                      size: 18,
                                      color: AppColors.blue,
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                '${seller.rating} rating • ${seller.responseRate}% response rate',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _sectionCard(
                  context,
                  'Offer history timeline',
                  Column(
                    children: [
                      ...controller.offerHistory.map(
                        (event) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.timeline_rounded),
                          title: Text(
                            '${event.actor} ${event.action.toLowerCase()}',
                          ),
                          subtitle: Text(
                            DateFormat(
                              'MMM d • h:mm a',
                            ).format(event.timestamp),
                          ),
                          trailing: Text(
                            '\$${event.amount.toStringAsFixed(0)}',
                          ),
                        ),
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Chip(label: Text('Offer expires in 18h')),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _sectionCard(
                  context,
                  'Reviews & trust features',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Product reviews: ${product.reviewCount}'),
                      const SizedBox(height: 10),
                      ...product.reviews.map(
                        (review) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('${review.author} • ${review.rating}'),
                          subtitle: Text(
                            '${review.comment}\n${review.dateLabel}',
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          const Chip(label: Text('Verified seller badge')),
                          const Chip(label: Text('Buyer ratings enabled')),
                          const Chip(label: Text('Scam report available')),
                          const Chip(label: Text('Safety guidelines visible')),
                          Chip(label: Text(controller.suspiciousScan(product))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _sectionCard(
                  context,
                  'Safety tips',
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Meet in public when possible.'),
                      Text('Inspect the item before payment.'),
                      Text('Use in-app messaging for a record of agreements.'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _sectionCard(
                  context,
                  'Social app integration',
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ActionChip(
                        label: const Text('Share to feed'),
                        onPressed: () =>
                            AppGet.snackbar('Marketplace', 'Shared to feed'),
                      ),
                      ActionChip(
                        label: const Text('Share to story'),
                        onPressed: () =>
                            AppGet.snackbar('Marketplace', 'Shared to story'),
                      ),
                      ActionChip(
                        label: const Text('Follow seller'),
                        onPressed: () =>
                            controller.toggleFollowSeller(seller.id),
                      ),
                      ActionChip(
                        label: const Text('Compare item'),
                        onPressed: () => controller.toggleCompare(product.id),
                      ),
                      ActionChip(
                        label: const Text('Marketplace comments'),
                        onPressed: () =>
                            AppGet.snackbar('Marketplace', 'Comments opened'),
                      ),
                      ActionChip(
                        label: const Text('QR product share'),
                        onPressed: () => AppGet.snackbar(
                          'Marketplace',
                          'QR share generated',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Similar items',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 320,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: similar.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final item = similar[index];
                      return SizedBox(
                        width: 220,
                        child: ProductCard(
                          product: item,
                          controller: controller,
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute<void>(
                                builder: (_) => ProductDetailsScreen(
                                  controller: controller,
                                  productId: item.id,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => MarketplaceChatScreen(
                        controller: controller,
                        product: product,
                      ),
                    ),
                  );
                },
                child: const Text('Message seller'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: () =>
                    AppGet.snackbar('Call seller', 'Calling is mocked for now'),
                child: const Text('Call'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _makeOffer(context, product),
                child: const Text('Make offer'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: () => _buyNow(context, product),
                child: Text(
                  controller.checkoutEnabled ? 'Buy now' : 'Message to buy',
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AppGet.snackbar('Cart', 'Added to cart'),
        icon: const Icon(Icons.add_shopping_cart_outlined),
        label: const Text('Add to cart'),
      ),
    );
  }

  Widget _pill(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label),
    );
  }

  Widget _sectionCard(BuildContext context, String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Future<void> _makeOffer(BuildContext context, ProductModel product) async {
    final controllerText = TextEditingController(
      text: controller.randomCounterOffer(product).toStringAsFixed(0),
    );
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Make an offer',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controllerText,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(prefixText: '\$'),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  final amount = double.tryParse(controllerText.text);
                  if (amount != null) {
                    controller.sendOffer(amount);
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Send offer'),
              ),
            ],
          ),
        );
      },
    );
    controllerText.dispose();
  }

  void _buyNow(BuildContext context, ProductModel product) {
    if (!controller.checkoutEnabled) {
      AppGet.snackbar('Marketplace', 'External purchase flow disabled for now');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            _CheckoutScreen(controller: controller, product: product),
      ),
    );
  }
}

class _CheckoutScreen extends StatelessWidget {
  const _CheckoutScreen({required this.controller, required this.product});

  final MarketplaceController controller;
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                product.images.first,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(product.title),
            subtitle: Text('\$${product.price.toStringAsFixed(0)}'),
          ),
          const SizedBox(height: 20),
          _checkoutCard(
            context,
            'Shipping address',
            const Text('House 14, Road 7, Dhanmondi, Dhaka'),
          ),
          const SizedBox(height: 16),
          _checkoutCard(
            context,
            'Delivery method',
            Text(product.deliveryOptions.map((item) => item.label).join(', ')),
          ),
          const SizedBox(height: 16),
          _checkoutCard(
            context,
            'Payment method',
            const Text('Wallet • Cash on delivery • Card on file'),
          ),
          const SizedBox(height: 16),
          _checkoutCard(
            context,
            'Order summary',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Subtotal: \$${product.price.toStringAsFixed(0)}'),
                const Text('Shipping: \$12'),
                Text('Total: \$${(product.price + 12).toStringAsFixed(0)}'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _checkoutCard(
            context,
            'Order status tabs',
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MarketplaceOrderStatus.values
                  .map((status) => Chip(label: Text(status.label)))
                  .toList(),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              controller.placeOrder(product);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (_) => _OrderSuccessScreen(product: product),
                ),
              );
            },
            child: const Text('Confirm order'),
          ),
        ],
      ),
    );
  }

  Widget _checkoutCard(BuildContext context, String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _OrderSuccessScreen extends StatelessWidget {
  const _OrderSuccessScreen({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                size: 88,
                color: AppColors.green,
              ),
              const SizedBox(height: 16),
              Text(
                'Order placed',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text('Your order for ${product.title} has been confirmed.'),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text('Back to Marketplace'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

