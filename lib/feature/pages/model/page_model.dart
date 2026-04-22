class PageModel {
  const PageModel({
    required this.id,
    required this.name,
    required this.about,
    required this.posts,
    this.following = false,
    this.category = 'General',
    this.actionButtonLabel = 'Follow',
    this.reviewSummary = 'Reviews placeholder',
    this.visitorPostsSummary = 'Visitor posts placeholder',
    this.followersInsight = 'Insights placeholder',
  });
  final String id;
  final String name;
  final String about;
  final List<String> posts;
  final bool following;
  final String category;
  final String actionButtonLabel;
  final String reviewSummary;
  final String visitorPostsSummary;
  final String followersInsight;

  PageModel copyWith({bool? following}) => PageModel(
        id: id,
        name: name,
        about: about,
        posts: posts,
        following: following ?? this.following,
        category: category,
        actionButtonLabel: actionButtonLabel,
        reviewSummary: reviewSummary,
        visitorPostsSummary: visitorPostsSummary,
        followersInsight: followersInsight,
      );
}
