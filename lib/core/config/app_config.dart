import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  static const defaultApiBaseUrl = 'http://localhost:3000';
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: defaultApiBaseUrl,
  );
  static const androidEmulatorApiBaseUrl = String.fromEnvironment(
    'ANDROID_EMULATOR_API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );
  static const androidDeviceApiBaseUrl = String.fromEnvironment(
    'ANDROID_DEVICE_API_BASE_URL',
    defaultValue: '',
  );

  // The backend repo listens on localhost:3000 by default. On the Android
  // emulator we need to hit the host machine through 10.0.2.2 instead. On a
  // physical Android device, either run `adb reverse tcp:3000 tcp:3000` to
  // keep using localhost or pass a LAN URL with API_BASE_URL or
  // ANDROID_DEVICE_API_BASE_URL.
  static String get currentApiBaseUrl {
    if (apiBaseUrl != defaultApiBaseUrl || kIsWeb) {
      return apiBaseUrl;
    }

    final String explicitAndroidDeviceBaseUrl = androidDeviceApiBaseUrl.trim();
    if (defaultTargetPlatform == TargetPlatform.android &&
        explicitAndroidDeviceBaseUrl.isNotEmpty) {
      return explicitAndroidDeviceBaseUrl;
    }

    return defaultTargetPlatform == TargetPlatform.android
        ? androidEmulatorApiBaseUrl
        : apiBaseUrl;
  }

  static String? get debugLocalNetworkHint {
    if (!kDebugMode ||
        kIsWeb ||
        defaultTargetPlatform != TargetPlatform.android) {
      return null;
    }

    final Uri? resolvedBaseUri = Uri.tryParse(currentApiBaseUrl);
    final String host = resolvedBaseUri?.host.toLowerCase() ?? '';
    if (host == '10.0.2.2') {
      return 'Using Android emulator loopback (10.0.2.2). On a physical '
          'Android device, either run adb reverse tcp:3000 tcp:3000 and keep '
          'using localhost, or run with '
          '--dart-define=API_BASE_URL=http://<your-computer-lan-ip>:3000 '
          'or --dart-define=ANDROID_DEVICE_API_BASE_URL='
          'http://<your-computer-lan-ip>:3000.';
    }

    if (host == 'localhost' || host == '127.0.0.1') {
      return 'Using localhost. On a physical Android device this works when '
          'adb reverse tcp:3000 tcp:3000 is active. Otherwise launch with '
          '--dart-define=API_BASE_URL=http://<your-computer-lan-ip>:3000.';
    }

    if (_isPrivateIpv4Host(host)) {
      return 'Using your computer LAN IP. Make sure the phone and computer '
          'are on the same Wi-Fi network and that port 3000 is allowed '
          'through the computer firewall.';
    }

    return null;
  }

  static bool _isPrivateIpv4Host(String host) {
    final List<String> parts = host.split('.');
    if (parts.length != 4) {
      return false;
    }

    final List<int> octets = parts
        .map(int.tryParse)
        .whereType<int>()
        .toList(growable: false);
    if (octets.length != 4) {
      return false;
    }

    if (octets[0] == 10) {
      return true;
    }
    if (octets[0] == 192 && octets[1] == 168) {
      return true;
    }
    if (octets[0] == 172 && octets[1] >= 16 && octets[1] <= 31) {
      return true;
    }
    return false;
  }

  static String get apiDocsUrl => '$currentApiBaseUrl/docs';
  static String get apiOpenApiJsonUrl => '$currentApiBaseUrl/docs-json';
  static String get apiOpenApiYamlUrl => '$currentApiBaseUrl/docs-yaml';
  static const connectTimeoutMs = 15000;
  static const receiveTimeoutMs = 15000;
  static const uploadTimeoutMs = 90000;
}
