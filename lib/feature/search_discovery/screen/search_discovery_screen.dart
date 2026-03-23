import 'package:flutter/material.dart';

import '../controller/search_discovery_controller.dart';

class SearchDiscoveryScreen extends StatefulWidget {
  const SearchDiscoveryScreen({super.key});

  @override
  State<SearchDiscoveryScreen> createState() => _SearchDiscoveryScreenState();
}

class _SearchDiscoveryScreenState extends State<SearchDiscoveryScreen> {
  final SearchDiscoveryController _controller = SearchDiscoveryController();
  final TextEditingController _queryController = TextEditingController();

  static const List<String> _hashtagTabs = <String>['Top', 'Latest'];

  @override
  void dispose() {
    _queryController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search & Discovery')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _queryController,
                  onChanged: _controller.search,
                  decoration: const InputDecoration(
                    hintText: 'Search users, creators, posts, hashtags',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: SearchEntityFilter.values.map((filter) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(filter.name),
                        selected: _controller.activeFilter == filter,
                        onSelected: (_) => _controller.setFilter(
                          filter,
                          currentQuery: _queryController.text,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      'Trending Search Terms',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _controller.trendingTerms
                          .map((term) => Chip(label: Text(term)))
                          .toList(),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Suggestions by Entity Type',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _controller
                          .suggestionsForActiveFilter()
                          .map(
                            (item) => ActionChip(
                              label: Text(item),
                              onPressed: () {
                                _queryController.text = item;
                                _controller.search(item);
                              },
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    ..._controller.userResults.map(
                      (item) => Card(
                        child: ListTile(
                          onTap: () {
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${item.name} public profile preview opened',
                                  ),
                                ),
                              );
                          },
                          leading: CircleAvatar(
                            child: Text(item.name.substring(0, 1)),
                          ),
                          title: Text(item.name),
                          subtitle: Text('@${item.username} • ${item.role.name}'),
                          trailing: item.verified
                              ? const Icon(Icons.verified_rounded)
                              : null,
                        ),
                      ),
                    ),
                    ..._controller.mediaResults.map(
                      (item) => Card(
                        child: ListTile(
                          title: Text(item.caption),
                          subtitle: Text(
                            '${item.location ?? 'No location'} • ${item.viewCount} views • ${item.audience}',
                          ),
                          trailing: const Icon(Icons.photo_library_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _SectionCard(
                      title: 'Hashtag Detail',
                      subtitle: '#creatoreconomy with top/latest tabs',
                      child: Wrap(
                        spacing: 8,
                        children: _hashtagTabs
                            .map((tab) => Chip(label: Text(tab)))
                            .toList(),
                      ),
                    ),
                    _SectionCard(
                      title: 'Recommendation Feedback',
                      subtitle: 'Controls for tuning what the system shows next',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: const [
                          Chip(label: Text('Show less like this')),
                          Chip(label: Text('Hide creator')),
                          Chip(label: Text('Hide topic')),
                          Chip(label: Text('Improve recommendations')),
                          Chip(label: Text('Why am I seeing this?')),
                        ],
                      ),
                    ),
                    _SectionCard(
                      title: 'Explore Sections',
                      subtitle: 'Expanded discovery surfaces',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: const [
                          Chip(label: Text('Creator Spotlight')),
                          Chip(label: Text('Rising Communities')),
                          Chip(label: Text('Trending Products')),
                          Chip(label: Text('Trending Jobs')),
                          Chip(label: Text('Suggested Pages')),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(subtitle),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
