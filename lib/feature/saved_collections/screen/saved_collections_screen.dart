import 'package:flutter/material.dart';

import '../controller/saved_collections_controller.dart';

class SavedCollectionsScreen extends StatefulWidget {
  const SavedCollectionsScreen({super.key});

  @override
  State<SavedCollectionsScreen> createState() => _SavedCollectionsScreenSta  State<SavedCollectionsScreen> createState() => _SavedCollectionsScreenSta  State<SavedCollectionsScreen> createState() => _SavedCollectionsScreenSta  State<SavedCollectionsScreen> createState() => _SavedCollectionsScreenSta  State<SavedCollectionsScreen> createState() => _SavedCollectionsScreenSta  State<SavedCollectionsScreen> createState() => _SavedCollectionsScreenSta  State<SavedCollectionsScreen> createState() => _SavedCollectionsScreenSta  State<SavedCollectionsScreen> createState() => _SavedCollectionsScreenSta  State<SavedCollectionsScreen> createState() => _SavedCollectionsScreenSta  State<SavedCollectionsScreen> createState() => _Save TextField(controller: _name, decoration: const InputDecoration(hintText: 'Collection name'))), IconButton(onPressed: () => _controller.create(_name.text), icon: const Icon(Icons.create_new_folder_outlined))]),
            ..._controller.collections.map((c) => Card(child: ListTile(title: Text(c.name), subtitle: Text('Items: ${c.itemIds.join(', ')}'), trailing: IconButton(onPressed: c.itemIds.isEmpty ? null : () => _controller.remove(c.id, c.itemIds.last), icon: const Icon(Icons.remove_circle_outline))))),
          ],
        ),
      ),
    );
  }
}
