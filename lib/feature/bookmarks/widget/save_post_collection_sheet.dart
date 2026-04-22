import 'package:flutter/material.dart';

import '../../saved_collections/model/saved_collection_model.dart';
import '../controller/bookmarks_controller.dart';

Future<String?> showSavePostCollectionSheet({
  required BuildContext context,
  required BookmarksController controller,
  required Future<void> Function(String? collectionId) onSave,
}) {
  final TextEditingController nameController = TextEditingController();
  List<SavedCollectionModel> localCollections =
      List<SavedCollectionModel>.from(controller.state.collections);
  String? selectedCollectionId;

  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          Future<void> createCollection() async {
            final SavedCollectionModel? created = await controller
                .createCollection(nameController.text);
            if (created == null) {
              return;
            }
            setSheetState(() {
              localCollections = List<SavedCollectionModel>.from(
                controller.state.collections,
              );
              selectedCollectionId = created.id;
              nameController.clear();
            });
          }

          Future<void> saveSelection() async {
            await onSave(selectedCollectionId);
            if (!sheetContext.mounted) {
              return;
            }
            final String selectedLabel = localCollections
                    .where(
                      (SavedCollectionModel collection) =>
                          collection.id == selectedCollectionId,
                    )
                    .firstOrNull
                    ?.name ??
                'All Posts';
            Navigator.of(sheetContext).pop(selectedLabel);
          }

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 4,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Save post',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Choose a folder, or save it to All Posts only.',
                  ),
                  const SizedBox(height: 16),
                  _CollectionOptionTile(
                    label: 'All Posts',
                    selected: selectedCollectionId == null,
                    onTap: () {
                      setSheetState(() {
                        selectedCollectionId = null;
                      });
                    },
                  ),
                  ...localCollections.map(
                    (SavedCollectionModel collection) => _CollectionOptionTile(
                      label: collection.name,
                      subtitle: '${collection.itemIds.length} saved posts',
                      selected: selectedCollectionId == collection.id,
                      onTap: () {
                        setSheetState(() {
                          selectedCollectionId = collection.id;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            hintText: 'New folder name',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: createCollection,
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: saveSelection,
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
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
