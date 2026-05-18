import 'package:flutter/material.dart';

import 'app_button.dart';

class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    required this.message,
    super.key,
    this.onRetry,
    this.onRefresh,
  });

  final String message;
  final VoidCallback? onRetry;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final Widget content = Center(
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
            AppButton(label: 'Retry', onPressed: onRetry, expanded: false),
          ],
        ),
      ),
    );
    final Future<void> Function()? refresh = onRefresh;
    if (refresh == null) {
      return content;
    }
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return RefreshIndicator(
          onRefresh: refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: <Widget>[
              SizedBox(
                height: constraints.maxHeight.isFinite
                    ? constraints.maxHeight
                    : MediaQuery.of(context).size.height * 0.7,
                child: content,
              ),
            ],
          ),
        );
      },
    );
  }
}
