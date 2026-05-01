import 'package:flutter/material.dart';

import '../controller/seller_profile_controller.dart';

class SellerProfileScreen extends StatelessWidget {
  const SellerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SellerProfileController();

    return Scaffold(
      appBar: AppBar(title: const Text('Seller Profile')),
      body: ListTile(
        title: Text(controller.profile.storeName),
        subtitle: Text(
          'Rating ${controller.profile.rating} • ${controller.profile.totalListings} listings',
        ),
      ),
    );
  }
}
