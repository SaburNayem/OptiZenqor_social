import 'package:flutter/material.dart';

class CreatorMetricModel {
  const CreatorMetricModel({
    required this.label,
    required this.value,
    required this.delta,
    required this.icon,
    required this.highlightColor,
  });

  final String label;
  final String value;
  final String delta;
  final IconData icon;
  final Color highlightColor;
}

class CreatorContentInsight {
  const CreatorContentInsight({
    required this.title,
    required this.type,
    required this.summary,
    required this.reach,
    required this.engagementRate,
  });

  final String title;
  final String type;
  final String summary;
  final String reach;
  final String engagementRate;
}

class CreatorAudienceInsight {
  const CreatorAudienceInsight({
    required this.label,
    required this.value,
    required this.details,
  });

  final String label;
  final String value;
  final String details;
}

class CreatorActionItem {
  const CreatorActionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}
