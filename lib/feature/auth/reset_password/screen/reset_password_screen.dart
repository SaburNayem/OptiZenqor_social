import 'package:flutter/material.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../route/route_names.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const AppTextField(hint: 'OTP code', prefixIcon: Icons.pin_outlined),
          const SizedBox(height: 12),
          const AppTextField(
            hint: 'New password',
            obscureText: true,
            prefixIcon: Icons.lock_outline,
          ),
          const SizedBox(height: 20),
          AppButton(
            label: 'Update Password',
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
              RouteNames.login,
              (route) => false,
            ),
          ),
        ],
      ),
    );
  }
}
