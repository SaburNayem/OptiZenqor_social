import 'package:flutter/material.dart';

import '../controller/trending_controller.dart';
import '../model/trending_item_model.dart';

class TrendingScreen extends StatefulWidget {
  const TrendingScreen({super.key});

  @override
  State<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen> {
  late final TrendingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TrendingController()..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trending')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_controller.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      _controller.errorMessage!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _controller.load,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _controller.load,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                _TrendingSection(title: 'Posts', items: _controller.posts),
                _TrendingSection(
                  title: 'Hashtags',
                  items: _controller.hashtags,
                ),
                _TrendingSection(title: 'Reels', items: _controller.reels),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TrendingSection extends StatelessWidget {
  const _TrendingSection({required this.title, required this.items});

  final String title;
  final List<TrendingItemModel> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (items.isEmpty)
          const Card(child: ListTile(title: Text('Nothing trending yet'))),
        ...items.map(
          (item) => Card(
            child: ListTile(
              title: Text(item.title),
              subtitle: Text('Score ${item.score}'),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
