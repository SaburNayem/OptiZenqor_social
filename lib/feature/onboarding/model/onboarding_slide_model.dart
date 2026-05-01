import 'package:flutter/material.dart';

class OnboardingSlideModel {
  const OnboardingSlideModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconKey,
  });

  final String id;
  final String title;
  final String subtitle;
  final String iconKey;

  IconData get icon {
    switch (iconKey) {
      case 'person_pin_circle_rounded':
        return Icons.person_pin_circle_rounded;
      case 'travel_explore_rounded':
        return Icons.travel_explore_rounded;
      case 'insights_rounded':
        return Icons.insights_rounded;
      case 'groups_rounded':
        return Icons.groups_rounded;
      case 'workspaces_rounded':
        return Icons.workspaces_rounded;
      default:
        return Icons.auto_awesome_rounded;
    }
  }

  factory OnboardingSlideModel.fromApiJson(Map<String, dynamic> json) {
    return OnboardingSlideModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      iconKey: (json['icon'] ?? '').toString(),
    );
  }
}
