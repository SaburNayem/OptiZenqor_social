import 'package:flutter/material.dart';

import '../controller/saved_collections_controller.dart';

class SavedCollectionsScreen extends StatefulWidget {
  const SavedCollectionsScreen({super.key});

  @override
  State<SavedCollectionsScreen> createState() => _SavedCollectionsScreenState();
}

class _SavedCollectionsScreenState extends State<SavedCollectionsScreen> {
  final SavedCollectionsController _controller = SavedCollectionsController();
  final TextEditingController _name = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  @override
  void dispose() {
    _name.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Collections')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _name,
                    decoration: const InputDecoration(
                      hintText: 'Collection name',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await _controller.create(_name.text);
                    _name.clear();
                  },
                  icon: const Icon(Icons.create_new_folder_outlined),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_controller.collections.isEmpty)
              const Card(
                child: ListTile(
                  title: Text('No collections yet'),
                  subtitle: Text('Create one to organize saved items.'),
                ),
              ),
            ..._controller.collections.map(
              (collection) => Card(
                child: ListTile(
                  title: Text(collection.name),
                  subtitle: Text(
                    collection.itemIds.isEmpty
                        ? 'No saved items'
                        : 'Items: ${collection.itemIds.join(', ')}',
                  ),
                  trailing: IconButton(
                    onPressed: collection.itemIds.isEmpty
                        ? null
                        : () => _controller.remove(
                              collection.id,
                              collection.itemIds.last,
                            ),
                    icon: const Icon(Icons.remove_circle_outline),
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
