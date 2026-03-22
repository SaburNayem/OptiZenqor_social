class LocalStorageService {
  final Map<String, dynamic> _cache = <String, dynamic>{};

  T? read<T>(String key) => _cache[key] as T?;

  Future<void> write(String key, dynamic value) async {
    _cache[key] = value;
  }
}
