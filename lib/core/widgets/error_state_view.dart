import 'package:flutter/material.dart';

import 'app_button.dart';

class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    required this.message,
    super.key,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Retry',
              onPressed: onRetry,
              expanded: false,
            ),
          ],
        ),
      ),
    );
  }
}
