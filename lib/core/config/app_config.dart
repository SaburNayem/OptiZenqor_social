import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  static const appFlavor = String.fromEnvironment(
    'APP_FLAVOR',
    defaultValue: kReleaseMode ? 'prod' : 'dev',
  );
  static const defaultApiBaseUrl = kReleaseMode
      ? 'https://opti-zenqor-social-backend.vercel.app'
      : 'http://127.0.0.1:3000';
  static const defaultWebApiProxyPath = '/api';
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static const localAndroidDebugApiBaseUrl = String.fromEnvironment(
    'LOCAL_ANDROID_DEBUG_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:3000',
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

  static String get currentApiBaseUrl {
    final String explicitBaseUrl = apiBaseUrl.trim();
    if (explicitBaseUrl.isNotEmpty) {
      return explicitBaseUrl;
    }
    if (kIsWeb && !_isLocalWebOrigin) {
      return Uri.base.resolve(defaultWebApiProxyPath).toString();
    }
    if (!kIsWeb && !kReleaseMode && Platform.isAndroid) {
      return localAndroidDebugApiBaseUrl;
    }
    return defaultApiBaseUrl;
  }

  static bool get isUsingDefaultRemoteBackend =>
      apiBaseUrl.trim().isEmpty && currentApiBaseUrl == defaultApiBaseUrl;

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
    if (kReleaseMode || appFlavor == 'prod') {
      return null;
    }
    if (kIsWeb) {
      if (_isLocalWebOrigin) {
        return 'Debug web build is running on a local origin and calling the deployed Vercel backend directly. If Chrome shows `Failed to fetch`, the backend is likely blocking this localhost origin with CORS. Deploy the web app behind the bundled Vercel `/api` rewrite or allow this origin in the backend CORS policy.';
      }
      if (isUsingDefaultRemoteBackend) {
        return 'Debug web build is using the deployed backend through the same-origin `/api` proxy path.';
      }
      return 'Debug web build is using an overridden backend: $currentApiBaseUrl';
    }
    if (!kIsWeb && Platform.isAndroid && apiBaseUrl.trim().isEmpty) {
      return 'Debug Android build is using the local backend by default. Make sure `adb reverse tcp:3000 tcp:3000` is active, or pass `--dart-define=API_BASE_URL=$defaultApiBaseUrl` to force the deployed backend.';
    }
    if (isUsingDefaultRemoteBackend) {
      return 'Debug build is using the deployed Vercel backend. To test the local backend on a USB-connected Android device, run `adb reverse tcp:3000 tcp:3000` and launch with `--dart-define=API_BASE_URL=$localAndroidDebugApiBaseUrl`.';
    }
    return 'Debug build is using an overridden backend: $currentApiBaseUrl';
  }

  static String get apiDocsUrl => '$currentApiBaseUrl/docs';
  static String get apiOpenApiJsonUrl => '$currentApiBaseUrl/docs-json';
  static String get apiOpenApiYamlUrl => '$currentApiBaseUrl/docs-yaml';
  static const connectTimeoutMs = 15000;
  static const receiveTimeoutMs = 30000;
  static const uploadTimeoutMs = 90000;
  static const socketConnectTimeoutMs = 15000;
  static const socketReconnectDelayMs = 3000;
  static const useRemoteOnly = true;
  static const allowOfflineFallback = bool.fromEnvironment(
    'ALLOW_OFFLINE_FALLBACK',
    defaultValue: false,
  );

  static bool get _isLocalWebOrigin {
    if (!kIsWeb) {
      return false;
    }
    final String host = Uri.base.host.toLowerCase().trim();
    return host == 'localhost' ||
        host == '127.0.0.1' ||
        host == '0.0.0.0';
  }
}
