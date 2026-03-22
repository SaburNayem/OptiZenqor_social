import 'package:flutter/material.dart';

import '../controller/communities_controller.dart';

class CommunitiesScreen extends StatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  State<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen> {
  final CommunitiesController _controller = CommunitiesController();

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Communities')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          if (_controller.groups.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _controller.groups.length,
            itemBuilder: (context, index) {
              final item = _controller.groups[index];
              final joined = _controller.isJoined(item.id);
              return Card(
                child: ListTile(
                  title: Text(item.name),
                  subtitle: Text(item.description),
                  trailing: FilledButton(
                    onPressed: () {
                      _controller.toggleJoin(item.id);
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
          );
        },
      ),
    );
  }
}
