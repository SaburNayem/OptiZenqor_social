import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../core/common_widget/empty_state_view.dart';
import '../../post_detail/screen/post_detail_screen.dart';
import '../../saved_collections/model/saved_collection_model.dart';
import '../controller/bookmarks_controller.dart';
import '../model/bookmark_item_model.dart';
import '../widget/saved_collection_tile.dart';
import '../widget/saved_post_list_card.dart';
import 'saved_collection_posts_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookmarksController, BookmarksState>(
      builder: (context, state) {
        final BookmarksController controller = context.read<BookmarksController>();
        final List<BookmarkItemModel> items = state.items;

        return Scaffold(
          appBar: AppBar(title: const Text('Saved Posts')),
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _createCollection(context, controller),
                        icon: const Icon(Icons.create_new_folder_outlined),
                        label: const Text('New Collection'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Folders',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 190,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          SavedCollectionTile(
                            title: 'All Posts',
                            count: items.length,
                            previews: items
                                .map((BookmarkItemModel item) => item.thumbnail)
                                .where((String preview) => preview.isNotEmpty)
                                .take(4)
                                .toList(growable: false),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const SavedCollectionPostsScreen(
                                  title: 'All Posts',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ...state.collections.map(
                            (SavedCollectionModel collection) {
                              final List<BookmarkItemModel> collectionItems =
                                  controller.itemsForCollection(collection.id);
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: SavedCollectionTile(
                                  title: collection.name,
                                  count: collectionItems.length,
                                  previews: collectionItems
                                      .map(
                                        (BookmarkItemModel item) => item.thumbnail,
                                      )
                                      .where(
                                        (String preview) => preview.isNotEmpty,
                                      )
                                      .take(4)
                                      .toList(growable: false),
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          SavedCollectionPostsScreen(
                                        collectionId: collection.id,
                                        title: collection.name,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'All Saved Posts',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (items.isEmpty)
                      const EmptyStateView(
                        title: 'No saved posts yet',
                        message: 'Saved posts from the feed will appear here.',
                      )
                    else
                      ...items.map(
                        (BookmarkItemModel item) => SavedPostListCard(
                          item: item,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => PostDetailScreen(postId: item.id),
                            ),
                          ),
                          onMoreTap: () => _showPostActions(
                            context: context,
                            controller: controller,
                            item: item,
                          ),
                        ),
                      ),
                  ],
                ),
        );
      },
    );
  }

  Future<void> _createCollection(
    BuildContext context,
    BookmarksController controller,
  ) async {
    final TextEditingController textController = TextEditingController();
    final String? name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('New Collection'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(hintText: 'Folder name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(textController.text.trim()),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
    if (name == null || name.trim().isEmpty) {
      return;
    }
    await controller.createCollection(name);
    if (!context.mounted) {
      return;
    }
    AppGet.snackbar('Saved posts', 'Collection created');
  }

  Future<void> _showPostActions({
    required BuildContext context,
    required BookmarksController controller,
    required BookmarkItemModel item,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.bookmark_remove_outlined),
                title: const Text('Unsave post'),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await controller.unsave(item.id);
                  if (!context.mounted) {
                    return;
                  }
                  AppGet.snackbar('Saved posts', 'Post removed from saved');
                },
              ),
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: const Text('Report'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  AppGet.snackbar('Reported', 'Static report flow opened');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
