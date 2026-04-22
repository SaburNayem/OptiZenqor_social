import 'package:flutter/material.dart';

import '../../../app_route/route_names.dart';

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
          const SizedBox(height: 16),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(label: Text('Daily usage time')),
                  Chip(label: Text('Take-a-break reminder')),
                  Chip(label: Text('Quiet mode')),
                  Chip(label: Text('Bedtime mode')),
                  Chip(label: Text('Content consumption summary')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

