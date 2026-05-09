import '../../../core/data/api/api_payload_reader.dart';

class PageModel {
  const PageModel({
    required this.id,
    required this.name,
    required this.about,
    required this.posts,
    this.following = false,
    this.category = '',
    this.actionButtonLabel = '',
    this.reviewSummary = '',
    this.visitorPostsSummary = '',
    this.followersInsight = '',
    this.avatarUrl = '',
    this.coverUrl = '',
    this.followersCount = 0,
    this.likesCount = 0,
    this.verified = false,
    this.ownerId = '',
    this.location = '',
    this.contactLabel = '',
    this.shareUrl = '',
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
  final String shareUrl;
  final List<String> highlights;

  factory PageModel.fromApiJson(Map<String, dynamic> json) {
    return PageModel(
      id: ApiPayloadReader.readString(json['id']),
      name: ApiPayloadReader.readString(json['name']),
      about: ApiPayloadReader.readString(json['about'] ?? json['description']),
      posts: ApiPayloadReader.readStringList(
        json['posts'] ?? json['postTitles'],
      ),
      following:
          ApiPayloadReader.readBool(json['following'] ?? json['isFollowing']) ??
          false,
      category: ApiPayloadReader.readString(json['category']),
      actionButtonLabel: ApiPayloadReader.readString(json['actionButtonLabel']),
      reviewSummary: ApiPayloadReader.readString(json['reviewSummary']),
      visitorPostsSummary: ApiPayloadReader.readString(
        json['visitorPostsSummary'],
      ),
      followersInsight: ApiPayloadReader.readString(json['followersInsight']),
      avatarUrl: ApiPayloadReader.readString(
        json['avatarUrl'] ?? json['avatar'],
      ),
      coverUrl: ApiPayloadReader.readString(
        json['coverUrl'] ?? json['coverImageUrl'],
      ),
      followersCount: ApiPayloadReader.readInt(json['followersCount']),
      likesCount: ApiPayloadReader.readInt(json['likesCount']),
      verified:
          ApiPayloadReader.readBool(json['verified'] ?? json['isVerified']) ??
          false,
      ownerId: ApiPayloadReader.readString(json['ownerId'] ?? json['userId']),
      location: ApiPayloadReader.readString(json['location']),
      contactLabel: ApiPayloadReader.readString(
        json['contactLabel'] ?? json['primaryActionLabel'],
      ),
      shareUrl: ApiPayloadReader.readString(
        json['shareUrl'] ?? json['shareLink'] ?? json['url'],
      ),
      highlights: ApiPayloadReader.readStringList(json['highlights']),
    );
  }

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
    shareUrl: shareUrl,
    highlights: highlights,
  );
}
