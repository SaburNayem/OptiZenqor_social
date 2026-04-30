import 'package:flutter/material.dart';

import '../controller/business_profile_controller.dart';

class BusinessProfileScreen extends StatelessWidget {
  BusinessProfileScreen({super.key}) {
    _controller.load();
  }

  final BusinessProfileController _controller = BusinessProfileController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Business Profile')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if ((_controller.errorMessage ?? '').isNotEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.business_center_outlined, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      _controller.errorMessage!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _controller.load,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final profile = _controller.profile;
          if (profile == null) {
            return const Center(
              child: Text('No business profile data is available yet.'),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  title: Text(profile.name),
                  subtitle: Text(profile.info),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.call_outlined),
                      label: const Text('Call'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.mail_outline),
                      label: const Text('Email'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  title: const Text('Analytics'),
                  subtitle: Text(profile.analyticsPlaceholder),
                ),
              ),
              const SizedBox(height: 8),
              const Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.quickreply_outlined),
                      title: Text('Quick reply automation'),
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.description_outlined),
                      title: Text('Lead capture form'),
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.inbox_outlined),
                      title: Text('Inquiry inbox'),
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.smart_toy_outlined),
                      title: Text('Auto-reply rules'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
