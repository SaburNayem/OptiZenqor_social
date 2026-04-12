import '../../model/community_group_model.dart';

class CommunityMockDataSource {
  Future<List<CommunityGroupModel>> loadGroups() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return _mockGroups();
  }
}

List<CommunityGroupModel> _mockGroups() {
  const members = <CommunityMemberModel>[
    CommunityMemberModel(
      id: 'm1',
      name: 'Sadia Rahman',
      role: CommunityRole.admin,
      accentColor: 0xFF3B82F6,
      topContributor: true,
    ),
    CommunityMemberModel(
      id: 'm2',
      name: 'Riyad Khan',
      role: CommunityRole.moderator,
      accentColor: 0xFF10B981,
      topContributor: true,
    ),
    CommunityMemberModel(
      id: 'm3',
      name: 'Maya Quinn',
      role: CommunityRole.member,
      accentColor: 0xFFF97316,
    ),
    CommunityMemberModel(
      id: 'm4',
      name: 'Noor Alam',
      role: CommunityRole.member,
      accentColor: 0xFF8B5CF6,
    ),
  ];

  const posts = <CommunityPostModel>[
    CommunityPostModel(
      id: 'p1',
      authorName: 'Sadia Rahman',
      authorRole: CommunityRole.admin,
      authorAccent: 0xFF3B82F6,
      timeLabel: '2h ago',
      content:
          'Welcome to the weekly build sprint. Share wins, blockers, and screenshots.',
      type: CommunityPostType.text,
      likes: 124,
      comments: 28,
      shares: 9,
      highlight: true,
      pinned: true,
    ),
    CommunityPostModel(
      id: 'p2',
      authorName: 'Riyad Khan',
      authorRole: CommunityRole.moderator,
      authorAccent: 0xFF10B981,
      timeLabel: '4h ago',
      content: 'Uploaded the community moodboard pack for this month.',
      type: CommunityPostType.image,
      likes: 92,
      comments: 14,
      shares: 5,
      mediaLabel: 'Moodboard pack',
    ),
    CommunityPostModel(
      id: 'p3',
      authorName: 'Maya Quinn',
      authorRole: CommunityRole.member,
      authorAccent: 0xFFF97316,
      timeLabel: 'Yesterday',
      content: 'Should we run a live critique session on Saturday evening?',
      type: CommunityPostType.poll,
      likes: 78,
      comments: 31,
      shares: 3,
      pollOptions: <String>['Yes', 'No', 'Maybe later'],
    ),
    CommunityPostModel(
      id: 'p4',
      authorName: 'Noor Alam',
      authorRole: CommunityRole.member,
      authorAccent: 0xFF8B5CF6,
      timeLabel: 'Yesterday',
      content: 'Highlights from our remote workshop are now live for replay.',
      type: CommunityPostType.video,
      likes: 146,
      comments: 22,
      shares: 16,
      mediaLabel: 'Workshop replay',
    ),
    CommunityPostModel(
      id: 'p5',
      authorName: 'Sadia Rahman',
      authorRole: CommunityRole.admin,
      authorAccent: 0xFF3B82F6,
      timeLabel: '3d ago',
      content: 'Next meetup: Product systems and creator monetization.',
      type: CommunityPostType.event,
      likes: 63,
      comments: 12,
      shares: 11,
      highlight: true,
    ),
  ];

  const events = <CommunityEventModel>[
    CommunityEventModel(
      id: 'e1',
      title: 'Creator Growth Roundtable',
      dateLabel: 'Apr 18 • 8:30 PM',
      locationLabel: 'Online',
      coverColor: 0xFF2563EB,
      status: 'Upcoming',
    ),
    CommunityEventModel(
      id: 'e2',
      title: 'Live Portfolio Reviews',
      dateLabel: 'Now live',
      locationLabel: 'Community Stage',
      coverColor: 0xFF9333EA,
      status: 'Ongoing',
      going: true,
    ),
    CommunityEventModel(
      id: 'e3',
      title: 'Launch Checklist Sprint',
      dateLabel: 'Apr 1 • 7:00 PM',
      locationLabel: 'Dhaka Hub',
      coverColor: 0xFF059669,
      status: 'Past',
    ),
  ];

  return <CommunityGroupModel>[
    CommunityGroupModel(
      id: 'c1',
      name: 'Creator Circle',
      description:
          'A premium space for designers, creators, and founders to share work, events, and live sessions.',
      privacy: CommunityPrivacy.public,
      memberCount: 18420,
      coverColors: const <int>[0xFF0F172A, 0xFF2563EB, 0xFF22D3EE],
      avatarColor: 0xFF2563EB,
      tags: const <String>['Design', 'Creator Economy', 'Live Sessions'],
      rules: const <String>[
        'Respect each member',
        'Keep posts relevant to the community',
        'No spam or repetitive promotion',
      ],
      createdLabel: 'Created on Jan 12, 2023',
      category: 'Design & Creator',
      location: 'Global / Online',
      links: const <String>[
        'creatorcircle.local/join',
        'creatorcircle.local/resources',
      ],
      contactInfo: 'mods@creatorcircle.local',
      posts: posts,
      events: events,
      members: members,
      recentActivity: const <String>[
        'Raisa joined the community 10 min ago',
        'Noor posted a workshop recap 35 min ago',
        'Maya started a poll 1 h ago',
      ],
      pinnedPosts: <CommunityPostModel>[posts[0]],
      announcements: <CommunityPostModel>[posts[4]],
      trendingPosts: <CommunityPostModel>[posts[1], posts[3]],
      joined: true,
    ),
    CommunityGroupModel(
      id: 'c2',
      name: 'Startup Builders',
      description:
          'Growth notes, founder accountability, and community-led events for early stage builders.',
      privacy: CommunityPrivacy.private,
      memberCount: 9200,
      coverColors: const <int>[0xFF111827, 0xFFEA580C, 0xFFF59E0B],
      avatarColor: 0xFFEA580C,
      tags: const <String>['Startup', 'Product', 'Growth'],
      rules: const <String>[
        'Be useful',
        'Share context',
        'Protect member privacy',
      ],
      createdLabel: 'Created on Jul 2, 2022',
      category: 'Startup',
      location: 'Asia',
      links: const <String>['startupbuilders.local/apply'],
      contactInfo: 'hello@startupbuilders.local',
      posts: posts,
      events: events,
      members: members,
      recentActivity: const <String>['Three new members joined today'],
      pinnedPosts: <CommunityPostModel>[posts[0]],
      announcements: <CommunityPostModel>[posts[4]],
      trendingPosts: <CommunityPostModel>[posts[3]],
    ),
    CommunityGroupModel(
      id: 'c3',
      name: 'Motion Lab',
      description:
          'Animation breakdowns, case studies, and curated references with critique-friendly feedback.',
      privacy: CommunityPrivacy.hidden,
      memberCount: 3510,
      coverColors: const <int>[0xFF0B1020, 0xFF6D28D9, 0xFFEC4899],
      avatarColor: 0xFF6D28D9,
      tags: const <String>['Motion', 'UI', 'Animation'],
      rules: const <String>[
        'Be specific in feedback',
        'Credit references',
        'Stay constructive',
      ],
      createdLabel: 'Created on Nov 8, 2021',
      category: 'Creative',
      location: 'Members only',
      links: const <String>['motionlab.local'],
      contactInfo: 'mods@motionlab.local',
      posts: posts,
      events: events,
      members: members,
      recentActivity: const <String>['Pinned a new challenge post'],
      pinnedPosts: <CommunityPostModel>[posts[0]],
      announcements: <CommunityPostModel>[posts[4]],
      trendingPosts: <CommunityPostModel>[posts[1]],
    ),
  ];
}
