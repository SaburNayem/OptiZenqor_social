import 'package:flutter/material.dart';

import '../controller/trending_controller.dart';
import '../model/trending_item_model.dart';

class TrendingScreen extends StatelessWidget {
  TrendingScreen({super.key}) { _controller.load(); }
  final TrendingController _controller = TrendingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trending')),
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      rossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...items.map((item) => Card(child: ListTile(title: Text(item.title), subtitle: Text('Score ${item.score}')))),
        const SizedBox(height: 12),
      ],
    );
  }
}
