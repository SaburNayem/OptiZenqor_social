import 'package:flutter/material.dart';

import 'app_button.dart';

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    required this.title,
    required this.message,
    super.key,
    this.actionLabel,
    this.onAction,
    this.onRefresh,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final Widget content = Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_rounded, size: 48),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                expanded: false,
              ),
            ],
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
