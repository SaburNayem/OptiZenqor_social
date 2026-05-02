import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/push_category_model.dart';
import '../service/push_notification_preferences_service.dart';

class PushNotificationPreferencesController extends ChangeNotifier {
  PushNotificationPreferencesController({
    PushNotificationPreferencesService? service,
  }) : _service = service ?? PushNotificationPreferencesService() {
    unawaited(load());
  }

  final PushNotificationPreferencesService _service;

  List<PushCategoryModel> categories = const <PushCategoryModel>[];
  bool isLoading = true;
  bool isSaving = false;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final ServiceResponseModel<Map<String, dynamic>> response = await _service
          .getEndpoint('preferences');
      if (!response.isSuccess || response.data['success'] == false) {
        throw Exception(
          response.message ?? 'Unable to load push notification preferences.',
        );
      }

      categories = _readCategories(response.data);
    } catch (error) {
      categories = const <PushCategoryModel>[];
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggle(int index) async {
    if (isSaving || index < 0 || index >= categories.length) {
      return;
    }

    final List<PushCategoryModel> previous = categories;
    categories = categories
        .asMap()
        .entries
        .map((entry) {
          final PushCategoryModel item = entry.value;
          return entry.key == index
              ? PushCategoryModel(title: item.title, enabled: !item.enabled)
              : item;
        })
        .toList(growable: false);
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      final ServiceResponseModel<Map<String, dynamic>> response = await _service
          .patchEndpoint(
            'preferences',
            payload: <String, dynamic>{
              'categories': categories
                  .map(
                    (PushCategoryModel item) => <String, dynamic>{
                      'title': item.title,
                      'enabled': item.enabled,
                    },
                  )
                  .toList(growable: false),
            },
          );
      if (!response.isSuccess || response.data['success'] == false) {
        throw Exception(
          response.message ?? 'Unable to update push notification preferences.',
        );
      }
      categories = _readCategories(response.data);
    } catch (error) {
      categories = previous;
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  List<PushCategoryModel> _readCategories(Map<String, dynamic> response) {
    final Map<String, dynamic> payload =
        ApiPayloadReader.readMap(response['data']) ?? response;
    return ApiPayloadReader.readMapList(
          payload,
          preferredKeys: const <String>['categories', 'items'],
        )
        .map(
          (Map<String, dynamic> item) => PushCategoryModel(
            title: ApiPayloadReader.readString(item['title']),
            enabled: ApiPayloadReader.readBool(item['enabled']) ?? false,
          ),
        )
        .where((PushCategoryModel item) => item.title.isNotEmpty)
        .toList(growable: false);
  }
}
