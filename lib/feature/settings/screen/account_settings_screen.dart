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
        ],
      ),
    );
  }
}
