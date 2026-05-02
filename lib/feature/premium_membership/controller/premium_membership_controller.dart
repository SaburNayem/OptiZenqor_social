import 'package:flutter/foundation.dart';

import '../repository/premium_membership_repository.dart';
import '../model/premium_plan_model.dart';

class PremiumMembershipController extends ChangeNotifier {
  PremiumMembershipController({PremiumMembershipRepository? repository})
    : _repository = repository ?? PremiumMembershipRepository();

  final PremiumMembershipRepository _repository;

  bool isLoading = true;
  bool isSubmitting = false;
  String? errorMessage;
  String? activePlanId;
  List<PremiumPlanModel> plans = const <PremiumPlanModel>[];

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      plans = await _repository.loadPlans();
      activePlanId = await _repository.loadActivePlanId();
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      plans = const <PremiumPlanModel>[];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> choosePlan(String planId) async {
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _repository.changePlan(planId);
      activePlanId = planId;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  bool isSelected(PremiumPlanModel plan) => activePlanId == plan.id;

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
