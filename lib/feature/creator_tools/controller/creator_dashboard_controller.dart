import 'package:flutter/material.dart';

import '../model/creator_metric_model.dart';
import '../../../core/constants/app_colors.dart';

class CreatorDashboardController extends ChangeNotifier {
  final List<CreatorMetricModel> metrics = const [
    CreatorMetricModel(
      label: 'Total reach',
      value: '124K',
      delta: '+18.4% this month',
      icon: Icons.groups_rounded,
      highlightColor: AppColors.hexFF4C7CF0,
    ),
    CreatorMetricModel(
      label: 'Engagement rate',
      value: '8.2%',
      delta: '+1.1 pts vs last month',
      icon: Icons.favorite_rounded,
      highlightColor: AppColors.hexFFE55B5B,
    ),
    CreatorMetricModel(
      label: 'Followers growth',
      value: '+1.4K',
      delta: '320 from reels this week',
      icon: Icons.trending_up_rounded,
      highlightColor: AppColors.hexFF2D9D78,
    ),
    CreatorMetricModel(
      label: 'Estimated earnings',
      value: '\$2,430',
      delta: '3 brand deals pending',
      icon: Icons.payments_rounded,
      highlightColor: AppColors.hexFFF29B38,
    ),
  ];

  final List<CreatorContentInsight> topPerformingContent = const [
    CreatorContentInsight(
      title: 'Morning productivity reel',
      type: 'Reel',
      summary: 'Best completion rate and strongest save count this week.',
      reach: '42K reach',
      engagementRate: '11.3% engagement',
    ),
    CreatorContentInsight(
      title: 'Desk setup carousel',
      type: 'Carousel',
      summary: 'High shares from non-followers and strong profile visits.',
      reach: '28K reach',
      engagementRate: '9.4% engagement',
    ),
    CreatorContentInsight(
      title: 'Creator Q&A livestream',
      type: 'Live',
      summary: 'Longest watch time and strongest comment quality.',
      reach: '9.8K viewers',
      engagementRate: '16.1% engagement',
    ),
  ];

  final List<CreatorAudienceInsight> audienceInsights = const [
    CreatorAudienceInsight(
      label: 'Top age group',
      value: '25-34',
      details: '46% of engaged audience',
    ),
    CreatorAudienceInsight(
      label: 'Top cities',
      value: 'Dhaka, Chattogram, Sylhet',
      details: 'Most conversions from Dhaka',
    ),
    CreatorAudienceInsight(
      label: 'Most active time',
      value: '8:00 PM - 10:00 PM',
      details: 'Peak saves happen on Sunday evenings',
    ),
    CreatorAudienceInsight(
      label: 'Audience mix',
      value: '63% returning viewers',
      details: 'New viewers rose 12% after collaborations',
    ),
  ];

  final List<CreatorActionItem> actionItems = const [
    CreatorActionItem(
      title: 'Review collaboration inbox',
      subtitle: '5 unread brand and partnership requests need replies.',
      icon: Icons.mail_outline_rounded,
    ),
    CreatorActionItem(
      title: 'Schedule next week content',
      subtitle: '3 draft posts are ready for publishing windows.',
      icon: Icons.event_note_rounded,
    ),
    CreatorActionItem(
      title: 'Refresh media kit',
      subtitle: 'Engagement stats changed enough to update your pitch deck.',
      icon: Icons.description_outlined,
    ),
  ];

  final List<String> libraryTools = const [
    'All media library',
    'Reusable drafts',
    'Saved templates',
    'Scheduled content calendar',
    'Bulk content management',
    'Collaborative boards',
    'Invite collaborator',
    'Partnership requests',
    'Campaign invites',
    'Collaboration inbox',
    'Reminder system',
    'Task manager',
  ];
}

