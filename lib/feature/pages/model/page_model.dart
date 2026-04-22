class PageModel {
  const PageModel({
    required this.id,
    required this.name,
    required this.about,
    required this.posts,
    this.following = false,
    this.category = 'General',
    this.actionButtonLabel = 'Follow',
    this.reviewSummary = 'Audience reviews are available for page visitors.',
    this.visitorPostsSummary = 'Visitor posts are enabled for followers.',
    this.followersInsight = 'Page engagement is trending upward this week.',
    this.avatarUrl = '',
    this.coverUrl = '',
    this.followersCount = 0,
    this.likesCount = 0,
    this.verified = false,
    this.ownerId = '',
    this.location = 'Global',
    this.contactLabel = 'Message',
    this.highlights = const <String>[],
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
  final String avatarUrl;
  final String coverUrl;
  final int followersCount;
  final int likesCount;
  final bool verified;
  final String ownerId;
  final String location;
  final String contactLabel;
  final List<String> highlights;

  PageModel copyWith({
    bool? following,
    int? followersCount,
    List<String>? posts,
  }) => PageModel(
        id: id,
        name: name,
        about: about,
        posts: posts ?? this.posts,
        following: following ?? this.following,
        category: category,
        actionButtonLabel: actionButtonLabel,
        reviewSummary: reviewSummary,
        visitorPostsSummary: visitorPostsSummary,
        followersInsight: followersInsight,
        avatarUrl: avatarUrl,
        coverUrl: coverUrl,
        followersCount: followersCount ?? this.followersCount,
        likesCount: likesCount,
        verified: verified,
        ownerId: ownerId,
        location: location,
        contactLabel: contactLabel,
        highlights: highlights,
      );
}
