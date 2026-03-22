import 'package:flutter/material.dart';

import '../../user_profile/screen/user_profile_screen.dart';
import '../controller/search_discovery_controller.dart';

class SearchDiscoveryScreen extends StatelessWidget {
  SearchDiscoveryScreen({super.key});

  final SearchDiscoveryController _controller = SearchDiscoveryController();

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
                  onChanged: _controller.search,
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
                    ..._controller.results.map(
                      (item) => Card(
                        child: ListTile(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => UserProfileScreen(userId: item.id),
                              ),
                            );
                          },
                          leading: CircleAvatar(backgroundImage: NetworkImage(item.avatar)),
                          title: Text(item.name),
                          subtitle: Text('@${item.username}'),
                        ),
                      ),
                    ),
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
