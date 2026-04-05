import 'package:flutter/material.dart';

import '../widgets/error_state_view.dart';

class CommonErrorView extends StatelessWidget {
  const CommonErrorView({required this.message, super.key, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return ErrorStateView(message: message, onRetry: onRetry);
  }
}
