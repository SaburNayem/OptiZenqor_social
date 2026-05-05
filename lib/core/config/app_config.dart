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
  static const debugSharedApiBaseUrl = String.fromEnvironment(
    'DEBUG_SHARED_API_BASE_URL',
    defaultValue: '',
  );
  static const localLanApiBaseUrl = String.fromEnvironment(
    'LOCAL_LAN_API_BASE_URL',
    defaultValue: '',
  );
  static const localAndroidDebugApiBaseUrl = String.fromEnvironment(
    'LOCAL_ANDROID_DEBUG_API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );
  static const localAdbReverseApiBaseUrl = 'http://127.0.0.1:3000';
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

    if (kIsWeb && !_isLocalWebOrigin) {
      addCandidate(Uri.base.resolve(defaultWebApiProxyPath).toString());
      return candidates;
    }

    final String sharedDebugBaseUrl = debugSharedApiBaseUrl.trim();
    if (!kReleaseMode && sharedDebugBaseUrl.isNotEmpty) {
      addCandidate(sharedDebugBaseUrl);
    }

    final String localLanBaseUrl = localLanApiBaseUrl.trim();
    if (!kReleaseMode && localLanBaseUrl.isNotEmpty) {
      addCandidate(localLanBaseUrl);
    }

    if (!kReleaseMode && !kIsWeb) {
      addCandidate(localAndroidDebugApiBaseUrl);
      addCandidate(localAdbReverseApiBaseUrl);
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
      if (_isLocalWebOrigin) {
        if (debugSharedApiBaseUrl.trim().isNotEmpty) {
          return 'Debug web build is using the shared debug backend: ${debugSharedApiBaseUrl.trim()}.';
        }
        return 'Debug web build is running on a local origin and calling the deployed backend directly. If Chrome shows `Failed to fetch`, either use `--dart-define=DEBUG_SHARED_API_BASE_URL=<public-backend-url>` for one shared route across devices, deploy the web app behind the bundled Vercel `/api` rewrite, or allow this localhost origin in the backend CORS policy.';
      }
      if (isUsingDefaultRemoteBackend) {
        return 'Debug web build is using the deployed backend through the same-origin `/api` proxy path.';
      }
      return 'Debug web build is using an overridden backend: $currentApiBaseUrl';
    }
    if (debugSharedApiBaseUrl.trim().isNotEmpty) {
      return 'Debug build is using the shared debug backend: ${debugSharedApiBaseUrl.trim()}. This is the simplest single route for phone, emulator, and local web.';
    }
    if (localLanApiBaseUrl.trim().isNotEmpty) {
      return 'Debug build has LAN fallback enabled at ${localLanApiBaseUrl.trim()}. The app will try configured debug fallback URLs before the deployed backend.';
    }
    if (isUsingDefaultRemoteBackend) {
      final String lanHint = localLanApiBaseUrl.trim().isEmpty
          ? '<your-pc-lan-ip>:3000'
          : localLanApiBaseUrl.trim();
      return 'Debug build is using the deployed backend by default. For one shared local route across devices, start your backend on port 3000 and launch with `--dart-define=DEBUG_SHARED_API_BASE_URL=http://$lanHint`. Emulator-only local uses `$localAndroidDebugApiBaseUrl`, USB reverse uses `$localAdbReverseApiBaseUrl`, and real devices should use your PC LAN IP.';
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
    return host == 'localhost' || host == '127.0.0.1' || host == '0.0.0.0';
  }

  static String _normalizeUrl(String value) {
    return value.trim().replaceFirst(RegExp(r'/+$'), '');
  }
}
