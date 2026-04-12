import 'package:flutter/material.dart';

import '../../../core/widgets/app_button.dart';
import '../controller/onboarding_controller.dart';
import '../model/onboarding_slide_model.dart';

class OnboardingScreen extends StatelessWidget {
  OnboardingScreen({super.key});

  final OnboardingController _controller = OnboardingController();
  final ValueNotifier<int> _index = ValueNotifier<int>(0);

  final List<OnboardingSlideModel> _slides = const [
    OnboardingSlideModel(
      title: 'Create your social identity',
      subtitle: 'One profile, multiple roles, premium social tools.',
      icon: Icons.person_pin_circle_rounded,
    ),
    OnboardingSlideModel(
      title: 'Discover what matters faster',
      subtitle: 'Reels, communities, market, jobs, and curated feed.',
      icon: Icons.travel_explore_rounded,
    ),
    OnboardingSlideModel(
      title: 'Scale with creator and business tools',
      subtitle: 'Insights, campaigns, subscriptions, and growth modules.',
      icon: Icons.insights_rounded,
    ),
  ];

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
                  onPageChanged: (value) {
                    _controller.index = value;
                    _index.value = value;
                  },
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
                        Text(slide.subtitle, textAlign: TextAlign.center),
                      ],
                    );
                  },
                ),
              ),
              ValueListenableBuilder<int>(
                valueListenable: _index,
                builder: (context, activeIndex, _) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: activeIndex == index ? 26 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: activeIndex == index
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder<int>(
                valueListenable: _index,
                builder: (context, activeIndex, _) {
                  final isLast = activeIndex == _slides.length - 1;
                  return AppButton(
                    label: isLast ? 'Get Started' : 'Continue',
                    onPressed: () async {
                      await _controller.next(context, () {});
                      if (!isLast) {
                        _index.value = activeIndex + 1;
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
