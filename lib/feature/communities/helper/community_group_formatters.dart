import '../model/community_group_model.dart';

String privacyLabel(CommunityPrivacy privacy) {
  switch (privacy) {
    case CommunityPrivacy.public:
      return 'Public';
    case CommunityPrivacy.private:
      return 'Private';
    case CommunityPrivacy.hidden:
      return 'Hidden';
  }
}

String notificationLabel(CommunityNotificationLevel level) {
  switch (level) {
    case CommunityNotificationLevel.all:
      return 'All posts';
    case CommunityNotificationLevel.highlights:
      return 'Highlights only';
    case CommunityNotificationLevel.off:
      return 'Off';
  }
}

String mediaFilterLabel(CommunityMediaFilter filter) {
  switch (filter) {
    case CommunityMediaFilter.all:
      return 'All';
    case CommunityMediaFilter.photos:
      return 'Photos';
    case CommunityMediaFilter.videos:
      return 'Videos';
  }
}
