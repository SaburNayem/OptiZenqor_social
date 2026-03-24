import 'package:flutter/material.dart';

import '../../../core/common_data/mock_data.dart';
import '../widget/settings_tiles.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = MockData.users.first;
    return Scaffold(
      appBar: AppBar(title: const Text('Account Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: CircleAvatar(backgroundImage: NetworkImage(user.avatar)),
            title: Text(user.name),
            subtitle: Text('@${user.username}'),
            trailing: const Icon(Icons.edit_outlined),
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          const SettingsNavigationTile(
            title: 'Edit profile details',
            subtitle: 'Name, username, bio, and links',
            icon: Icons.person_outline,
          ),
          const SettingsNavigationTile(
            title: 'Update email',
            subtitle: 'Manage your primary email address',
            icon: Icons.email_outlined,
          ),
          const SettingsNavigationTile(
            title: 'Update phone number',
            subtitle: 'Recovery and sign-in phone',
            icon: Icons.phone_outlined,
          ),
          const SettingsNavigationTile(
            title: 'Download my data',
            subtitle: 'Request a copy of your data',
            icon: Icons.download_outlined,
          ),
          const SettingsNavigationTile(
            title: 'Deactivate account',
            subtitle: 'Temporarily disable your account',
            icon: Icons.pause_circle_outline,
            isDestructive: true,
          ),
          const SettingsNavigationTile(
            title: 'Delete account',
            subtitle: 'Permanently remove your account',
            icon: Icons.delete_forever_outlined,
            isDestructive: true,
          ),
        ],
      ),
    );
  }
}
