class DeepLinkService {
  Future<String?> handleIncomingLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return null;
    }
    return _routeFromUri(uri);
  }

  Future<String?> open(String route) async {
    return route;
  }

  String? _routeFromUri(Uri uri) {
    if (uri.pathSegments.isEmpty) {
      return null;
    }
    if (uri.pathSegments.first == 'post' && uri.pathSegments.length > 1) {
      return '/post-detail?id=${uri.pathSegments[1]}';
    }
    if (uri.pathSegments.first == 'profile' && uri.pathSegments.length > 1) {
      return '/user-profile?id=${uri.pathSegments[1]}';
    }
    if (uri.pathSegments.first == 'chat' && uri.pathSegments.length > 1) {
      return '/chat?chatId=${uri.pathSegments[1]}';
    }
    return uri.path;
  }
}
