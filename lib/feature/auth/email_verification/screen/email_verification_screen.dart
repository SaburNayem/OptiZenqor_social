import 'package:flutter/material.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../app_route/route_names.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key, this.email});

  final String? email;

  @override
  Widget build(BuildContext context) {
    final String displayEmail =
        (email?.trim().isNotEmpty ?? false) ? email!.trim() : 'your email';

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.hexFF868E96),
          onPressed: () => AppGet.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Container(
                height: 72,
                width: 72,
                decoration: BoxDecoration(
                  color: AppColors.splashBackground.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.mark_email_read_outlined,
                  size: 34,
                  color: AppColors.splashBackground,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Verify Your Email',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.hexFF101828,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'We sent a verification link to $displayEmail. Open your inbox and tap the link to activate your account.',
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: AppColors.hexFF667085,
                ),
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.hexFFF9FAFB,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.hexFFEAECF0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _EmailTipRow(
                      icon: Icons.check_circle_outline,
                      text: 'Check your inbox and spam folder.',
                    ),
                    SizedBox(height: 14),
                    _EmailTipRow(
                      icon: Icons.link_outlined,
                      text: 'Tap the verification link from the email.',
                    ),
                    SizedBox(height: 14),
                    _EmailTipRow(
                      icon: Icons.refresh_outlined,
                      text: 'Resend the email if it does not arrive in a few minutes.',
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => AppGet.offAllNamed(RouteNames.shell),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.splashBackground,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'I Verified My Email',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    AppGet.snackbar(
                      'Verification Email Sent',
                      'A new verification link was sent to $displayEmail.',
                      snackPosition: SnackPosition.bottom,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    side: const BorderSide(color: AppColors.hexFFEAECF0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Resend Email',
                    style: TextStyle(
                      color: AppColors.hexFF344054,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => AppGet.back(),
                  child: const Text(
                    'Use a different email',
                    style: TextStyle(
                      color: AppColors.splashBackground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmailTipRow extends StatelessWidget {
  const _EmailTipRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.splashBackground),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.hexFF475467,
            ),
          ),
        ),
      ],
    );
  }
}

