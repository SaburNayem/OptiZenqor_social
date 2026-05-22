import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  static const appFlavor = String.fromEnvironment(
    'APP_FLAVOR',
    defaultValue: kReleaseMode ? 'prod' : 'dev',
  );
  static const deployedApiBaseUrl =
      'https://opti-zenqor-social-backend.vercel.app';
  static const defaultWebApiProxyPath = '/api';
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static const socketBaseUrl = String.fromEnvironment(
    'SOCKET_BASE_URL',
    defaultValue: '',
  );
  static const socketEnabled = bool.fromEnvironment(
    'SOCKET_ENABLED',
    defaultValue: true,
  );
  static const socketPath = String.fromEnvironment(
    'SOCKET_PATH',
    defaultValue: '/socket.io',
  );
  static const socketContractPath = String.fromEnvironment(
    'SOCKET_CONTRACT_PATH',
    defaultValue: '/socket/contract',
  );

  static String get currentApiBaseUrl {
    return apiBaseUrlCandidates.first;
  }

  static List<String> get apiBaseUrlCandidates {
    final List<String> candidates = <String>[];

    void addCandidate(String value) {
      final String normalized = _normalizeUrl(value);
      if (normalized.isEmpty || candidates.contains(normalized)) {
        return;
      }
      candidates.add(normalized);
    }

    final String explicitBaseUrl = apiBaseUrl.trim();
    if (explicitBaseUrl.isNotEmpty) {
      addCandidate(explicitBaseUrl);
      return candidates;
    }

    if (kIsWeb && Uri.base.host.endsWith('.vercel.app')) {
      addCandidate(Uri.base.resolve(defaultWebApiProxyPath).toString());
      return candidates;
    }

    addCandidate(deployedApiBaseUrl);
    return candidates;
  }

  static bool get isUsingDefaultRemoteBackend =>
      apiBaseUrl.trim().isEmpty && currentApiBaseUrl == deployedApiBaseUrl;

  static String get currentSocketBaseUrl {
    if (socketBaseUrl.trim().isNotEmpty) {
      return socketBaseUrl.trim();
    }
    final Uri apiUri = Uri.parse(currentApiBaseUrl);
    final String scheme = apiUri.scheme == 'https' ? 'wss' : 'ws';
    return apiUri.replace(scheme: scheme, path: '').toString();
  }

  static bool get canUseRealtimeSocket {
    if (!socketEnabled) {
      return false;
    }
    if (socketBaseUrl.trim().isNotEmpty) {
      return true;
    }
    final Uri? apiUri = Uri.tryParse(currentApiBaseUrl);
    final String host = apiUri?.host.toLowerCase().trim() ?? '';
    return !host.endsWith('.vercel.app');
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
    if (apiBaseUrl.trim().isNotEmpty) {
      return 'Debug build is using an explicit API override: $currentApiBaseUrl';
    }
    if (kIsWeb) {
      if (isUsingDefaultRemoteBackend) {
        return 'Debug web build is using the deployed backend through the same-origin `/api` proxy path.';
      }
      return 'Debug web build is using an overridden backend: $currentApiBaseUrl';
    }
    if (isUsingDefaultRemoteBackend) {
      return 'Debug build is using the deployed backend by default.';
    }
    return 'Debug build is using an overridden backend: $currentApiBaseUrl';
  }

  static String get apiDocsUrl => '$currentApiBaseUrl/docs';
  static String get apiOpenApiJsonUrl => '$currentApiBaseUrl/docs-json';
  static String get apiOpenApiYamlUrl => '$currentApiBaseUrl/docs-yaml';
  static int get connectTimeoutMs => kDebugMode ? 4000 : 12000;
  static int get receiveTimeoutMs => kDebugMode ? 10000 : 20000;
  static int get uploadTimeoutMs => kDebugMode ? 30000 : 90000;
  static int get socketConnectTimeoutMs => kDebugMode ? 5000 : 15000;
  static const socketReconnectDelayMs = 3000;
  static const allowOfflineFallback = bool.fromEnvironment(
    'ALLOW_OFFLINE_FALLBACK',
    defaultValue: false,
  );

  static String _normalizeUrl(String value) {
    return value.trim().replaceFirst(RegExp(r'/+$'), '');
  }
}
