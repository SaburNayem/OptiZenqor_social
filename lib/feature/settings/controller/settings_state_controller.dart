import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/settings_preferences_repository.dart';

class SettingsState {
  const SettingsState({
    this.values = const <String, dynamic>{},
    this.loaded = false,
  });

  final Map<String, dynamic> values;
  final bool loaded;

  SettingsState copyWith({Map<String, dynamic>? values, bool? loaded}) {
    return SettingsState(
      values: values ?? this.values,
      loaded: loaded ?? this.loaded,
    );
  }

  bool getBool(String key, {bool fallback = false}) {
    final value = values[key];
    if (value is bool) {
      return value;
    }
    return fallback;
  }

  String getString(String key, {String fallback = ''}) {
    final value = values[key];
    if (value is String) {
      return value;
    }
    return fallback;
  }

  Map<String, dynamic> getMap(String key) {
    final value = values[key];
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }
}

class SettingsStateController extends Cubit<SettingsState> {
  SettingsStateController({SettingsPreferencesRepository? repository})
    : _repository = repository ?? SettingsPreferencesRepository(),
      super(const SettingsState());

  final SettingsPreferencesRepository _repository;

  Future<void> load() async {
    if (state.loaded) {
      return;
    }
    final values = await _repository.readAll();
    emit(SettingsState(values: values, loaded: true));
  }

  Future<void> setBool(String key, bool value) async {
    await _write(<String, dynamic>{...state.values, key: value});
  }

  Future<void> setString(String key, String value) async {
    await _write(<String, dynamic>{...state.values, key: value});
  }

  Future<void> setMap(String key, Map<String, dynamic> value) async {
    await _write(<String, dynamic>{...state.values, key: value});
  }

  Future<void> _write(Map<String, dynamic> values) async {
    emit(state.copyWith(values: values));
    await _repository.writeAll(values);
  }
}
