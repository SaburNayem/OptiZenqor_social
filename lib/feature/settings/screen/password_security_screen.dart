import 'package:flutter/material.dart';

class PasswordSecurityScreen extends StatelessWidget {
  const PasswordSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Password & Security')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.lock_outline),
            title: Text('Change password'),
          ),
          ListTile(
            leading: Icon(Icons.verified_user_outlined),
            title: Text('Two-factor authentication'),
          ),
          ListTile(
            leading: Icon(Icons.security_outlined),
            title: Text('Security alerts'),
          ),
        ],
      ),
    );
  }
}
