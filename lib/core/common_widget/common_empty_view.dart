import 'package:flutter/material.dart';

import '../widgets/empty_state_view.dart';

class CommonEmptyView extends StatelessWidget {
  const CommonEmptyView({
    required this.title,
    required this.message,
    super.key,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return EmptyStateView(
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}
