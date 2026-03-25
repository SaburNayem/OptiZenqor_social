import 'package:flutter/material.dart';

import '../controller/follow_controller.dart';

class FollowListScreen extends StatelessWidget {
  FollowListScreen({super.key}) {
    _controller.init();
  }

  final FollowController _controller = FollowController();

  @override
  Widget build(BuildContext context) {
    final currentUser = _controller.currentUser();
    return Scaffold(
      appBar: AppBar(title: const Text('Connections')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final followers = _controller.followers(currentUser.id);
          final following = _controller.following(currentUser.id);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Followers (${followers.length})',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...followers.map(
                (user) => ListTile(
                  leading: CircleAvatar(backgroundImage: NetworkImage(user.avatar)),
                  title: Text(user.name),
                  subtitle: Text('@${user.username}'),
                  trailing: TextButton(
                    onPressed: () => _controller.toggleFollow(user),
                    child: const Text('Remove'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Following (${following.length})',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...following.map(
                (user) => ListTile(
                  leading: CircleAvatar(backgroundImage: NetworkImage(user.avatar)),
                  title: Text(user.name),
                  subtitle: Text('@${user.username}'),
                  trailing: TextButton(
                    onPressed: () => _controller.toggleFollow(user),
                    child: const Text('Unfollow'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
