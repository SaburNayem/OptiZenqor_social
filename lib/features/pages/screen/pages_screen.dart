import 'package:flutter/material.dart';

import '../controller/pages_controller.dart';

class PagesScreen extends StatelessWidget {
  PagesScreen({super.key}) {
    _controller.load();
  }

  final PagesController _controller = PagesController();
  final TextEditingController _name = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pages')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _name,
                    decoration: const InputDecoration(hintText: 'Create page'),
                  ),
                ),
                IconButton(
                  onPressed: () => _controller.createPage(_name.text),
                  icon: const Icon(Icons.add_business_outlined),
                ),
              ],
            ),
            ..._controller.pages.map(
              (page) => Card(
                child: ListTile(
                  title: Text(page.name),
                  subtitle: Text(
                    '${page.about}\n'
                    'Category: ${page.category}\n'
                    'Posts: ${page.posts.length}\n'
                    '${page.reviewSummary}\n'
                    '${page.visitorPostsSummary}\n'
                    '${page.followersInsight}\n'
                    'Announcement-only posting • Subscriber/follower updates',
                  ),
                  trailing: FilledButton(
                    onPressed: () => _controller.toggleFollow(page.id),
                    child: Text(page.following ? 'Following' : page.actionButtonLabel),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
