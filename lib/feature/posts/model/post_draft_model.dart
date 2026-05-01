class PostDraftModel {
  const PostDraftModel({
    required this.id,
    required this.title,
    required this.createdAt,
    this.caption,
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final String? caption;

  factory PostDraftModel.fromMap(Map<String, dynamic> map) {
    return PostDraftModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? 'Untitled draft',
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
      caption: map['caption'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      if (caption != null) 'caption': caption,
    };
  }
}
