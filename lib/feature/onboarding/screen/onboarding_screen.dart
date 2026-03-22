import 'package:flutter/material.dart';

import '../../../core/widgets/app_button.dart';
import '../../onboarding/controller/onboarding_controller.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final OnboardingController _controller = OnboardingController();

  final List<({String title, String subtitle, IconData icon})> _slides = [
    (
      title: 'Create your social identity',
      subtitle: 'One profile, multiple roles, premium social tools.',
      icon: Icons.person_pin_circle_rounded,
    ),
    (
      title: 'Discover what matters faster',
      subtitle: 'Reels, communities, market, jobs, and curated feed.',
      icon: Icons.travel_explore_rounded,
    ),
    (
      title: 'Scale with creator and business tools',
      subtitle: 'Insights, campaigns, subscriptions, and growth modules.',
      icon: Icons.insights_rounded,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _controller.skip(context),
                  child: const Text('Skip'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller.pageController,
                  onPageChanged: (value) => setState(
                    () => _controller.onPageChanged(value, () {}),
                  ),
                  itemCount: _slides.length,
                  itemBuilder: (_, index) {
                    final slide = _slides[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 64,
                          child: Icon(slide.icon, size: 52),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          slide.subtitle,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _controller.index == index ? 26 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _controller.index == index
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AppButton(
                label: _controller.isLast ? 'Get Started' : 'Continue',
                onPressed: () => setState(
                  () => _controller.next(context, () {}),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
