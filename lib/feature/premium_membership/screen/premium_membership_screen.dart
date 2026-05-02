import 'package:flutter/material.dart';

import '../../../core/common_widget/app_button.dart';
import '../../../core/common_widget/app_loader.dart';
import '../../../core/constants/app_colors.dart';
import '../controller/premium_membership_controller.dart';
import '../model/premium_plan_model.dart';

class PremiumMembershipScreen extends StatefulWidget {
  const PremiumMembershipScreen({super.key});

  @override
  State<PremiumMembershipScreen> createState() =>
      _PremiumMembershipScreenState();
}

class _PremiumMembershipScreenState extends State<PremiumMembershipScreen> {
  late final PremiumMembershipController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PremiumMembershipController()..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Premium Plans')),
          body: _buildBody(context),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_controller.isLoading) {
      return const Center(child: AppLoader());
    }

    if (_controller.errorMessage != null && _controller.plans.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_controller.errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              AppButton(label: 'Retry', onPressed: _controller.load),
            ],
          ),
        ),
      );
    }

    if (_controller.plans.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No premium plans are available right now.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _heroCard(context),
        const SizedBox(height: 18),
        _miniHighlights(context),
        const SizedBox(height: 22),
        Text(
          'Choose your plan',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        ..._controller.plans.map(
          (plan) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _planCard(context, plan),
          ),
        ),
        const SizedBox(height: 8),
        _backendSummaryCard(context),
        if (_controller.errorMessage != null) ...[
          const SizedBox(height: 16),
          Text(
            _controller.errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent),
          ),
        ],
      ],
    );
  }

  Widget _heroCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.hexFF1E2B5F, AppColors.hexFF4D63C8],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Live subscription plans',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Choose a backend-managed premium plan',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Plans, pricing, and current subscription state now come from the live backend instead of hardcoded client data.',
            style: TextStyle(color: AppColors.white70, height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _miniHighlights(BuildContext context) {
    final items = <(String, IconData)>[
      (
        '${_controller.plans.length} live plans',
        Icons.workspace_premium_rounded,
      ),
      (
        _controller.activePlanId == null
            ? 'No active plan'
            : 'Current plan detected',
        Icons.verified_rounded,
      ),
      ('Backend pricing', Icons.sync_alt_rounded),
    ];

    return Row(
      children: items
          .map(
            (item) => Expanded(
              child: Container(
                margin: EdgeInsets.only(right: item == items.last ? 0 : 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    Icon(item.$2),
                    const SizedBox(height: 8),
                    Text(
                      item.$1,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }

  Widget _planCard(BuildContext context, PremiumPlanModel plan) {
    final bool isSelected = _controller.isSelected(plan);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.hexFFF3F6FF
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isSelected
              ? AppColors.hexFF4D63C8
              : Theme.of(context).colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      plan.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: plan.isActive
                      ? AppColors.hexFF1E2B5F
                      : Theme.of(context).disabledColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  plan.isActive ? 'Active plan' : 'Inactive',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                plan.priceLabel,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(plan.billingLabel),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (plan.features.isEmpty)
            const Text('No backend feature list was provided for this plan.')
          else
            ...plan.features.map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.check_circle_rounded,
                        size: 18,
                        color: AppColors.hexFF2D9D78,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(feature)),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          if (isSelected)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.hexFF1E2B5F,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'Current backend subscription',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            AppButton(
              label: _controller.isSubmitting
                  ? 'Updating...'
                  : 'Choose ${plan.name}',
              onPressed: _controller.isSubmitting || !plan.isActive
                  ? null
                  : () async {
                      final ScaffoldMessengerState messenger =
                          ScaffoldMessenger.of(context);
                      await _controller.choosePlan(plan.id);
                      if (!mounted) {
                        return;
                      }
                      final String? message = _controller.errorMessage;
                      messenger
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(
                              message ?? '${plan.name} selected successfully.',
                            ),
                          ),
                        );
                      if (message == null) {
                        _controller.clearError();
                      }
                    },
            ),
        ],
      ),
    );
  }

  Widget _backendSummaryCard(BuildContext context) {
    final List<(String, String)> rows = <(String, String)>[
      ('Plan source', 'Backend API'),
      ('Available plans', _controller.plans.length.toString()),
      (
        'Current plan id',
        _controller.activePlanId == null || _controller.activePlanId!.isEmpty
            ? 'None'
            : _controller.activePlanId!,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Live subscription summary',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(flex: 4, child: Text(row.$1)),
                  Expanded(
                    flex: 3,
                    child: Text(
                      row.$2,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
