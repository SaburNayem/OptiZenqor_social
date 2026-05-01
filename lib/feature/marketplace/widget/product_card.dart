import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../controller/marketplace_controller.dart';
import '../model/product_model.dart';
import '../../../core/constants/app_colors.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.controller,
    required this.onTap,
    this.compact = false,
  });

  final ProductModel product;
  final MarketplaceController controller;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final saved = controller.savedItemIds.contains(product.id);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: compact
            ? _buildCompact(context, saved)
            : _buildVertical(context, saved),
      ),
    );
  }

  Widget _buildVertical(BuildContext context, bool saved) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: AspectRatio(
                aspectRatio: 1.6,
                child: Image.network(product.images.first, fit: BoxFit.cover),
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: _Badge(label: product.condition.label),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.black.withValues(alpha: 0.35),
                child: IconButton(
                  style: IconButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(32, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () => controller.toggleSave(product.id),
                  icon: Icon(
                    saved
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: AppColors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      NumberFormat.currency(symbol: '\$').format(product.price),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product.location} • ${_timeAgo(product.timePosted)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Flexible(child: _Pill(label: product.condition.label)),
                    const SizedBox(width: 6),
                    Flexible(child: _Pill(label: product.sellerType.label)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompact(BuildContext context, bool saved) {
    final theme = Theme.of(context);
    return Row(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(24),
          ),
          child: SizedBox(
            width: 112,
            height: 112,
            child: Image.network(product.images.first, fit: BoxFit.cover),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      onPressed: () => controller.toggleSave(product.id),
                      icon: Icon(
                        saved
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  NumberFormat.currency(symbol: '\$').format(product.price),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${product.location} • ${_timeAgo(product.timePosted)}',
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  '${product.condition.label} • ${product.sellerType.label}',
                  style: theme.textTheme.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _timeAgo(DateTime time) {
    final difference = DateTime.now().difference(time);
    if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours}h';
    }
    return '${difference.inDays}d';
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}
