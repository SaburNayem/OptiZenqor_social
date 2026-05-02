import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/offline_action_model.dart';
import '../service/offline_sync_service.dart';

class OfflineSyncController extends ChangeNotifier {
  OfflineSyncController({OfflineSyncService? service})
    : _service = service ?? OfflineSyncService() {
    unawaited(load());
  }

  final OfflineSyncService _service;

  bool isOffline = false;
  bool isLoading = true;
  String? errorMessage;
  List<OfflineActionModel> queue = const <OfflineActionModel>[];

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final ServiceResponseModel<Map<String, dynamic>> response = await _service
          .getEndpoint('offline_sync');
      if (!response.isSuccess || response.data['success'] == false) {
        throw Exception(
          response.message ?? 'Unable to load offline sync state.',
        );
      }
      final Map<String, dynamic> payload =
          ApiPayloadReader.readMap(response.data['data']) ?? response.data;
      isOffline = ApiPayloadReader.readBool(payload['isOffline']) ?? false;
      queue =
          ApiPayloadReader.readMapList(
                payload,
                preferredKeys: const <String>['queue', 'items'],
              )
              .map((item) {
                return OfflineActionModel(
                  title: ApiPayloadReader.readString(
                    item['title'],
                    fallback: 'Queued action',
                  ),
                  pending: ApiPayloadReader.readBool(item['pending']) ?? false,
                );
              })
              .toList(growable: false);
    } catch (error) {
      errorMessage = error.toString();
      queue = const <OfflineActionModel>[];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markOnlineAndSync() async {
    errorMessage = null;
    notifyListeners();
    try {
      final ServiceResponseModel<Map<String, dynamic>> response = await _service
          .postEndpoint('retry');
      if (!response.isSuccess || response.data['success'] == false) {
        throw Exception(response.message ?? 'Unable to retry offline sync.');
      }
      await load();
    } catch (error) {
      errorMessage = error.toString();
      notifyListeners();
    }
  }
}
