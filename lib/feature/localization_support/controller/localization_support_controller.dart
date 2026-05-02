import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/localization_option_model.dart';
import '../service/localization_support_service.dart';

class LocalizationSupportController extends ChangeNotifier {
  LocalizationSupportController({LocalizationSupportService? service})
    : _service = service ?? LocalizationSupportService() {
    unawaited(load());
  }

  final LocalizationSupportService _service;

  List<LocalizationOptionModel> locales = const <LocalizationOptionModel>[];
  bool isLoading = true;
  String? errorMessage;
  String selected = 'en';

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final ServiceResponseModel<Map<String, dynamic>> response = await _service
          .getEndpoint('localization_support');
      if (!response.isSuccess || response.data['success'] == false) {
        throw Exception(
          response.message ?? 'Unable to load localization support.',
        );
      }
      final Map<String, dynamic> payload =
          ApiPayloadReader.readMap(response.data['data']) ?? response.data;
      locales =
          ApiPayloadReader.readMapList(
                payload,
                preferredKeys: const <String>['locales', 'items'],
              )
              .map((item) {
                return LocalizationOptionModel(
                  localeCode: ApiPayloadReader.readString(item['localeCode']),
                  label: ApiPayloadReader.readString(
                    item['label'],
                    fallback: item['localeCode']?.toString() ?? '',
                  ),
                );
              })
              .where((item) => item.localeCode.isNotEmpty)
              .toList(growable: false);
      if (locales.isEmpty) {
        throw StateError('Localization response did not include any locales.');
      }
      selected = ApiPayloadReader.readString(
        payload['selected'],
        fallback: payload['fallbackLocale']?.toString() ?? 'en',
      );
    } catch (error) {
      errorMessage = error.toString();
      locales = const <LocalizationOptionModel>[];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setLocale(String code) async {
    final String previous = selected;
    selected = code;
    errorMessage = null;
    notifyListeners();
    try {
      final ServiceResponseModel<Map<String, dynamic>> response = await _service
          .patchEndpoint(
            'localization_support',
            payload: <String, dynamic>{'localeCode': code},
          );
      if (!response.isSuccess || response.data['success'] == false) {
        throw Exception(response.message ?? 'Unable to update locale.');
      }
      final Map<String, dynamic> payload =
          ApiPayloadReader.readMap(response.data['data']) ?? response.data;
      selected = ApiPayloadReader.readString(
        payload['selected'],
        fallback: code,
      );
    } catch (error) {
      selected = previous;
      errorMessage = error.toString();
    } finally {
      notifyListeners();
    }
  }
}
