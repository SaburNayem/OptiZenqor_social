import 'package:flutter/material.dart';

class SearchDiscoveryScreen extends StatefulWidget {
  const SearchDiscoveryScreen({super.key});

  @override
  State<SearchDiscoveryScreen> createState() => _SearchDiscoveryScreenState();
}

class _SearchDiscoveryScreenState extends State<SearchDiscoveryScreen> {
  static const List<_SearchResultItem> _allItems = <_SearchResultItem>[
    _SearchResultItem(name: 'Nexa Studio', username: 'nexa.studio'),
    _SearchResultItem(name: 'Aria Rahman', username: 'aria.rahman'),
    _SearchResultItem(name: 'Motion Grid', username: 'motion.grid'),
    _SearchResultItem(name: 'Mira Codes', username: 'mira.codes'),
  ];

  String _query = '';

  List<_SearchResultItem> get _results {
    final term = _query.trim().toLowerCase();
    if (term.isEmpty) {
      return _allItems;
    }
    return _allItems
        .where((item) =>
            item.name.toLowerCase().contains(term) ||
            item.username.toLowerCase().contains(term))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search & Discovery')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                hintText: 'Search users, creators, posts, hashtags',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const Wrap(
                  spacing: 8,
                  children: [
                    Chip(label: Text('Trending Now')),
                    Chip(label: Text('Creators')),
                    Chip(label: Text('Jobs')),
                    Chip(label: Text('Communities')),
                  ],
                ),
                const SizedBox(height: 14),
                ..._results.map(
                  (item) => Card(
                    child: ListTile(
                      onTap: () {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(content: Text('${item.name} is a static preview')),
                          );
                      },
                      leading: CircleAvatar(
                        child: Text(item.name.substring(0, 1)),
                      ),
                      title: Text(item.name),
                      subtitle: Text('@${item.username}'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultItem {
  const _SearchResultItem({
    required this.name,
    required this.username,
  });

  final String name;
  final String username;
}
