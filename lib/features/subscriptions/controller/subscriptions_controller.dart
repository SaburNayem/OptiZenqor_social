import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/subscription_plan_model.dart';
import '../repository/subscriptions_repository.dart';

class SubscriptionsState {
  const SubscriptionsState({
    this.plans = const <SubscriptionPlanModel>[],
    this.activePlanId,
    this.isLoading = true,
  });

  final List<SubscriptionPlanModel> plans;
  final String? activePlanId;
  final bool isLoading;

  SubscriptionsState copyWith({
    List<SubscriptionPlanModel>? plans,
    String? activePlanId,
    bool? isLoading,
  }) {
    return SubscriptionsState(
      plans: plans ?? this.plans,
      activePlanId: activePlanId ?? this.activePlanId,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SubscriptionsController extends Cubit<SubscriptionsState> {
  SubscriptionsController({SubscriptionsRepository? repository})
    : _repository = repository ?? SubscriptionsRepository(),
      super(const SubscriptionsState());

  final SubscriptionsRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    final plans = await _repository.plans();
    final activePlanId =
        await _repository.activePlanId() ??
        (plans.isNotEmpty ? plans.first.id : null);
    emit(
      state.copyWith(
        plans: plans,
        activePlanId: activePlanId,
        isLoading: false,
      ),
    );
  }

  Future<void> upgradeOrDowngrade(String planId) async {
    await _repository.saveActivePlanId(planId);
    emit(state.copyWith(activePlanId: planId));
  }
}
