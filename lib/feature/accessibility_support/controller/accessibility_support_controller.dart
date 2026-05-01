import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/data/api/api_payload_reader.dart';
import '../model/accessibility_option_model.dart';
import '../service/accessibility_support_service.dart';

class AccessibilitySupportController extends ChangeNotifier {
  AccessibilitySupportController({AccessibilitySupportService? service})
    : _service = service ?? AccessibilitySupportService() {
    unawaited(load());
  }

  final AccessibilitySupportService _service;

  List<AccessibilityOptionModel> options = const <AccessibilityOptionModel>[];
  bool isLoading = true;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final response = await _service.getEndpoint('accessibility_support');
      final Map<String, dynamic>? payload = ApiPayloadReader.readMap(
        response.data['data'],
      );
      final List<Map<String, dynamic>> items =
          ApiPayloadReader.readMapListFromAny(payload?['options']);
      options = items
          .map(
            (item) => AccessibilityOptionModel(
              title: ApiPayloadReader.readString(item['title']),
              enabled: ApiPayloadReader.readBool(item['enabled']) ?? false,
            ),
          )
          .where((item) => item.title.isNotEmpty)
          .toList(growable: false);
    } catch (error) {
      errorMessage = error.toString();
      options = const <AccessibilityOptionModel>[];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggle(int index) async {
    if (index < 0 || index >= options.length) {
      return;
    }
    final AccessibilityOptionModel item = options[index];
    final String? key = _settingStateKeys[item.title];
    if (key == null) {
      errorMessage = 'This accessibility option is not editable yet.';
      notifyListeners();
      return;
    }
    final bool nextValue = !item.enabled;
    options = options
        .asMap()
        .entries
        .map((entry) {
          return entry.key == index
              ? AccessibilityOptionModel(title: item.title, enabled: nextValue)
              : entry.value;
        })
        .toList(growable: false);
    errorMessage = null;
    notifyListeners();
    try {
      await _service.patchEndpoint(
        'settings_state',
        payload: <String, dynamic>{key: nextValue},
      );
    } catch (error) {
      options = options
          .asMap()
          .entries
          .map((entry) {
            return entry.key == index ? item : entry.value;
          })
          .toList(growable: false);
      errorMessage = error.toString();
      notifyListeners();
    }
  }

  static const Map<String, String> _settingStateKeys = <String, String>{
    'Captions by default': 'accessibility.captions',
    'High contrast mode': 'accessibility.high_contrast',
    'Reduce motion': 'accessibility.reduce_motion',
    'Screen reader hints': 'accessibility.screen_reader_hints',
  };
}
