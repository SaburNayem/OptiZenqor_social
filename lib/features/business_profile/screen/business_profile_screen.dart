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
          final profile = _controller.profile;
          if (profile == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(child: ListTile(title: Text(profile.name), subtitle: Text(profile.info))),
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
              Card(child: ListTile(title: const Text('Analytics'), subtitle: Text(profile.analyticsPlaceholder))),
              const SizedBox(height: 8),
              const Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.quickreply_outlined),
                      title: Text('Quick reply templates placeholder'),
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.description_outlined),
                      title: Text('Lead form placeholder'),
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.inbox_outlined),
                      title: Text('Inquiry inbox placeholder'),
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.smart_toy_outlined),
                      title: Text('Auto-reply placeholder'),
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
