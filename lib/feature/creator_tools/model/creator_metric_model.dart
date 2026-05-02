import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

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

  factory CreatorMetricModel.fromApiJson(Map<String, dynamic> json) {
    final String label = (json['label'] ?? '').toString().trim();
    return CreatorMetricModel(
      label: label,
      value: (json['value'] ?? '').toString(),
      delta: (json['delta'] ?? '').toString(),
      icon: _iconForLabel(label),
      highlightColor: _colorForLabel(label),
    );
  }

  static IconData _iconForLabel(String label) {
    final String normalized = label.toLowerCase();
    if (normalized.contains('post')) {
      return Icons.grid_view_rounded;
    }
    if (normalized.contains('reel') || normalized.contains('video')) {
      return Icons.play_circle_fill_rounded;
    }
    if (normalized.contains('story')) {
      return Icons.auto_stories_rounded;
    }
    if (normalized.contains('follow')) {
      return Icons.trending_up_rounded;
    }
    return Icons.insights_rounded;
  }

  static Color _colorForLabel(String label) {
    final String normalized = label.toLowerCase();
    if (normalized.contains('post')) {
      return AppColors.hexFF4C7CF0;
    }
    if (normalized.contains('reel') || normalized.contains('video')) {
      return AppColors.hexFFE55B5B;
    }
    if (normalized.contains('story')) {
      return AppColors.hexFFF29B38;
    }
    return AppColors.hexFF2D9D78;
  }
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

class CreatorSummaryItem {
  const CreatorSummaryItem({required this.label, required this.value});

  final String label;
  final String value;
}

class CreatorDashboardPayload {
  const CreatorDashboardPayload({
    required this.creatorName,
    required this.creatorUsername,
    required this.creatorRole,
    required this.metrics,
    required this.totals,
    required this.detailItems,
  });

  final String creatorName;
  final String creatorUsername;
  final String creatorRole;
  final List<CreatorMetricModel> metrics;
  final List<CreatorSummaryItem> totals;
  final List<CreatorSummaryItem> detailItems;
}
