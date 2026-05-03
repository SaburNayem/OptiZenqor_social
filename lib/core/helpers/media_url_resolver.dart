import '../config/app_config.dart';

class MediaUrlResolver {
  const MediaUrlResolver._();

  static String resolve(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return trimmed;
    }
    if (trimmed.startsWith('file://')) {
      return trimmed.replaceFirst('file://', '');
    }
    final Uri? uri = Uri.tryParse(trimmed);
    if (uri == null) {
      return trimmed;
    }
    if (!uri.hasScheme) {
      return _resolveRelative(trimmed);
    }
    return _normalizeKnownImageHosts(trimmed, uri);
  }

  static String _resolveRelative(String value) {
    final Uri? apiBase = Uri.tryParse(AppConfig.currentApiBaseUrl);
    if (apiBase == null || !apiBase.hasScheme || apiBase.host.isEmpty) {
      return value;
    }
    final String path = value.startsWith('/') ? value : '/$value';
    return apiBase.replace(path: _joinPaths(apiBase.path, path)).toString();
  }

  static String _joinPaths(String basePath, String path) {
    final String normalizedBase = basePath.endsWith('/')
        ? basePath.substring(0, basePath.length - 1)
        : basePath;
    if (normalizedBase.isEmpty) {
      return path;
    }
    return '$normalizedBase$path';
  }

  static String _normalizeKnownImageHosts(String value, Uri uri) {
    if (uri.host.toLowerCase() != 'placehold.co') {
      return value;
    }

    final String path = uri.path.toLowerCase();
    if (path.endsWith('.png') ||
        path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.webp')) {
      return value;
    }

    return '$value/png';
  }
}
