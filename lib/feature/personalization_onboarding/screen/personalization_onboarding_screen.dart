import 'package:flutter/material.dart';

import '../../../app_route/route_names.dart';
import '../controller/personalization_onboarding_controller.dart';

class PersonalizationOnboardingScreen extends StatelessWidget {
  PersonalizationOnboardingScreen({super.key});

  final PersonalizationOnboardingController _controller =
      PersonalizationOnboardingController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Personalize Experience')),
          body: _controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text('Pick interests to improve recommendations.'),
                    if (_controller.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(_controller.errorMessage!),
                    ],
                    const SizedBox(height: 12),
                    if (_controller.interests.isEmpty)
                      const ListTile(
                        leading: Icon(Icons.interests_outlined),
                        title: Text('No interests are available right now.'),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _controller.interests
                            .map(
                              (item) => FilterChip(
                                label: Text(item.name),
                                selected: item.selected,
                                onSelected: (_) =>
                                    _controller.toggle(item.name),
                              ),
                            )
                            .toList(),
                      ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _controller.canContinue
                          ? () {
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Saved ${_controller.selectedCount} interests',
                                    ),
                                  ),
                                );
                              Navigator.of(
                                context,
                              ).pushReplacementNamed(RouteNames.shell);
                            }
                          : null,
                      child: const Text('Continue'),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
