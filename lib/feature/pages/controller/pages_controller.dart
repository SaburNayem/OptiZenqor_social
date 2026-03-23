import 'package:flutter/foundation.dart';

import '../model/page_model.dart';
import '../repository/pages_repository.dart';

classclassclassclassclassclassclasscNotclassclassclassclassclassclassclasscNotclassclassclassclassclassclassclasscNotclassclassclassclassclassclassclasscNotclassclassclassclassclassclassclasscNotclassclassclassclassclassclassclasscNotclassclassclassclassclassclassclasscNotclassclassclassclassclassclassclasscNotclassclassclassclassclassclassclasscNotclassclassclassclassclassclassclasscNotclassclassclassclassclassclassclasscNotclassclassclassclassclassclassclasscNotclassclassclassclassclassclapoclassclassclassclassclassclassclasscNotclassclassclassclassclassclassclasscNotclassclassclassclassclassclassclasscNotclassclassclassclassclassclassclasscNotclassclassclassclassclassclassclasscNotclassclassclassclassclassclassclasscNotclassclassclassclassclassclassclasscNotclassclassclassclassclassclassclasscNotclassclassclassclassclges_controller.dart';

class PagesScreen extends StatelessWidget {
  PagesScreen({super.key}) { _controller.load(); }
  final PagesController _controller = PagesController();
  final TextEditingController _name = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pages')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(children: [Expanded(child: TextField(controller: _name, decoration: const InputDecoration(hintText: 'Create page'))), IconButton(onPressed: () => _controller.createPage(_name.text), icon: const Icon(Icons.add_business_outlined))]),
            ..._controller.pages.map((p) => Card(child: ListTile(title: Text(p.name), subtitle: Text('${p.about}\nPosts: ${p.posts.length}'), trailing: FilledButton(onPressed: () => _controller.toggleFollow(p.id), child: Text(p.following ? 'Following' : 'Follow'))))),
          ],
        ),
      ),
    );
  }
}
