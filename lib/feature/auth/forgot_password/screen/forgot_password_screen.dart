import 'package:flutter/material.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../route/route_names.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('We will send an OTP and reset link to your email.'),
          const SizedBox(height: 16),
          const AppTextField(
            hint: 'Account email',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.alternate_email,
          ),
          const SizedBox(height: 20),
          AppButton(
            label: 'Continue',
            onPressed: () => Navigator.of(context).pushNamed(RouteNames.resetPassword),
          ),
        ],
      ),
    );
  }
}
