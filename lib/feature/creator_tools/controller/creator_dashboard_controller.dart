import 'package:flutter/material.dart';

import '../../../core/enums/view_state.dart';
import '../model/creator_metric_model.dart';
import '../repository/creator_dashboard_repository.dart';

class CreatorDashboardController extends ChangeNotifier {
  CreatorDashboardController({CreatorDashboardRepository? repository})
    : _repository = repository ?? CreatorDashboardRepository();

  final CreatorDashboardRepository _repository;

  ViewState viewState = ViewState.idle;
  String errorMessage = '';
  CreatorDashboardPayload? payload;

  Future<void> load() async {
    viewState = ViewState.loading;
    errorMessage = '';
    notifyListeners();

    try {
      final CreatorDashboardPayload nextPayload = await _repository.load();
      payload = nextPayload;
      viewState =
          nextPayload.metrics.isEmpty &&
              nextPayload.totals.every((item) => item.value == '0')
          ? ViewState.empty
          : ViewState.success;
    } catch (error) {
      errorMessage = error.toString();
      viewState = ViewState.error;
    }

    notifyListeners();
  }
}
