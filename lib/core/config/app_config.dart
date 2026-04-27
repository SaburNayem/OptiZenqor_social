import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  static const defaultApiBaseUrl =
      'https://opti-zenqor-social-backend.vercel.app';
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: defaultApiBaseUrl,
  );

  static String get currentApiBaseUrl {
    if (kIsWeb && apiBaseUrl == defaultApiBaseUrl) {
      return Uri.base.origin;
    }

    return apiBaseUrl;
  }

  static String? get debugLocalNetworkHint => null;

  static String get apiDocsUrl => '$currentApiBaseUrl/docs';
  static String get apiOpenApiJsonUrl => '$currentApiBaseUrl/docs-json';
  static String get apiOpenApiYamlUrl => '$currentApiBaseUrl/docs-yaml';
  static const connectTimeoutMs = 15000;
  static const receiveTimeoutMs = 30000;
  static const uploadTimeoutMs = 90000;
}
