import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/navigation/app_get.dart';
import '../controller/marketplace_controller.dart';
import '../model/product_model.dart';
import '../../../core/constants/app_colors.dart';

class MarketplaceChatScreen extends StatefulWidget {
  const MarketplaceChatScreen({
    super.key,
    required this.controller,
    required this.product,
  });

  final MarketplaceController controller;
  final ProductModel product;

  @override
  State<MarketplaceChatScreen> createState() => _MarketplaceChatScreenState();
}

class _MarketplaceChatScreenState extends State<MarketplaceChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.product.sellerName),
                Text(
                  widget.product.title,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) =>
                    AppGet.snackbar('Marketplace chat', '$value selected'),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'Block user', child: Text('Block user')),
                  PopupMenuItem(
                    value: 'Report user',
                    child: Text('Report user'),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              _ProductStrip(product: widget.product),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final reply in const [
                      'Is this available?',
                      'What is the last price?',
                      'Can you deliver?',
                    ])
                      ActionChip(
                        label: Text(reply),
                        onPressed: () =>
                            widget.controller.sendQuickReply(reply),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: widget.controller.chatMessages.length,
                  itemBuilder: (context, index) {
                    final message = widget.controller.chatMessages[index];
                    final isMine = message.senderName == 'You';
                    return Align(
                      alignment: isMine
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        width: MediaQuery.sizeOf(context).width * 0.72,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isMine
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (message.productTitle != null)
                              Text(
                                message.productTitle!,
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            if (message.imageUrl != null) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  message.imageUrl!,
                                  height: 140,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                            Text(message.text),
                            if (message.isOffer && message.offerAmount != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.white.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    'Offer: \$${message.offerAmount!.toStringAsFixed(0)}',
                                  ),
                                ),
                              ),
                            const SizedBox(height: 8),
                            Text(
                              DateFormat(
                                'MMM d • h:mm a',
                              ).format(message.timestamp),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showOfferSheet(context),
                            icon: const Icon(Icons.local_offer_outlined),
                            label: const Text('Offer price'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => widget.controller.sendMessage(
                              '',
                              imageUrl:
                                  'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=600&q=80',
                            ),
                            icon: const Icon(Icons.image_outlined),
                            label: const Text('Image'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton.filledTonal(
                          onPressed: () => AppGet.snackbar(
                            'Voice note',
                            'Voice note composer opened',
                          ),
                          icon: const Icon(Icons.mic_none_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: 'Write a message',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton.filled(
                          onPressed: () {
                            widget.controller.sendMessage(
                              _messageController.text,
                            );
                            _messageController.clear();
                          },
                          icon: const Icon(Icons.send_rounded),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showOfferSheet(BuildContext context) async {
    final priceController = TextEditingController(
      text: widget.product.price.toStringAsFixed(0),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Make an offer',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(prefixText: '\$'),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  final amount = double.tryParse(priceController.text);
                  if (amount != null) {
                    widget.controller.sendOffer(amount);
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
    priceController.dispose();
  }
}

class _ProductStrip extends StatelessWidget {
  const _ProductStrip({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              product.images.first,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text('\$${product.price.toStringAsFixed(0)}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

