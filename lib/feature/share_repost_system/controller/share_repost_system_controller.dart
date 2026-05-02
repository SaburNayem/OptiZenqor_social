import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../service/share_repost_system_service.dart';

class ShareRepostSystemController extends ChangeNotifier {
  ShareRepostSystemController({ShareRepostSystemService? service})
    : _service = service ?? ShareRepostSystemService() {
    unawaited(load());
  }

  final ShareRepostSystemService _service;

  List<String> options = const <String>[];
  bool isLoading = true;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final ServiceResponseModel<Map<String, dynamic>> response = await _service
          .getEndpoint('options');
      if (!response.isSuccess || response.data['success'] == false) {
        throw Exception(
          response.message ?? 'Unable to load share and repost options.',
        );
      }
      final Map<String, dynamic> payload =
          ApiPayloadReader.readMap(response.data['data']) ?? response.data;
      options =
          ApiPayloadReader.readMapList(
                payload,
                preferredKeys: const <String>['items', 'options'],
              )
              .map((item) {
                return ApiPayloadReader.readString(item['title']);
              })
              .where((item) => item.isNotEmpty)
              .toList(growable: false);
    } catch (error) {
      errorMessage = error.toString();
      options = const <String>[];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
