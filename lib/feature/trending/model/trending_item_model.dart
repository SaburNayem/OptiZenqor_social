class TrendingItemModel {
  const TrendingItemModel({
    required this.title,
    required this.type,
    required this.score,
  });

  final String title;
  final String type;
  final int score;

  factory TrendingItemModel.fromApiJson(Map<String, dynamic> json) {
    return TrendingItemModel(
      title: (json['title'] ?? json['tag'] ?? '').toString().trim(),
      type: (json['type'] ?? 'item').toString().trim().toLowerCase(),
      score: _readInt(json['score'] ?? json['count']),
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
