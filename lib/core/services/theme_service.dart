import 'package:flutter/material.dart';

import '../constants/storage_keys.dart';
import 'local_storage_service.dart';

class ThemeService {
  ThemeService._();

  static final ThemeService instance = ThemeService._();

  final LocalStorageService _storage = LocalStorageService();
  final ValueNotifier<ThemeMode> mode = ValueNotifier<ThemeMode>(ThemeMode.system);

  Future<void> init() async {
    final saved = await _storage.read<String>(StorageKeys.themeMode);
    mode.value = _parse(saved);
  }

  Future<void> setTheme(ThemeMode next) async {
    mode.value = next;
    await _storage.write(StorageKeys.themeMode, next.name);
  }

  ThemeMode _parse(String? raw) {
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
