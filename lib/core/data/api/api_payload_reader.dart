class ApiPayloadReader {
  ApiPayloadReader._();

  static const List<String> _defaultListKeys = <String>[
    'items',
    'results',
    'users',
    'accounts',
    'sessions',
    'history',
    'notifications',
    'threads',
    'messages',
    'collections',
    'bookmarks',
    'transactions',
    'ledger',
    'pages',
    'jobs',
    'applications',
    'companies',
    'applicants',
    'products',
    'blocked',
    'muted',
    'documents',
    'reels',
    'posts',
    'stories',
  ];

  static Map<String, dynamic>? readMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  static List<Map<String, dynamic>> readMapList(
    Map<String, dynamic> payload, {
    List<String> preferredKeys = const <String>[],
  }) {
    final List<Object?> candidates = <Object?>[
      payload,
      payload['data'],
      payload['result'],
      payload['payload'],
      payload['value'],
    ];

    for (final Object? candidate in candidates) {
      final List<Map<String, dynamic>> items = readMapListFromAny(
        candidate,
        preferredKeys: preferredKeys,
      );
      if (items.isNotEmpty) {
        return items;
      }
    }

    return const <Map<String, dynamic>>[];
  }

  static List<Map<String, dynamic>> readMapListFromAny(
    Object? value, {
    List<String> preferredKeys = const <String>[],
  }) {
    if (value is List) {
      return value
          .whereType<Object>()
          .map<Map<String, dynamic>>((Object item) {
            final Map<String, dynamic>? map = readMap(item);
            return map ?? const <String, dynamic>{};
          })
          .where((Map<String, dynamic> item) => item.isNotEmpty)
          .toList(growable: false);
    }

    final Map<String, dynamic>? map = readMap(value);
    if (map == null || map.isEmpty) {
      return const <Map<String, dynamic>>[];
    }

    for (final String key in <String>[...preferredKeys, ..._defaultListKeys]) {
      final List<Map<String, dynamic>> items = readMapListFromAny(map[key]);
      if (items.isNotEmpty) {
        return items;
      }
    }

    return const <Map<String, dynamic>>[];
  }

  static List<String> readStringList(Object? value) {
    if (value is List) {
      return value
          .map((Object? item) => item?.toString().trim() ?? '')
          .where((String item) => item.isNotEmpty)
          .toList(growable: false);
    }
    return const <String>[];
  }

  static int readInt(Object? value) {
    if (value is List) {
      return value.length;
    }
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double readDouble(Object? value) {
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? readDateTime(Object? value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static bool? readBool(Object? value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final String normalized = value.trim().toLowerCase();
      if (normalized == 'true' ||
          normalized == 'yes' ||
          normalized == 'active' ||
          normalized == 'enabled' ||
          normalized == 'verified') {
        return true;
      }
      if (normalized == 'false' ||
          normalized == 'no' ||
          normalized == 'inactive' ||
          normalized == 'disabled' ||
          normalized == 'unverified') {
        return false;
      }
    }
    return null;
  }

  static String readString(Object? value, {String fallback = ''}) {
    final String resolved = value?.toString().trim() ?? '';
    return resolved.isEmpty ? fallback : resolved;
  }
}
