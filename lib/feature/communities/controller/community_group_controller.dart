import 'package:flutter/foundation.dart';

import '../model/community_group_model.dart';

class CommunityGroupController extends ChangeNotifier {
  CommunityGroupController({required CommunityGroupModel group}) : _group = group {
    _posts = group.posts;
    _members = group.members;
    _events = group.events;
  }

  CommunityGroupModel _group;
  List<CommunityPostModel> _posts = <CommunityPostModel>[];
  List<CommunityMemberModel> _members = <CommunityMemberModel>[];
  List<CommunityEventModel> _events = <CommunityEventModel>[];
  String _postFilter = 'Recent';
  CommunityMediaFilter _mediaFilter = CommunityMediaFilter.all;
  String _memberQuery = '';
  bool _notificationsEnabled = true;

  CommunityGroupModel get group => _group;
  String get postFilter => _postFilter;
  CommunityMediaFilter get mediaFilter => _mediaFilter;
  String get memberQuery => _memberQuery;
  bool get notificationsEnabled => _notificationsEnabled;

  List<CommunityPostModel> get posts {
    if (_postFilter == 'Popular') {
      final items = <CommunityPostModel>[..._posts];
      items.sort((a, b) => b.likes.compareTo(a.likes));
      return items;
    }
    if (_postFilter == 'Media only') {
      return _posts
          .where(
            (item) =>
                item.type == CommunityPostType.image ||
                item.type == CommunityPostType.video,
          )
          .toList(growable: false);
    }
    return _posts;
  }

  List<CommunityMediaItem> get mediaItems {
    final base = _posts
        .where((post) => post.mediaLabel != null)
        .map(
          (post) => CommunityMediaItem(
            id: post.id,
            label: post.mediaLabel!,
            isVideo: post.type == CommunityPostType.video,
            color: post.authorAccent,
          ),
        )
        .toList(growable: false);
    switch (_mediaFilter) {
      case CommunityMediaFilter.photos:
        return base.where((item) => !item.isVideo).toList(growable: false);
      case CommunityMediaFilter.videos:
        return base.where((item) => item.isVideo).toList(growable: false);
      case CommunityMediaFilter.all:
        return base;
    }
  }

  List<CommunityEventModel> get upcomingEvents =>
      _events.where((event) => event.status == 'Upcoming').toList(growable: false);
  List<CommunityEventModel> get ongoingEvents =>
      _events.where((event) => event.status == 'Ongoing').toList(growable: false);
  List<CommunityEventModel> get pastEvents =>
      _events.where((event) => event.status == 'Past').toList(growable: false);

  List<CommunityMemberModel> get admins =>
      _members.where((member) => member.role == CommunityRole.admin).toList(growable: false);
  List<CommunityMemberModel> get moderators => _members
      .where((member) => member.role == CommunityRole.moderator)
      .toList(growable: false);
  List<CommunityMemberModel> get topContributors =>
      _members.where((member) => member.topContributor).toList(growable: false);
  List<CommunityMemberModel> get visibleMembers {
    if (_memberQuery.trim().isEmpty) {
      return _members;
    }
    final query = _memberQuery.trim().toLowerCase();
    return _members
        .where((member) => member.name.toLowerCase().contains(query))
        .toList(growable: false);
  }

  void toggleJoin() {
    _group = _group.copyWith(joined: !_group.joined);
    notifyListeners();
  }

  void setPostFilter(String value) {
    _postFilter = value;
    notifyListeners();
  }

  void setMediaFilter(CommunityMediaFilter value) {
    _mediaFilter = value;
    notifyListeners();
  }

  void updateMemberQuery(String value) {
    _memberQuery = value;
    notifyListeners();
  }

  void toggleNotificationBell() {
    _notificationsEnabled = !_notificationsEnabled;
    notifyListeners();
  }

  void setNotificationLevel(CommunityNotificationLevel value) {
    _group = _group.copyWith(notificationLevel: value);
    notifyListeners();
  }

  void toggleSavePost(String id) {
    _posts = _posts
        .map((post) => post.id == id ? post.copyWith(saved: !post.saved) : post)
        .toList(growable: false);
    notifyListeners();
  }

  void togglePinPost(String id) {
    _posts = _posts
        .map((post) => post.id == id ? post.copyWith(pinned: !post.pinned) : post)
        .toList(growable: false);
    notifyListeners();
  }

  void toggleFollowMember(String id) {
    _members = _members
        .map(
          (member) => member.id == id
              ? member.copyWith(following: !member.following)
              : member,
        )
        .toList(growable: false);
    notifyListeners();
  }

  void toggleGoing(String id) {
    _events = _events
        .map((event) => event.id == id ? event.copyWith(going: !event.going) : event)
        .toList(growable: false);
    notifyListeners();
  }

  void updateGeneral({
    required String name,
    required String description,
    required String category,
  }) {
    _group = _group.copyWith(
      name: name.trim().isEmpty ? _group.name : name.trim(),
      description: description.trim().isEmpty ? _group.description : description.trim(),
      category: category.trim().isEmpty ? _group.category : category.trim(),
    );
    notifyListeners();
  }

  void updatePrivacy({
    required CommunityPrivacy privacy,
    required bool approvalRequired,
  }) {
    _group = _group.copyWith(
      privacy: privacy,
      approvalRequired: approvalRequired,
    );
    notifyListeners();
  }

  void updateFeatures({
    bool? events,
    bool? live,
    bool? polls,
    bool? marketplace,
    bool? chatRoom,
  }) {
    _group = _group.copyWith(
      allowEvents: events,
      allowLive: live,
      allowPolls: polls,
      allowMarketplace: marketplace,
      allowChatRoom: chatRoom,
    );
    notifyListeners();
  }

  void loadMorePosts() {
    final nextIndex = _posts.length + 1;
    _posts = <CommunityPostModel>[
      ..._posts,
      CommunityPostModel(
        id: 'extra_$nextIndex',
        authorName: 'New contributor $nextIndex',
        authorRole: CommunityRole.member,
        authorAccent: 0xFF26C6DA,
        timeLabel: 'Just now',
        content: 'Fresh group update $nextIndex with local mock pagination.',
        type: nextIndex.isEven ? CommunityPostType.image : CommunityPostType.text,
        likes: 18 + nextIndex,
        comments: 6,
        shares: 2,
        mediaLabel: nextIndex.isEven ? 'New upload' : null,
      ),
    ];
    notifyListeners();
  }
}
