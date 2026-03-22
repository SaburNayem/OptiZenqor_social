import 'package:flutter/material.dart';

import '../controller/personalization_onboarding_controller.dart';

class PersonalizationOnboardingScreen extends StatefulWidget {
  const PersonalizationOnboardingScreen({super.key});

  @override
  State<PersonalizationOnboardingScreen> createState() =>
      _PersonalizationOnboardingScreenState();
}

class _PersonalizationOnboardingScreenState
    extends State<PersonalizationOnboardingScreen> {
  final PersonalizationOnboardingController _controller =
      PersonalizationOnboardingController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Personalize Experience')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Pick interests to improve recommendations.'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _controller.interests
                    .map(
                      (item) => FilterChip(
                        label: Text(item.name),
                        selected: item.selected,
                        onSelected: (_) => _controller.toggle(item.name),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {},
                child: const Text('Continue'),
              ),
            ],
          ),
        );
      },
    );
  }
}
