import 'package:flutter/material.dart';

class OnboardingSlideModel {
  const OnboardingSlideModel({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}
