import 'package:flutter/material.dart';

import '../model/community_group_model.dart';
import 'community_group_screen.dart';

class CommunitiesScreen extends StatefulWidget {
  const CommunitiesScreen({
    this.showJoinedFirst = false,
    this.title = 'Communities',
    super.key,
  });

  final bool showJoinedFirst;
  final String title;

  @override
  State<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen> {
  late List<CommunityGroupModel> _groups;
  late bool _showJoinedOnly;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _groups = _mockGroups();
    _showJoinedOnly = widget.showJoinedFirst;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _groups
        .where((group) {
          final matchesJoin = !_showJoinedOnly || group.joined;
          final matchesQuery =
              _query.trim().isEmpty ||
              group.name.toLowerCase().contains(_query.toLowerCase()) ||
              group.category.toLowerCase().contains(_query.toLowerCase());
          return matchesJoin && matchesQuery;
        })
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateCommunitySheet,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Create'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
        children: [
          TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Search communities',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ChoiceChip(
                label: const Text('Discover'),
                selected: !_showJoinedOnly,
                onSelected: (_) => setState(() => _showJoinedOnly = false),
              ),
              const SizedBox(width: 10),
              ChoiceChip(
                label: const Text('Joined'),
                selected: _showJoinedOnly,
                onSelected: (_) => setState(() => _showJoinedOnly = true),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SectionTitle('Featured communities'),
          const SizedBox(height: 12),
          SizedBox(
            height: 244,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _groups.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final group = _groups[index];
                return _FeaturedCommunityCard(
                  group: group,
                  onTap: () => _openGroup(group),
                  onJoinTap: () => _toggleJoin(group.id),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          _SectionTitle(_showJoinedOnly ? 'Your communities' : 'Browse all'),
          const SizedBox(height: 12),
          ...filtered.map(
            (group) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CommunityListTile(
                group: group,
                onTap: () => _openGroup(group),
                onJoinTap: () => _toggleJoin(group.id),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleJoin(String id) {
    setState(() {
      _groups = _groups
          .map(
            (group) =>
                group.id == id ? group.copyWith(joined: !group.joined) : group,
          )
          .toList(growable: false);
    });
  }

  Future<void> _openGroup(CommunityGroupModel group) async {
    final updated = await Navigator.of(context).push<CommunityGroupModel>(
      MaterialPageRoute(builder: (_) => CommunityGroupScreen(group: group)),
    );
    if (updated != null) {
      setState(() {
        _groups = _groups
            .map((item) => item.id == updated.id ? updated : item)
            .toList(growable: false);
      });
    }
  }

  Future<void> _showCreateCommunitySheet() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Create community',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Group name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isEmpty) {
                      return;
                    }
                    setState(() {
                      _groups = <CommunityGroupModel>[
                        CommunityGroupModel(
                          id: 'created_${DateTime.now().millisecondsSinceEpoch}',
                          name: name,
                          description: descriptionController.text.trim().isEmpty
                              ? 'A new local community created from the app drawer.'
                              : descriptionController.text.trim(),
                          privacy: CommunityPrivacy.private,
                          memberCount: 12,
                          coverColors: const <int>[0xFF2444FF, 0xFF59C3C3],
                          avatarColor: 0xFF2444FF,
                          tags: const <String>['New', 'Local', 'Social'],
                          rules: const <String>[
                            'Be respectful',
                            'Keep posts relevant',
                            'Use clear titles',
                          ],
                          createdLabel: 'Created today',
                          category: 'Custom',
                          location: 'Online',
                          links: const <String>['https://community.local'],
                          contactInfo: 'hello@community.local',
                          posts: const <CommunityPostModel>[],
                          events: const <CommunityEventModel>[],
                          members: const <CommunityMemberModel>[],
                          recentActivity: const <String>[
                            'Community created locally',
                          ],
                          pinnedPosts: const <CommunityPostModel>[],
                          announcements: const <CommunityPostModel>[],
                          trendingPosts: const <CommunityPostModel>[],
                          joined: true,
                        ),
                        ..._groups,
                      ];
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Create community'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FeaturedCommunityCard extends StatelessWidget {
  const _FeaturedCommunityCard({
    required this.group,
    required this.onTap,
    required this.onJoinTap,
  });

  final CommunityGroupModel group;
  final VoidCallback onTap;
  final VoidCallback onJoinTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 270,
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: group.coverColors
                    .map(Color.new)
                    .toList(growable: false),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AvatarBadge(group: group, radius: 24),
                  const Spacer(),
                  Text(
                    group.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${group.memberCount} members • ${group.category}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    group.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 92,
                      child: FilledButton(
                        onPressed: onJoinTap,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 44),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          group.joined ? 'Joined' : 'Join',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CommunityListTile extends StatelessWidget {
  const _CommunityListTile({
    required this.group,
    required this.onTap,
    required this.onJoinTap,
  });

  final CommunityGroupModel group;
  final VoidCallback onTap;
  final VoidCallback onJoinTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _AvatarBadge(group: group, radius: 26),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${group.memberCount} members • ${group.category}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      group.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 92,
                child: FilledButton(
                  onPressed: onJoinTap,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    group.joined ? 'Joined' : 'Join',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge({required this.group, required this.radius});

  final CommunityGroupModel group;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Color(group.avatarColor),
      child: Text(
        group.name.characters.first.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.8,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
    );
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
