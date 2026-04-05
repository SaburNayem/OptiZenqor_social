import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../controller/saved_collections_controller.dart';

class SavedCollectionsScreen extends StatelessWidget {
  const SavedCollectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SavedCollectionsController>(
      create: (_) => SavedCollectionsController()..load(),
      child: BlocBuilder<SavedCollectionsController, SavedCollectionsState>(
        builder: (context, state) {
          final controller = context.read<SavedCollectionsController>();
          return Scaffold(
            appBar: AppBar(title: const Text('Saved Collections')),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        key: ValueKey(state.draftName),
                        initialValue: state.draftName,
                        onChanged: controller.updateDraftName,
                        decoration: const InputDecoration(
                          hintText: 'Collection name',
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await controller.create(state.draftName);
                      },
                      icon: const Icon(Icons.create_new_folder_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (state.collections.isEmpty)
                  const Card(
                    child: ListTile(
                      title: Text('No collections yet'),
                      subtitle: Text('Create one to organize saved items.'),
                    ),
                  ),
                ...state.collections.map(
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
                            : () => controller.remove(
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
          );
        },
      ),
    );
  }
}
