import 'package:flutter/material.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('Edit name and username'),
          ),
          ListTile(
            leading: Icon(Icons.email_outlined),
            title: Text('Update email'),
          ),
          ListTile(
            leading: Icon(Icons.phone_outlined),
            title: Text('Update phone number'),
          ),
          ListTile(
            leading: Icon(Icons.download_outlined),
            title: Text('Download my data'),
          ),
          ListTile(
            leading: Icon(Icons.upload_file_outlined),
            title: Text('Resume/profile export placeholder'),
          ),
          ListTile(
            leading: Icon(Icons.pause_circle_outline),
            title: Text('Deactivate account placeholder'),
          ),
          ListTile(
            leading: Icon(Icons.delete_forever_outlined),
            title: Text('Delete account placeholder'),
          ),
        ],
      ),
    );
  }
}
