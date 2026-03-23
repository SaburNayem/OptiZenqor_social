class PageModel {
  const PageModel({required this.id, required this.name, required this.about, required this.posts, this.following = false});
  final String id;
  final String name;
  final String about;
  final List<String> posts;
  final bool following;
  PageModel copyWith({bool? following}) => PageModel(id: id, name: name, about: about, posts: posts, following: following ?? this.following);
}
