import 'package:flutter/material.dart';

import '../model/marketplace_filter_model.dart';
import '../model/product_model.dart';

class MarketplaceFilterSheet extends StatefulWidget {
  const MarketplaceFilterSheet({
    super.key,
    required this.initialFilter,
    required this.categories,
  });

  final MarketplaceFilterModel initialFilter;
  final List<String> categories;

  @override
  State<MarketplaceFilterSheet> createState() => _MarketplaceFilterSheetState();
}

class _MarketplaceFilterSheetState extends State<MarketplaceFilterSheet> {
  late MarketplaceFilterModel _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Filters', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: _filter.category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: <DropdownMenuItem<String>>[
                  const DropdownMenuItem<String>(value: '', child: Text('All')),
                  ...widget.categories.map(
                    (category) => DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(
                    () => _filter = _filter.copyWith(
                      category: value == null || value.isEmpty ? null : value,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text('Price range', style: theme.textTheme.titleMedium),
              RangeSlider(
                values: RangeValues(_filter.minPrice, _filter.maxPrice),
                min: 0,
                max: 5000,
                divisions: 20,
                labels: RangeLabels(
                  _filter.minPrice.round().toString(),
                  _filter.maxPrice.round().toString(),
                ),
                onChanged: (values) {
                  setState(
                    () => _filter = _filter.copyWith(
                      minPrice: values.start,
                      maxPrice: values.end,
                    ),
                  );
                },
              ),
              Text('Location radius: ${_filter.locationRadius.round()} km'),
              Slider(
                value: _filter.locationRadius,
                min: 1,
                max: 100,
                divisions: 20,
                onChanged: (value) {
                  setState(
                    () => _filter = _filter.copyWith(locationRadius: value),
                  );
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ProductCondition?>(
                initialValue: _filter.condition,
                decoration: const InputDecoration(labelText: 'Condition'),
                items: [
                  const DropdownMenuItem<ProductCondition?>(
                    value: null,
                    child: Text('Any condition'),
                  ),
                  ...ProductCondition.values.map(
                    (condition) => DropdownMenuItem<ProductCondition?>(
                      value: condition,
                      child: Text(condition.label),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(
                    () => _filter = value == null
                        ? _filter.copyWith(clearCondition: true)
                        : _filter.copyWith(condition: value),
                  );
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                value: _filter.deliveryAvailable,
                onChanged: (value) {
                  setState(
                    () => _filter = _filter.copyWith(deliveryAvailable: value),
                  );
                },
                contentPadding: EdgeInsets.zero,
                title: const Text('Delivery available'),
              ),
              SwitchListTile(
                value: _filter.negotiableOnly,
                onChanged: (value) {
                  setState(
                    () => _filter = _filter.copyWith(negotiableOnly: value),
                  );
                },
                contentPadding: EdgeInsets.zero,
                title: const Text('Negotiable only'),
              ),
              SwitchListTile(
                value: _filter.verifiedSellersOnly,
                onChanged: (value) {
                  setState(
                    () =>
                        _filter = _filter.copyWith(verifiedSellersOnly: value),
                  );
                },
                contentPadding: EdgeInsets.zero,
                title: const Text('Verified sellers only'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<MarketplaceSort>(
                initialValue: _filter.sortBy,
                decoration: const InputDecoration(labelText: 'Sort by'),
                items: MarketplaceSort.values
                    .map(
                      (sort) => DropdownMenuItem<MarketplaceSort>(
                        value: sort,
                        child: Text(sort.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _filter = _filter.copyWith(sortBy: value));
                  }
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(
                        context,
                      ).pop(const MarketplaceFilterModel()),
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(_filter),
                      child: const Text('Apply filters'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
