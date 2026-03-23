import 'package:flutter/material.dart';

class PasswordSecurityScreen extends StatefulWidget {
  const PasswordSecurityScreen({super.key});

  @override
  State<PasswordSecurityScreen> createState() => _PasswordSecurityScreenState();
}

class _PasswordSecurityScreenState extends State<PasswordSecurityScreen> {
  bool _twoFactorEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Password & Security')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: Icon(Icons.lock_outline),
            title: Text('Change password'),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.verified_user_outlined),
            title: const Text('Enable two-factor authentication'),
            subtitle: Text(_twoFactorEnabled ? '2FA enabled placeholder' : '2FA disabled'),
            value: _twoFactorEnabled,
            onChanged: (value) {
              setState(() {
                _twoFactorEnabled = value;
              });
            },
          ),
          const ListTile(
            leading: Icon(Icons.qr_code_2_outlined),
            title: Text('OTP app placeholder'),
          ),
          const ListTile(
            leading: Icon(Icons.password_outlined),
            title: Text('Backup codes placeholder'),
          ),
          const ListTile(
            leading: Icon(Icons.restore_outlined),
            title: Text('Recovery flow placeholder'),
          ),
          const ListTile(
            leading: Icon(Icons.alternate_email_outlined),
            title: Text('Recovery email/phone placeholder'),
          ),
          const ListTile(
            leading: Icon(Icons.warning_amber_outlined),
            title: Text('Suspicious login alert placeholder'),
          ),
          const ListTile(
            leading: Icon(Icons.devices_outlined),
            title: Text('Trusted device placeholder'),
          ),
          const ListTile(
            leading: Icon(Icons.security_outlined),
            title: Text('Security alerts'),
          ),
        ],
      ),
    );
  }
}
