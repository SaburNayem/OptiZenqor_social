import 'package:flutter/material.dart';

import '../../saved_collections/model/saved_collection_model.dart';
import '../controller/bookmarks_controller.dart';

Future<String?> showSavePostCollectionSheet({
  required BuildContext context,
  required BookmarksController controller,
  required Future<void> Function(String? collectionId) onSave,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) =>
        _SavePostCollectionSheet(controller: controller, onSave: onSave),
  );
}

class _SavePostCollectionSheet extends StatefulWidget {
  const _SavePostCollectionSheet({
    required this.controller,
    required this.onSave,
  });

  final BookmarksController controller;
  final Future<void> Function(String? collectionId) onSave;

  @override
  State<_SavePostCollectionSheet> createState() =>
      _SavePostCollectionSheetState();
}

class _SavePostCollectionSheetState extends State<_SavePostCollectionSheet> {
  late final TextEditingController _nameController;
  late List<SavedCollectionModel> _localCollections;
  String? _selectedCollectionId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _localCollections = List<SavedCollectionModel>.from(
      widget.controller.state.collections,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createCollection() async {
    final SavedCollectionModel? created = await widget.controller
        .createCollection(_nameController.text);
    if (created == null || !mounted) {
      return;
    }
    setState(() {
      _localCollections = List<SavedCollectionModel>.from(
        widget.controller.state.collections,
      );
      _selectedCollectionId = created.id;
      _nameController.clear();
    });
  }

  Future<void> _saveSelection() async {
    await widget.onSave(_selectedCollectionId);
    if (!mounted) {
      return;
    }
    final String selectedLabel =
        _localCollections
            .where(
              (SavedCollectionModel collection) =>
                  collection.id == _selectedCollectionId,
            )
            .firstOrNull
            ?.name ??
        'All Posts';
    Navigator.of(context).pop(selectedLabel);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 4,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Save post',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text('Choose a folder, or save it to All Posts only.'),
              const SizedBox(height: 16),
              _CollectionOptionTile(
                label: 'All Posts',
                selected: _selectedCollectionId == null,
                onTap: () {
                  setState(() {
                    _selectedCollectionId = null;
                  });
                },
              ),
              ..._localCollections.map(
                (SavedCollectionModel collection) => _CollectionOptionTile(
                  label: collection.name,
                  subtitle: '${collection.itemIds.length} saved posts',
                  selected: _selectedCollectionId == collection.id,
                  onTap: () {
                    setState(() {
                      _selectedCollectionId = collection.id;
                    });
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        hintText: 'New folder name',
                      ),
                      onSubmitted: (_) => _createCollection(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _createCollection,
                    child: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saveSelection,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CollectionOptionTile extends StatelessWidget {
  const _CollectionOptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });

  final String label;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Icon(
        selected
            ? Icons.check_circle_rounded
            : Icons.radio_button_unchecked_rounded,
      ),
      title: Text(label),
      subtitle: subtitle == null ? null : Text(subtitle!),
    );
  }
}
