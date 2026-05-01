import 'package:flutter/material.dart';

import '../../../core/common_widget/app_button.dart';
import '../controller/onboarding_controller.dart';
import '../model/onboarding_slide_model.dart';

class OnboardingScreen extends StatelessWidget {
  OnboardingScreen({super.key});

  final OnboardingController _controller = OnboardingController();
  final ValueNotifier<int> _index = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<OnboardingSlideModel>>(
          future: _controller.loadSlides(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Unable to load onboarding right now.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            }

            final List<OnboardingSlideModel> slides =
                snapshot.data ?? const <OnboardingSlideModel>[];
            if (slides.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Onboarding content is not available yet.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return Padding(
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
                      itemCount: slides.length,
                      itemBuilder: (_, index) {
                        final slide = slides[index];
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
                          slides.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: activeIndex == index ? 26 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: activeIndex == index
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                      context,
                                    ).colorScheme.outlineVariant,
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
                      final bool isLast = activeIndex == slides.length - 1;
                      return AppButton(
                        label: isLast ? 'Get Started' : 'Continue',
                        onPressed: () async {
                          await _controller.next(
                            context,
                            () {},
                            isLast: isLast,
                          );
                          if (!isLast) {
                            _index.value = activeIndex + 1;
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
