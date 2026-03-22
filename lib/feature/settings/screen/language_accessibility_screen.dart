import 'package:flutter/material.dart';

import '../../../route/route_names.dart';

class LanguageAccessibilityScreen extends StatelessWidget {
  const LanguageAccessibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Language & Accessibility')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FilledButton(
            onPressed: () => Navigator.of(context).pushNamed(RouteNames.localizationSupport),
            child: const Text('Open Localization Settings'),
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: () => Navigator.of(context).pushNamed(RouteNames.accessibilitySupport),
            child: const Text('Open Accessibility Settings'),
          ),
        ],
      ),
    );
  }
}
