import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );
  static const androidEmulatorApiBaseUrl = 'http://10.0.2.2:3000';

  // The backend repo listens on localhost:3000 by default. On the Android
  // emulator we need to hit the host machine through 10.0.2.2 instead.
  static String get currentApiBaseUrl {
    if (apiBaseUrl != 'http://localhost:3000' || kIsWeb) {
      return apiBaseUrl;
    }
    return defaultTargetPlatform == TargetPlatform.android
        ? androidEmulatorApiBaseUrl
        : apiBaseUrl;
  }

  static String get apiDocsUrl => '$currentApiBaseUrl/docs';
  static String get apiOpenApiJsonUrl => '$currentApiBaseUrl/docs-json';
  static String get apiOpenApiYamlUrl => '$currentApiBaseUrl/docs-yaml';
  static const connectTimeoutMs = 15000;
  static const receiveTimeoutMs = 15000;
}
