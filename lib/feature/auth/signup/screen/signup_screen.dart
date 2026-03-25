import 'package:flutter/material.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          AppTextField(hint: 'Full name', prefixIcon: Icons.person_outline),
          SizedBox(height: 12),
          AppTextField(hint: 'Email', prefixIcon: Icons.mail_outline),
          SizedBox(height: 12),
          AppTextField(
            hint: 'Password',
            obscureText: true,
            prefixIcon: Icons.lock_outline,
          ),
          SizedBox(height: 12),
          AppTextField(
            hint: 'OTP (placeholder)',
            prefixIcon: Icons.pin_outlined,
          ),
          SizedBox(height: 20),
          AppButton(label: 'Sign Up', onPressed: null),
          SizedBox(height: 10),
          Text('Social login placeholders: Google, Apple, Meta'),
        ],
      ),
    );
  }
}
