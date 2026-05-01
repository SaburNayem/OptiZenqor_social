import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/common_widget/app_loader.dart';
import '../controller/settings_state_controller.dart';
import '../model/settings_keys.dart';
import '../widget/settings_tiles.dart';

class PasswordSecurityScreen extends StatelessWidget {
  const PasswordSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsStateController, SettingsState>(
      builder: (context, state) {
        final controller = context.read<SettingsStateController>();
        if (!state.loaded) {
          return Scaffold(
            appBar: AppBar(title: Text('Password & Security')),
            body: Center(child: AppLoader()),
          );
        }
        final twoFactorEnabled = state.getBool(
          SettingsKeys.twoFactor,
          fallback: false,
        );
        return Scaffold(
          appBar: AppBar(title: const Text('Password & Security')),
          body: ListView(
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
                    controller.setBool(SettingsKeys.twoFactor, value),
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
          ),
        );
      },
    );
  }
}
