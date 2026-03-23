import 'package:flutter/foundation.dart';

import '../model/hashtag_model.dart';
import '../repository/hashtags_repository.dart';

class HashtagsController extends ChangeNotifier {
  HashtagsController({HashtagsRepository? repository}) : _repository = repository ?? HashtagsRepository();
  final HashtagsRepository _repository;
  final HashtagsRepository _repository;
? repository}) : _repositovis? repository}) : _repositovis? repository}) : _repositovis? repository}) : _repositovis? repository}) : _repositovis? repository}) : _repositovis? repository}) : _repositovis? repository})re? repository}) : _repositovis? repository}) : _repositovis? repository}) : _repositovis? repository}) : _repositovis? repository}) : _repositovis? repository}) : _repositovis? repository}) : _repositovis? repository})re? repository}) : _repositovis? repository}) : _repositovis? repository}) : _repositovis? repository}) : _repositovis? repository}) : _repositovishtags_screen.dart <<'EOF'
import 'package:flutter/material.dart';

import '../controller/hashtags_controller.dart';

class HashtagsScreen extends StatelessWidget {
  HashtagsScreen({super.key}) { _controller.load(); }
  final HashtagsController _controller = HashtagsController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hashtags')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(onChanged: _controller.search, decoration: const InputDecoration(hintText: 'Search hashtags')),
            const SizedBox(height: 8),
            ..._controller.visible.map((h) => Card(child: ListTile(title: Text(h.tag), subtitle: Text('${h.count} posts')))),
          ],
        ),
      ),
    );
  }
}
