import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<T?> read<T>(String key) async {
    await init();
    final value = _prefs!.get(key);
    return value as T?;
  }

  Future<void> write(String key, dynamic value) async {
    await init();
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
    final raw = _prefs!.getString(key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  Future<List<Map<String, dynamic>>> readJsonList(String key) async {
    await init();
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
    await _prefs!.setString(key, jsonEncode(value));
  }

  Future<void> writeJsonList(String key, List<Map<String, dynamic>> value) async {
    await init();
    await _prefs!.setString(key, jsonEncode(value));
  }

  Future<void> remove(String key) async {
    await init();
    await _prefs!.remove(key);
  }
}
