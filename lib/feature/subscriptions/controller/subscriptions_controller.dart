import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/subscription_plan_model.dart';
import '../repository/subscriptions_repository.dart';

class SubscriptionsState {
  const SubscriptionsState({
    this.plans = const <SubscriptionPlanModel>[],
    this.activePlanId,
    this.isLoading = true,
    this.isCancelled = false,
    this.errorMessage,
  });

  final List<SubscriptionPlanModel> plans;
  final String? activePlanId;
  final bool isLoading;
  final bool isCancelled;
  final String? errorMessage;

  SubscriptionsState copyWith({
    List<SubscriptionPlanModel>? plans,
    String? activePlanId,
    bool? isLoading,
    bool? isCancelled,
    String? errorMessage,
  }) {
    return SubscriptionsState(
      plans: plans ?? this.plans,
      activePlanId: activePlanId ?? this.activePlanId,
      isLoading: isLoading ?? this.isLoading,
      isCancelled: isCancelled ?? this.isCancelled,
      errorMessage: errorMessage,
    );
  }
}

class SubscriptionsController extends Cubit<SubscriptionsState> {
  SubscriptionsController({SubscriptionsRepository? repository})
    : _repository = repository ?? SubscriptionsRepository(),
      super(const SubscriptionsState());

  final SubscriptionsRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final plans = await _repository.plans();
      final activePlanId =
          await _repository.activePlanId() ??
          (plans.isNotEmpty ? plans.first.id : null);
      emit(
        state.copyWith(
          plans: plans,
          activePlanId: activePlanId,
          isLoading: false,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          plans: const <SubscriptionPlanModel>[],
          isLoading: false,
          errorMessage: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> upgradeOrDowngrade(String planId) async {
    await _repository.saveActivePlanId(planId);
    emit(
      state.copyWith(
        activePlanId: planId,
        isCancelled: false,
        errorMessage: null,
      ),
    );
  }

  Future<void> cancel() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _repository.cancelSubscription();
      emit(state.copyWith(isLoading: false, isCancelled: true));
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> renew() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _repository.renewSubscription();
      emit(state.copyWith(isLoading: false, isCancelled: false));
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
