import 'package:flutter/material.dart';

import '../../../core/widgets/app_loader.dart';
import '../controller/settings_state_controller.dart';
import '../model/settings_keys.dart';
import '../widget/settings_tiles.dart';

class PasswordSecurityScreen extends StatefulWidget {
  const PasswordSecurityScreen({super.key});

  @override
  State<PasswordSecurityScreen> createState() => _PasswordSecurityScreenState();
}

class _PasswordSecurityScreenState extends State<PasswordSecurityScreen> {
  final SettingsStateController _controller = SettingsStateController();

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Password & Security')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (!_controller.loaded) {
            return const Center(child: AppLoader());
          }
          final twoFactorEnabled =
              _controller.getBool(SettingsKeys.twoFactor, fallback: false);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SettingsNavigationTile(
                title: 'Change password',
                subtitle: 'Update your sign-in password',
                icon: Icons.lock_outline,
              ),
              SettingsSwitchTile(
                title: 'Two-factor authentication',
                subtitle: twoFactorEnabled
                    ? '2FA enabled'
                    : 'Add an extra layer of security',
                icon: Icons.verified_user_outlined,
                value: twoFactorEnabled,
                onChanged: (value) =>
                    _controller.setBool(SettingsKeys.twoFactor, value),
              ),
              const SettingsNavigationTile(
                title: 'Authenticator app',
                subtitle: 'Set up an OTP app for login',
                icon: Icons.qr_code_2_outlined,
              ),
              const SettingsNavigationTile(
                title: 'Backup codes',
                subtitle: 'Generate emergency login codes',
                icon: Icons.password_outlined,
              ),
              const SettingsNavigationTile(
                title: 'Recovery options',
                subtitle: 'Update recovery email and phone',
                icon: Icons.restore_outlined,
              ),
              const SettingsNavigationTile(
                title: 'Suspicious login alerts',
                subtitle: 'Get notified about unusual activity',
                icon: Icons.warning_amber_outlined,
              ),
              const SettingsNavigationTile(
                title: 'Trusted devices',
                subtitle: 'Manage remembered devices',
                icon: Icons.devices_outlined,
              ),
            ],
          );
        },
      ),
    );
  }
}
