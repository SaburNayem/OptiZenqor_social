class HashtagModel {
  const HashtagModel({required this.tag, required this.count});
  final String tag;
  final int count;

  factory HashtagModel.fromApiJson(Map<String, dynamic> json) {
    return HashtagModel(
      tag: (json['tag'] ?? '').toString().trim(),
      count: _readInt(json['count']),
    );
  }

  static int _readInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
