import 'package:flutter/material.dart';

class VerificationSubmissionCompleteScreen extends StatelessWidget {
  const VerificationSubmissionCompleteScreen({
    super.key,
    required this.returnRouteName,
    required this.targetLabel,
  });

  final String returnRouteName;
  final String targetLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.verified_user_rounded,
                size: 88,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 18),
              Text(
                'Submission complete',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Your verification request was submitted successfully. We will review your ID details and update your account status.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => _goBack(context),
                child: Text('Go back to $targetLabel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goBack(BuildContext context) {
    Navigator.of(context).popUntil(
      (route) => route.settings.name == returnRouteName || route.isFirst,
    );
  }
}
