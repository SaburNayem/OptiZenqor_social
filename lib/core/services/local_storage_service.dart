import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  SharedPreferences? _prefs;
  bool _initialized = false;
  bool _pluginAvailable = true;
  final Map<String, dynamic> _memoryStore = <String, dynamic>{};

  Future<void> init() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    try {
      _prefs ??= await SharedPreferences.getInstance();
    } on MissingPluginException {
      _pluginAvailable = false;
    }
  }

  Future<T?> read<T>(String key) async {
    await init();
    if (!_pluginAvailable || _prefs == null) {
      return _memoryStore[key] as T?;
    }
    final value = _prefs!.get(key);
    return value as T?;
  }

  Future<void> write(String key, dynamic value) async {
    await init();
    if (!_pluginAvailable || _prefs == null) {
      _memoryStore[key] = value;
      return;
    }
    if (value is String) {
      await _prefs!.setString(key, value);
    } else if (value is bool) {
      await _prefs!.setBool(key, value);
    } else if (value is int) {
      await _prefs!.setInt(key, value);
    } else if (value is double) {
      await _prefs!.setDouble(key, value);
    } else if (value is List<String>) {
      await _prefs!.setStringList(key, value);
    } else {
      await _prefs!.setString(key, jsonEncode(value));
    }
  }

  Future<Map<String, dynamic>?> readJson(String key) async {
    await init();
    if (!_pluginAvailable || _prefs == null) {
      final dynamic value = _memoryStore[key];
      if (value == null) {
        return null;
      }
      if (value is Map<String, dynamic>) {
        return value;
      }
      if (value is String && value.isNotEmpty) {
        return Map<String, dynamic>.from(jsonDecode(value) as Map);
      }
      return null;
    }
    final raw = _prefs!.getString(key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  Future<List<Map<String, dynamic>>> readJsonList(String key) async {
    await init();
    if (!_pluginAvailable || _prefs == null) {
      final dynamic value = _memoryStore[key];
      if (value == null) {
        return <Map<String, dynamic>>[];
      }
      if (value is List<Map<String, dynamic>>) {
        return value;
      }
      if (value is List<dynamic>) {
        return value
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }
      if (value is String && value.isNotEmpty) {
        final decoded = jsonDecode(value) as List<dynamic>;
        return decoded
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }
      return <Map<String, dynamic>>[];
    }
    final raw = _prefs!.getString(key);
    if (raw == null || raw.isEmpty) {
      return <Map<String, dynamic>>[];
    }
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<void> writeJson(String key, Map<String, dynamic> value) async {
    await init();
    if (!_pluginAvailable || _prefs == null) {
      _memoryStore[key] = value;
      return;
    }
    await _prefs!.setString(key, jsonEncode(value));
  }

  Future<void> writeJsonList(String key, List<Map<String, dynamic>> value) async {
    await init();
    if (!_pluginAvailable || _prefs == null) {
      _memoryStore[key] = value;
      return;
    }
    await _prefs!.setString(key, jsonEncode(value));
  }

  Future<void> remove(String key) async {
    await init();
    if (!_pluginAvailable || _prefs == null) {
      _memoryStore.remove(key);
      return;
    }
    await _prefs!.remove(key);
  }
}
