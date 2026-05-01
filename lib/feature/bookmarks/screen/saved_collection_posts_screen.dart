import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/common_widget/empty_state_view.dart';
import '../../../core/navigation/app_get.dart';
import '../../post_detail/screen/post_detail_screen.dart';
import '../controller/bookmarks_controller.dart';
import '../model/bookmark_item_model.dart';
import '../widget/saved_post_list_card.dart';

class SavedCollectionPostsScreen extends StatelessWidget {
  const SavedCollectionPostsScreen({
    super.key,
    this.collectionId,
    required this.title,
  });

  final String? collectionId;
  final String title;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookmarksController, BookmarksState>(
      builder: (context, state) {
        final BookmarksController controller = context
            .read<BookmarksController>();
        final List<BookmarkItemModel> items = collectionId == null
            ? state.items
            : controller.itemsForCollection(collectionId!);

        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: items.isEmpty
              ? const EmptyStateView(
                  title: 'No saved posts',
                  message: 'This folder does not have any saved posts yet.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final BookmarkItemModel item = items[index];
                    return SavedPostListCard(
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
                    );
                  },
                ),
        );
      },
    );
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
