// ignore_for_file: invalid_use_of_protected_member

part of 'chat_detail_screen.dart';

extension _ChatDetailMessageHelpers on _ChatDetailScreenState {
  String _messagePreviewText(MessageModel message) {
    if (_isLocationMessage(message)) {
      return _locationPreviewText(message);
    }
    final String text = message.text.trim();
    if (text.isNotEmpty) {
      return text;
    }
    switch (message.kind) {
      case 'image':
      case 'gallery':
      case 'camera':
      case 'photo':
        return 'Photo';
      case 'audio':
      case 'voice':
        return 'Audio message';
      case 'file':
      case 'document':
        return 'Attachment';
      case 'location':
        return 'Location';
      case 'contact':
        return 'Contact';
      default:
        return (message.mediaPath ?? '').trim().isNotEmpty
            ? 'Attachment'
            : 'Message';
    }
  }

  String _chatErrorMessage(String raw) {
    final String normalized = raw.trim();
    if (normalized.isEmpty) {
      return 'Unable to send message.';
    }
    final String cleaned = normalized.replaceFirst('Exception: ', '');
    return cleaned.length > 120 ? 'Unable to send message.' : cleaned;
  }

  void _closeSearch() {
    FocusScope.of(context).unfocus();
    setState(() {
      _searchController.clear();
      _isSearchOpen = false;
    });
  }

  String? get _headerStatusText {
    if (_otherUserTyping) {
      return 'Typing...';
    }
    if (_chatUser.isOnline == true) {
      return 'Online';
    }
    final DateTime? lastSeen = _chatUser.lastSeen;
    if (lastSeen == null) {
      return null;
    }
    final Duration difference = DateTime.now().difference(lastSeen);
    if (difference.inMinutes < 1) {
      return 'Last seen just now';
    }
    if (difference.inHours < 1) {
      return 'Last seen ${difference.inMinutes}m ago';
    }
    if (difference.inDays < 1) {
      return 'Last seen ${difference.inHours}h ago';
    }
    return 'Last seen ${difference.inDays}d ago';
  }

  IconData _attachmentIcon(String kind) {
    switch (kind) {
      case 'gallery':
      case 'image':
      case 'photo':
        return Icons.photo_library_outlined;
      case 'camera':
        return Icons.camera_alt_outlined;
      case 'document':
      case 'file':
        return Icons.description_outlined;
      case 'location':
        return Icons.location_on_outlined;
      case 'contact':
        return Icons.person_outline_rounded;
      case 'audio':
        return Icons.headphones_outlined;
      default:
        return Icons.attach_file_rounded;
    }
  }

  bool _isImageMessage(MessageModel message) {
    return message.kind == 'gallery' ||
        message.kind == 'camera' ||
        message.kind == 'image' ||
        message.kind == 'photo' ||
        _isImagePath(message.mediaPath);
  }

  bool _isLocationMessage(MessageModel message) {
    return message.kind == 'location' ||
        _extractMessageLatLng(message) != null ||
        _extractLocationUrl(message) != null;
  }

  String _locationTitle(MessageModel message) {
    final String locationName = (message.locationName ?? '').trim();
    if (locationName.isNotEmpty && !_looksLikeMapsUrl(locationName)) {
      if (RegExp(
        r'^shared location\b',
        caseSensitive: false,
      ).hasMatch(locationName)) {
        return 'Shared location';
      }
      return locationName;
    }
    return 'Shared location';
  }

  String _locationPreviewText(MessageModel message) {
    final String locationName = (message.locationName ?? '').trim();
    if (locationName.isNotEmpty && !_looksLikeMapsUrl(locationName)) {
      return locationName;
    }
    final _ChatLatLng? coordinates = _extractMessageLatLng(message);
    if (coordinates != null) {
      return coordinates.formatted;
    }
    final List<String> lines = message.text
        .split('\n')
        .map((String line) => line.trim())
        .where((String line) => line.isNotEmpty)
        .toList(growable: false);
    for (final String line in lines) {
      if (!_looksLikeUrl(line)) {
        return line;
      }
    }
    return 'Open location in Google Maps';
  }

  String? _locationNameFromText(String text) {
    final List<String> lines = text
        .split('\n')
        .map((String line) => line.trim())
        .where((String line) => line.isNotEmpty)
        .toList(growable: false);
    for (final String line in lines) {
      if (_looksLikeMapsUrl(line)) {
        continue;
      }
      if (RegExp(r'^shared location\b', caseSensitive: false).hasMatch(line)) {
        return 'Shared location';
      }
      final _ChatLatLng? coordinates = _extractLatLng(line);
      if (coordinates != null &&
          line.replaceAll(RegExp(r'[-\d.,\s]'), '').isEmpty) {
        return 'Shared location';
      }
      return line;
    }
    return null;
  }

  String? _extractLocationUrl(MessageModel message) {
    final String? explicitUrl = message.locationUrl?.trim();
    if (explicitUrl != null &&
        explicitUrl.isNotEmpty &&
        _looksLikeMapsUrl(explicitUrl)) {
      return explicitUrl;
    }
    final String? mediaPath = message.mediaPath?.trim();
    if (mediaPath != null &&
        mediaPath.isNotEmpty &&
        _looksLikeMapsUrl(mediaPath)) {
      return mediaPath;
    }

    return _extractMapsUrlFromText(message.text);
  }

  String? _extractMapsUrlFromText(String text) {
    final Iterable<RegExpMatch> matches = RegExp(
      r'(geo:[^\s]+|https?:\/\/[^\s]+)',
      caseSensitive: false,
    ).allMatches(text);
    for (final RegExpMatch match in matches) {
      final String rawUrl = (match.group(0) ?? '').trim();
      final String normalized = rawUrl.replaceAll(RegExp(r'[),.;]+$'), '');
      if (_looksLikeMapsUrl(normalized)) {
        return normalized;
      }
    }
    return null;
  }

  _ChatLatLng? _extractProfileLatLng(String? location) {
    return _extractLatLng(location ?? '');
  }

  _ChatLatLng? _extractMessageLatLng(MessageModel message) {
    final double? latitude = message.latitude;
    final double? longitude = message.longitude;
    if (latitude != null &&
        longitude != null &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180) {
      return _ChatLatLng(latitude, longitude);
    }
    final String mediaPath = message.mediaPath?.trim() ?? '';
    if (mediaPath.isNotEmpty) {
      final _ChatLatLng? mediaLocation = _extractLatLng(mediaPath);
      if (mediaLocation != null) {
        return mediaLocation;
      }
    }
    final String locationUrl = message.locationUrl?.trim() ?? '';
    if (locationUrl.isNotEmpty) {
      final _ChatLatLng? urlLocation = _extractLatLng(locationUrl);
      if (urlLocation != null) {
        return urlLocation;
      }
    }
    return _extractLatLng(message.text);
  }

  _ChatLatLng? _extractLatLng(String value) {
    final RegExpMatch? match = RegExp(
      r'(-?\d+(?:\.\d+)?)\s*,\s*(-?\d+(?:\.\d+)?)',
    ).firstMatch(value);
    if (match == null) {
      return null;
    }
    final double? latitude = double.tryParse(match.group(1) ?? '');
    final double? longitude = double.tryParse(match.group(2) ?? '');
    if (latitude == null ||
        longitude == null ||
        latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      return null;
    }
    return _ChatLatLng(latitude, longitude);
  }

  Future<void> _openSharedLocation(_ChatLatLng location) async {
    if (await _tryOpenNativeGoogleMaps(location)) {
      return;
    }

    if (kIsWeb &&
        await _tryOpenUri(Uri.parse(_buildGoogleMapsSearchUrl(location)))) {
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google Maps app is required to open this location.'),
        ),
      );
    }
  }

  Future<bool> _tryOpenNativeGoogleMaps(_ChatLatLng location) async {
    if (kIsWeb) {
      return false;
    }

    final String compactCoordinates =
        '${location.latitude.toStringAsFixed(6)},${location.longitude.toStringAsFixed(6)}';
    if (Platform.isAndroid) {
      return _tryOpenUri(Uri.parse('google.navigation:q=$compactCoordinates'));
    }

    if (Platform.isIOS) {
      return _tryOpenUri(
        Uri.parse(
          'comgooglemaps://?q=$compactCoordinates&center=$compactCoordinates&zoom=16',
        ),
      );
    }

    return false;
  }

  String _buildGoogleMapsSearchUrl(_ChatLatLng location) {
    return _buildGoogleMapsUrl(location.formatted);
  }

  String _buildGoogleMapsUrl(String rawLocation) {
    final String normalized = rawLocation.trim();
    final RegExp latLngPattern = RegExp(
      r'^\s*(-?\d+(?:\.\d+)?)\s*,\s*(-?\d+(?:\.\d+)?)\s*$',
    );
    final RegExpMatch? match = latLngPattern.firstMatch(normalized);
    final String query = match == null
        ? normalized
        : '${match.group(1)},${match.group(2)}';
    return Uri.https('www.google.com', '/maps/search/', <String, String>{
      'api': '1',
      'query': query,
    }).toString();
  }

  bool _looksLikeMapsUrl(String value) {
    final String normalized = value.trim();
    if (normalized.toLowerCase().startsWith('geo:')) {
      return true;
    }
    if (!_looksLikeUrl(normalized)) {
      return false;
    }
    final Uri? uri = Uri.tryParse(normalized);
    if (uri == null) {
      return false;
    }
    final String host = uri.host.toLowerCase();
    final String path = uri.path.toLowerCase();
    return (host.contains('google.com') && path.contains('/maps')) ||
        host == 'maps.google.com' ||
        host == 'maps.app.goo.gl' ||
        (host == 'goo.gl' && path.startsWith('/maps'));
  }

  bool _looksLikeUrl(String value) {
    final Uri? uri = Uri.tryParse(value.trim());
    return uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https');
  }

  bool _shouldUseUrlMedia(String path) {
    final Uri? uri = Uri.tryParse(path.trim());
    if (uri == null || !uri.hasScheme) {
      return false;
    }
    return uri.scheme == 'http' ||
        uri.scheme == 'https' ||
        uri.scheme == 'blob' ||
        uri.scheme == 'data';
  }

  bool _canOpenMediaPath(String? path) {
    final String normalized = (path ?? '').trim();
    if (normalized.isEmpty) {
      return false;
    }
    return _shouldUseUrlMedia(normalized) || _hasLocalFile(normalized);
  }

  bool _hasLocalFile(String path) {
    if (kIsWeb || path.trim().isEmpty || _shouldUseUrlMedia(path)) {
      return false;
    }
    try {
      return File(path).existsSync();
    } catch (_) {
      return false;
    }
  }

  Future<void> _openExternalUrl(String rawUrl) async {
    final bool launched = await _tryOpenExternalUrl(rawUrl);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open this location.')),
      );
    }
  }

  Future<bool> _tryOpenExternalUrl(String rawUrl) async {
    final Uri? uri = Uri.tryParse(rawUrl.trim());
    if (uri == null) {
      return false;
    }
    return _tryOpenUri(uri);
  }

  Future<bool> _tryOpenUri(Uri uri) async {
    try {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  bool _isImagePath(String? path) {
    final String normalized = (path ?? '').trim().toLowerCase();
    if (normalized.isEmpty) {
      return false;
    }
    return normalized.endsWith('.png') ||
        normalized.endsWith('.jpg') ||
        normalized.endsWith('.jpeg') ||
        normalized.endsWith('.webp') ||
        normalized.endsWith('.gif');
  }

  bool _isVideoPath(String? path) {
    final String normalized = (path ?? '').trim().toLowerCase();
    if (normalized.isEmpty) {
      return false;
    }
    return normalized.endsWith('.mp4') ||
        normalized.endsWith('.mov') ||
        normalized.endsWith('.m4v') ||
        normalized.endsWith('.webm');
  }

  String _buildVoiceFilePath() {
    if (kIsWeb) {
      return 'voice_${DateTime.now().microsecondsSinceEpoch}.m4a';
    }
    final String separator = Platform.pathSeparator;
    return '${Directory.systemTemp.path}${separator}voice_${DateTime.now().microsecondsSinceEpoch}.m4a';
  }

  String _uploadResourceType(String kind, String path) {
    final String normalizedKind = kind.trim().toLowerCase();
    if (normalizedKind == 'gallery' ||
        normalizedKind == 'camera' ||
        normalizedKind == 'image' ||
        normalizedKind == 'photo') {
      return 'image';
    }
    if (normalizedKind == 'audio' || normalizedKind == 'voice') {
      return 'auto';
    }
    if (normalizedKind == 'video' || _isVideoPath(path)) {
      return 'video';
    }
    if (normalizedKind == 'document' || normalizedKind == 'file') {
      return 'raw';
    }
    return 'auto';
  }

  String? _inferMimeType(String path, String kind) {
    final String normalizedKind = kind.trim().toLowerCase();
    final String lowerPath = path.trim().toLowerCase();
    if (normalizedKind == 'gallery' ||
        normalizedKind == 'camera' ||
        normalizedKind == 'image' ||
        normalizedKind == 'photo') {
      if (lowerPath.endsWith('.png')) {
        return 'image/png';
      }
      if (lowerPath.endsWith('.webp')) {
        return 'image/webp';
      }
      return 'image/jpeg';
    }
    if (normalizedKind == 'audio' || normalizedKind == 'voice') {
      if (lowerPath.endsWith('.mp3')) {
        return 'audio/mpeg';
      }
      if (lowerPath.endsWith('.wav')) {
        return 'audio/wav';
      }
      return 'audio/mp4';
    }
    if (normalizedKind == 'video' || _isVideoPath(path)) {
      return 'video/mp4';
    }
    if (lowerPath.endsWith('.pdf')) {
      return 'application/pdf';
    }
    if (lowerPath.endsWith('.doc')) {
      return 'application/msword';
    }
    if (lowerPath.endsWith('.docx')) {
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    }
    if (lowerPath.endsWith('.txt')) {
      return 'text/plain';
    }
    if (lowerPath.endsWith('.xls')) {
      return 'application/vnd.ms-excel';
    }
    if (lowerPath.endsWith('.xlsx')) {
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    }
    if (lowerPath.endsWith('.ppt')) {
      return 'application/vnd.ms-powerpoint';
    }
    if (lowerPath.endsWith('.pptx')) {
      return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
    }
    return null;
  }

  double _mapAmplitudeToHeight(double amplitude) {
    final double safeAmplitude = amplitude.isFinite ? amplitude : -60;
    final double normalized = ((safeAmplitude + 60) / 60).clamp(0.0, 1.0);
    return 6 + (normalized * 16);
  }

  String _fileName(String path) {
    final String normalized = path.replaceAll('\\', '/');
    return normalized.split('/').last;
  }
}
