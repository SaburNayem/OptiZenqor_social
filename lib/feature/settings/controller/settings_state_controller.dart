import 'package:flutter/foundation.dart';

import '../repository/settings_preferences_repository.dart';

class SettingsStateController extends ChangeNotifier {
  SettingsStateController({SettingsPreferencesRepository? repository})
      : _repository = repository ?? SettingsPreferencesRepository();

  final SettingsPreferencesRepository _repository;
  Map<String, dynamic> _state = <String, dynamic>{};
  bool _loaded = false;

  bool get loaded => _loaded;

  Future<void> load() async {
    if (_loaded) {
      return;
    }
    _state = await _repository.readAll();
    _loaded = true;
    notifyListeners();
  }

  bool getBool(String key, {bool fallback = false}) {
    final value = _state[key];
    if (value is bool) {
      return value;
    }
    return fallback;
  }

  String getString(String key, {String fallback = ''}) {
    final value = _state[key];
    if (value is String) {
      return value;
    }
    return fallback;
  }

  Map<String, dynamic> getMap(String key) {
    final value = _state[key];
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }

  Future<void> setBool(String key, bool value) async {
    _state[key] = value;
    notifyListeners();
    await _repository.writeAll(_state);
  }

  Future<void> setString(String key, String value) async {
    _state[key] = value;
    notifyListeners();
    await _repository.writeAll(_state);
  }

  Future<void> setMap(String key, Map<String, dynamic> value) async {
    _state[key] = value;
    notifyListeners();
    await _repository.writeAll(_state);
  }
}
