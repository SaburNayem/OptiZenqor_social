import 'package:flutter/material.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  static const List<_MarketplaceItem> _allItems = <_MarketplaceItem>[
    _MarketplaceItem(
      title: 'Creator Camera Rig',
      price: '\$249.00',
      location: 'Dhaka',
      icon: Icons.videocam_outlined,
    ),
    _MarketplaceItem(
      title: 'Studio LED Light',
      price: '\$89.00',
      location: 'Chattogram',
      icon: Icons.lightbulb_outline_rounded,
    ),
    _MarketplaceItem(
      title: 'Podcast Mic Set',
      price: '\$129.00',
      location: 'Sylhet',
      icon: Icons.mic_none_rounded,
    ),
    _MarketplaceItem(
      title: 'Social Brand Kit',
      price: '\$59.00',
      location: 'Remote',
      icon: Icons.palette_outlined,
    ),
  ];

  String _query = '';

  List<_MarketplaceItem> get _visibleItems {
    final term = _query.trim().toLowerCase();
    if (term.isEmpty) {
      return _allItems;
    }
    return _allItems
        .where((item) =>
            item.title.toLowerCase().contains(term) ||
            item.location.toLowerCase().contains(term))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Marketplace')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search products',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: Text('Cart placeholder')),
                    Chip(label: Text('Checkout placeholder')),
                    Chip(label: Text('Saved addresses')),
                    Chip(label: Text('Order history')),
                    Chip(label: Text('Order status')),
                    Chip(label: Text('Return/refund')),
                    Chip(label: Text('Wishlist')),
                    Chip(label: Text('Nearby marketplace items')),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _visibleItems.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (context, index) {
                final item = _visibleItems[index];
                return Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                          ),
                          child: Icon(
                            item.icon,
                            size: 52,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(item.price),
                            Text(item.location),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketplaceItem {
  const _MarketplaceItem({
    required this.title,
    required this.price,
    required this.location,
    required this.icon,
  });

  final String title;
  final String price;
  final String location;
  final IconData icon;
}
