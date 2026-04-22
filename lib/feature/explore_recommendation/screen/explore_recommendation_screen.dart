import 'package:flutter/material.dart';

import '../controller/explore_recommendation_controller.dart';

class ExploreRecommendationScreen extends StatelessWidget {
  const ExploreRecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ExploreRecommendationController();

    return Scaffold(
      appBar: AppBar(title: const Text('Explore Recommendations')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.items.length,
        itemBuilder: (context, index) {
          final item = controller.items[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.auto_awesome_rounded),
              title: Text(item.title),
              subtitle: Text(item.subtitle),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
          );
        },
      ),
    );
  }
}
