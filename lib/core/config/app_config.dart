import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  static const appFlavor = String.fromEnvironment(
    'APP_FLAVOR',
    defaultValue: kReleaseMode ? 'prod' : 'dev',
  );
  static const defaultApiBaseUrl =
      'https://opti-zenqor-social-backend.vercel.app';
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static const socketBaseUrl = String.fromEnvironment(
    'SOCKET_BASE_URL',
    defaultValue: '',
  );
  static const socketPath = String.fromEnvironment(
    'SOCKET_PATH',
    defaultValue: '/socket',
  );
  static const socketContractPath = String.fromEnvironment(
    'SOCKET_CONTRACT_PATH',
    defaultValue: '/socket/contract',
  );
  static const localApiPort = String.fromEnvironment(
    'LOCAL_API_PORT',
    defaultValue: '3000',
  );

  static String get currentApiBaseUrl {
    final String explicitBaseUrl = apiBaseUrl.trim();
    if (explicitBaseUrl.isNotEmpty) {
      return explicitBaseUrl;
    }

    if (useRemoteOnly) {
      return defaultApiBaseUrl;
    }

    if (kReleaseMode || appFlavor == 'prod') {
      return defaultApiBaseUrl;
    }

    if (kIsWeb) {
      if (Uri.base.hasAuthority) {
        return Uri.base.origin;
      }
      return 'http://127.0.0.1:$localApiPort';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:$localApiPort';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return 'http://127.0.0.1:$localApiPort';
    }
  }

  static String get currentSocketBaseUrl {
    if (socketBaseUrl.trim().isNotEmpty) {
      return socketBaseUrl.trim();
    }
    final Uri apiUri = Uri.parse(currentApiBaseUrl);
    final String scheme = apiUri.scheme == 'https' ? 'wss' : 'ws';
    return apiUri.replace(scheme: scheme, path: '').toString();
  }

  static Uri get socketContractUri =>
      Uri.parse(currentApiBaseUrl).resolve(socketContractPath);

  static Uri defaultSocketUri({
    Map<String, dynamic>? queryParameters,
    String? path,
  }) {
    final Uri baseSocketUri = Uri.parse(currentSocketBaseUrl);
    final Map<String, String>? query = queryParameters?.map(
      (String key, dynamic value) => MapEntry(key, value.toString()),
    );
    return baseSocketUri.replace(
      path: path ?? socketPath,
      queryParameters: query,
    );
  }

  static String? get debugLocalNetworkHint {
    if (kReleaseMode || appFlavor == 'prod' || useRemoteOnly) {
      return null;
    }
    if (kIsWeb) {
      return 'Web dev defaults to the current origin unless API_BASE_URL is set.';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'Android emulator should usually use 10.0.2.2 for localhost.';
      case TargetPlatform.iOS:
        return 'iOS simulator can usually reach localhost via 127.0.0.1.';
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return 'Desktop/local dev defaults to 127.0.0.1 unless API_BASE_URL is set.';
    }
  }

  static String get apiDocsUrl => '$currentApiBaseUrl/docs';
  static String get apiOpenApiJsonUrl => '$currentApiBaseUrl/docs-json';
  static String get apiOpenApiYamlUrl => '$currentApiBaseUrl/docs-yaml';
  static const connectTimeoutMs = 15000;
  static const receiveTimeoutMs = 30000;
  static const uploadTimeoutMs = 90000;
  static const socketConnectTimeoutMs = 15000;
  static const socketReconnectDelayMs = 3000;
  static const useRemoteOnly = bool.fromEnvironment(
    'USE_REMOTE_ONLY',
    defaultValue: true,
  );
  static const allowOfflineFallback = bool.fromEnvironment(
    'ALLOW_OFFLINE_FALLBACK',
    defaultValue: false,
  );
}
