import 'package:flutter/material.dart';

class CommunitiesScreen extends StatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  State<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen> {
  static const List<_CommunityItem> _items = <_CommunityItem>[
    _CommunityItem(
      id: 'founders-circle',
      name: 'Founders Circle',
      description: 'Startup talks, product feedback, and growth notes.',
    ),
    _CommunityItem(
      id: 'creator-club',
      name: 'Creator Club',
      description: 'Short-form content ideas, trends, and brand collabs.',
    ),
    _CommunityItem(
      id: 'design-lab',
      name: 'Design Lab',
      description: 'UI critique, motion studies, and portfolio sharing.',
    ),
  ];

  final Set<String> _joinedIds = <String>{'creator-club'};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Communities')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Owner/Admin Moderation',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(label: Text('Pin announcement')),
                        Chip(label: Text('Approve join requests')),
                        Chip(label: Text('Remove member')),
                        Chip(label: Text('Assign group role')),
                        Chip(label: Text('Mute member')),
                        Chip(label: Text('Rule management')),
                        Chip(label: Text('Broadcast channel placeholder')),
                        Chip(label: Text('One-to-many updates feed')),
                        Chip(label: Text('Follow/join channel')),
                        Chip(label: Text('Channel reactions')),
                        Chip(label: Text('Announcement-only posting')),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
          final item = _items[index - 1];
          final joined = _joinedIds.contains(item.id);
          return Card(
            child: ListTile(
              title: Text(item.name),
              subtitle: Text('${item.description}\nRising community placeholder'),
              trailing: FilledButton(
                onPressed: () {
                  setState(() {
                    if (joined) {
                      _joinedIds.remove(item.id);
                    } else {
                      _joinedIds.add(item.id);
                    }
                  });
                  final label = joined ? 'Left ${item.name}' : 'Joined ${item.name}';
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text(label)));
                },
                child: Text(joined ? 'Joined' : 'Join'),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CommunityItem {
  const _CommunityItem({
    required this.id,
    required this.name,
    required this.description,
  });

  final String id;
  final String name;
  final String description;
}
