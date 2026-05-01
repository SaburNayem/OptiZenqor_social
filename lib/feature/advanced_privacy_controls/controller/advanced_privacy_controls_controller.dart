import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/data/api/api_payload_reader.dart';
import '../model/privacy_setting_model.dart';
import '../service/advanced_privacy_controls_service.dart';

class AdvancedPrivacyControlsController extends ChangeNotifier {
  AdvancedPrivacyControlsController({AdvancedPrivacyControlsService? service})
    : _service = service ?? AdvancedPrivacyControlsService() {
    unawaited(load());
  }

  final AdvancedPrivacyControlsService _service;

  List<PrivacySettingModel> settings = const <PrivacySettingModel>[];
  bool isLoading = true;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final response = await _service.getEndpoint('advanced_privacy_controls');
      final Map<String, dynamic>? payload = ApiPayloadReader.readMap(
        response.data['data'],
      );
      final Map<String, dynamic>? state = ApiPayloadReader.readMap(
        payload?['state'],
      );
      final List<Map<String, dynamic>> controls =
          ApiPayloadReader.readMapListFromAny(state?['controls']);
      settings = controls
          .map(
            (item) => PrivacySettingModel(
              title: ApiPayloadReader.readString(item['title']),
              value: ApiPayloadReader.readBool(item['value']) ?? false,
            ),
          )
          .where((item) => item.title.isNotEmpty)
          .toList(growable: false);
    } catch (error) {
      errorMessage = error.toString();
      settings = const <PrivacySettingModel>[];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggle(int index) async {
    if (index < 0 || index >= settings.length) {
      return;
    }
    final PrivacySettingModel item = settings[index];
    final String? key = _settingStateKeys[item.title];
    if (key == null) {
      errorMessage = 'This privacy control is not editable yet.';
      notifyListeners();
      return;
    }
    final bool nextValue = !item.value;
    settings = settings
        .asMap()
        .entries
        .map((entry) {
          return entry.key == index
              ? PrivacySettingModel(title: item.title, value: nextValue)
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
      settings = settings
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
    'Private account': 'privacy.profile_private',
    'Allow mentions': 'privacy.allow_mentions',
    'Allow comments from everyone': 'privacy.allow_comments',
    'Sensitive content filter': 'privacy.hide_sensitive',
    'Hide like counts': 'privacy.hide_likes',
  };
}
