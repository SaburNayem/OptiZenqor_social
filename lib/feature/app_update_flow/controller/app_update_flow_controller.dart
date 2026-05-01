import 'dart:async';

import 'package:flutter/foundation.dart';

import '../model/app_update_model.dart';
import '../service/app_update_flow_service.dart';
import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service_model/service_response_model.dart';

class AppUpdateFlowController extends ChangeNotifier {
  AppUpdateFlowController({AppUpdateFlowService? service})
    : _service = service ?? AppUpdateFlowService() {
    unawaited(load());
  }

  final AppUpdateFlowService _service;
  AppUpdateModel update = const AppUpdateModel(
    type: UpdateType.optional,
    message: 'Version 2.1 has performance improvements and chat upgrades.',
  );

  bool isUpdating = false;

  Future<void> load() async {
    for (final String key in <String>[
      'app_update_flow',
      'config',
      'bootstrap',
    ]) {
      try {
        final ServiceResponseModel<Map<String, dynamic>> response =
            await _service.getEndpoint(key);
        if (!response.isSuccess || response.data['success'] == false) {
          continue;
        }
        final Map<String, dynamic> data =
            ApiPayloadReader.readMap(response.data['data']) ?? response.data;
        if (data.containsKey('type') ||
            data.containsKey('status') ||
            data.containsKey('message')) {
          update = AppUpdateModel.fromApiJson(data);
          notifyListeners();
          return;
        }
      } catch (_) {}
    }
  }

  Future<void> startUpdate() async {
    isUpdating = true;
    notifyListeners();
    try {
      await _service.postEndpoint('start');
    } catch (_) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
    }
    isUpdating = false;
    notifyListeners();
  }
}
