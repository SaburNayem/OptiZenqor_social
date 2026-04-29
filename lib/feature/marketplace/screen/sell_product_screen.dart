import 'package:flutter/material.dart';

import '../../../core/data/models/user_model.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/navigation/app_get.dart';
import '../controller/marketplace_controller.dart';
import '../model/product_model.dart';

class SellProductScreen extends StatefulWidget {
  const SellProductScreen({
    super.key,
    required this.controller,
    required this.activeUser,
    this.onPublished,
  });

  final MarketplaceController controller;
  final UserModel activeUser;
  final VoidCallback? onPublished;

  @override
  State<SellProductScreen> createState() => _SellProductScreenState();
}

class _SellProductScreenState extends State<SellProductScreen> {
  final _titleController = TextEditingController(text: 'Premium Desk Lamp');
  final _descriptionController = TextEditingController(
    text:
        'Modern LED lamp with adjustable temperature and creator-friendly color output.',
  );
  final _priceController = TextEditingController(text: '85');
  final _quantityController = TextEditingController(text: '2');
  final _tagsController = TextEditingController(text: 'lighting, studio, desk');
  final _locationController = TextEditingController(text: 'Banani, Dhaka');
  final _brandController = TextEditingController(text: 'Luma');
  final _colorController = TextEditingController(text: 'Matte Black');
  final _sizeController = TextEditingController(text: 'Medium');
  final _warrantyController = TextEditingController(text: '6 months');
  final _skuController = TextEditingController(text: 'LM-LAMP-01');
  final _variantController = TextEditingController(text: 'Warm + Cool');

  String _category = 'Electronics';
  String _subcategory = 'Lighting';
  ProductCondition _condition = ProductCondition.newItem;
  bool _negotiable = true;
  bool _boostListing = false;
  bool _pickup = true;
  bool _shipping = true;
  bool _delivery = false;
  String _contactPreference = 'Chat';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _tagsController.dispose();
    _locationController.dispose();
    _brandController.dispose();
    _colorController.dispose();
    _sizeController.dispose();
    _warrantyController.dispose();
    _skuController.dispose();
    _variantController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        _SectionCard(
          title: 'Add photos / videos',
          child: SizedBox(
            height: 110,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final icon in const [
                  Icons.add_a_photo_outlined,
                  Icons.video_camera_back_outlined,
                  Icons.photo_library_outlined,
                ])
                  Container(
                    width: 110,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(icon),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Listing details',
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Product title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: const [
                  DropdownMenuItem(
                    value: 'Electronics',
                    child: Text('Electronics'),
                  ),
                  DropdownMenuItem(
                    value: 'Home & Furniture',
                    child: Text('Home & Furniture'),
                  ),
                  DropdownMenuItem(
                    value: 'Digital Products',
                    child: Text('Digital Products'),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => _category = value ?? _category),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _subcategory,
                decoration: const InputDecoration(labelText: 'Subcategory'),
                items: const [
                  DropdownMenuItem(value: 'Lighting', child: Text('Lighting')),
                  DropdownMenuItem(value: 'Cameras', child: Text('Cameras')),
                  DropdownMenuItem(
                    value: 'Accessories',
                    child: Text('Accessories'),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => _subcategory = value ?? _subcategory),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ProductCondition>(
                initialValue: _condition,
                decoration: const InputDecoration(labelText: 'Condition'),
                items: ProductCondition.values.map((condition) {
                  return DropdownMenuItem<ProductCondition>(
                    value: condition,
                    child: Text(condition.label),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _condition = value ?? _condition),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  prefixText: '\$',
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _negotiable,
                onChanged: (value) => setState(() => _negotiable = value),
                contentPadding: EdgeInsets.zero,
                title: const Text('Negotiable'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _tagsController,
                decoration: const InputDecoration(labelText: 'Tags'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              const SizedBox(height: 12),
              Text(
                'Delivery options',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              CheckboxListTile(
                value: _pickup,
                onChanged: (value) =>
                    setState(() => _pickup = value ?? _pickup),
                contentPadding: EdgeInsets.zero,
                title: const Text('Local pickup'),
              ),
              CheckboxListTile(
                value: _shipping,
                onChanged: (value) =>
                    setState(() => _shipping = value ?? _shipping),
                contentPadding: EdgeInsets.zero,
                title: const Text('Shipping'),
              ),
              CheckboxListTile(
                value: _delivery,
                onChanged: (value) =>
                    setState(() => _delivery = value ?? _delivery),
                contentPadding: EdgeInsets.zero,
                title: const Text('Local delivery'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _contactPreference,
                decoration: const InputDecoration(
                  labelText: 'Contact preference',
                ),
                items: const [
                  DropdownMenuItem(value: 'Chat', child: Text('Chat')),
                  DropdownMenuItem(value: 'Phone', child: Text('Phone')),
                  DropdownMenuItem(
                    value: 'Chat + Phone',
                    child: Text('Chat + Phone'),
                  ),
                ],
                onChanged: (value) => setState(
                  () => _contactPreference = value ?? _contactPreference,
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _boostListing,
                onChanged: (value) => setState(() => _boostListing = value),
                contentPadding: EdgeInsets.zero,
                title: const Text('Boost listing'),
                subtitle: const Text(
                  'Promote as premium inventory in browse sections.',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Optional fields',
          child: Column(
            children: [
              TextField(
                controller: _brandController,
                decoration: const InputDecoration(labelText: 'Brand'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _colorController,
                decoration: const InputDecoration(labelText: 'Color'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _sizeController,
                decoration: const InputDecoration(labelText: 'Size'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _warrantyController,
                decoration: const InputDecoration(labelText: 'Warranty'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _skuController,
                decoration: const InputDecoration(labelText: 'SKU'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _variantController,
                decoration: const InputDecoration(labelText: 'Variant options'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Social & seller tools',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              Chip(label: Text('Share to feed')),
              Chip(label: Text('Share to story')),
              Chip(label: Text('Live selling ready')),
              Chip(label: Text('Group selling ready')),
              Chip(label: Text('Shop page enabled')),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _onSaveDraft,
                child: const Text('Save draft'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: _onPreview,
                child: const Text('Preview listing'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _onPublish,
                child: const Text('Publish listing'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Map<String, String> get _optionalFields => <String, String>{
    'Brand': _brandController.text,
    'Color': _colorController.text,
    'Size': _sizeController.text,
    'Warranty': _warrantyController.text,
    'SKU': _skuController.text,
    'Variant': _variantController.text,
    'Contact preference': _contactPreference,
  };

  List<DeliveryOption> get _deliveryOptions => <DeliveryOption>[
    if (_pickup) DeliveryOption.pickup,
    if (_shipping) DeliveryOption.shipping,
    if (_delivery) DeliveryOption.delivery,
  ];

  List<String> get _tags => _tagsController.text
      .split(',')
      .map((tag) => tag.trim())
      .where((tag) => tag.isNotEmpty)
      .toList();

  SellerType get _sellerType {
    if (widget.activeUser.verified ||
        widget.activeUser.verificationStatus.toLowerCase() == 'verified') {
      return SellerType.verified;
    }
    if (widget.activeUser.role == UserRole.business) {
      return SellerType.shop;
    }
    return SellerType.individual;
  }

  void _onSaveDraft() {
    widget.controller.saveDraft(
      title: _titleController.text,
      description: _descriptionController.text,
      category: _category,
      subcategory: _subcategory,
      condition: _condition,
      price: double.tryParse(_priceController.text) ?? 0,
      isNegotiable: _negotiable,
      quantity: int.tryParse(_quantityController.text) ?? 1,
      tags: _tags,
      location: _locationController.text,
      deliveryOptions: _deliveryOptions,
      optionalFields: _optionalFields,
      sellerId: widget.activeUser.id,
      sellerName: widget.activeUser.name,
      sellerAvatar: widget.activeUser.avatar,
      sellerType: _sellerType,
    );
    AppGet.snackbar(
      'Marketplace',
      'Draft saved on device. Backend draft persistence is not exposed for marketplace listings.',
    );
  }

  void _onPreview() {
    AppGet.snackbar(
      'Preview listing',
      'Preview shows title, pricing, moderation scan, and seller info',
    );
  }

  Future<void> _onPublish() async {
    final bool published = await widget.controller.publishDraft(
      title: _titleController.text,
      description: _descriptionController.text,
      category: _category,
      subcategory: _subcategory,
      condition: _condition,
      price: double.tryParse(_priceController.text) ?? 0,
      isNegotiable: _negotiable,
      quantity: int.tryParse(_quantityController.text) ?? 1,
      tags: _tags,
      location: _locationController.text,
      deliveryOptions: _deliveryOptions,
      boostListing: _boostListing,
      optionalFields: _optionalFields,
      sellerId: widget.activeUser.id,
      sellerName: widget.activeUser.name,
      sellerAvatar: widget.activeUser.avatar,
      sellerType: _sellerType,
    );
    if (!mounted) {
      return;
    }
    if (!published) {
      AppGet.snackbar('Marketplace', 'Unable to publish listing');
      return;
    }
    AppGet.snackbar('Marketplace', 'Listing published');
    widget.onPublished?.call();
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

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
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
