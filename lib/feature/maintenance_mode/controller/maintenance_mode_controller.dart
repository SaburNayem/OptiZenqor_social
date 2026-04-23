import 'dart:async';

import 'package:flutter/foundation.dart';

import '../model/maintenance_mode_model.dart';
import '../service/maintenance_mode_service.dart';
import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service_model/service_response_model.dart';

class MaintenanceModeController extends ChangeNotifier {
  MaintenanceModeController({MaintenanceModeService? service})
    : _service = service ?? MaintenanceModeService() {
    unawaited(load());
  }

  final MaintenanceModeService _service;
  MaintenanceModeModel state = const MaintenanceModeModel(
    title: 'Scheduled Maintenance',
    message: 'We are improving your experience. Please retry shortly.',
    isActive: false,
  );

  bool isRetrying = false;

  Future<void> load() async {
    for (final String key in <String>['maintenance_mode', 'app_config']) {
      try {
        final ServiceResponseModel<Map<String, dynamic>> response =
            await _service.getEndpoint(key);
        if (!response.isSuccess || response.data['success'] == false) {
          continue;
        }
        final Map<String, dynamic> data =
            ApiPayloadReader.readMap(response.data['data']) ?? response.data;
        if (data.containsKey('isActive') ||
            data.containsKey('active') ||
            data.containsKey('message')) {
          state = MaintenanceModeModel.fromApiJson(data);
          notifyListeners();
          return;
        }
      } catch (_) {}
    }
  }

  Future<void> retry() async {
    isRetrying = true;
    notifyListeners();
    try {
      await _service.postEndpoint('retry');
      await load();
    } catch (_) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    isRetrying = false;
    notifyListeners();
  }
}
