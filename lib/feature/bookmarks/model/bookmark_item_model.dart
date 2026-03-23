enum BookmarkType { post, reel, product }

class BookmarkItemModel {
  const BookmarkItemModel({required this.id, required this.title, required this.type});

  final String id;
  final String title;
  final BookmarkType type;
}
