import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/data/models/post_model.dart';
import '../../../core/data/models/user_model.dart';
import '../../saved_collections/model/saved_collection_model.dart';
import '../../saved_collections/repository/saved_collections_repository.dart';
import '../model/bookmark_item_model.dart';
import '../repository/bookmarks_repository.dart';

class BookmarksState {
  const BookmarksState({
    this.items = const <BookmarkItemModel>[],
    this.collections = const <SavedCollectionModel>[],
    this.isLoading = false,
  });

  final List<BookmarkItemModel> items;
  final List<SavedCollectionModel> collections;
  final bool isLoading;

  BookmarksState copyWith({
    List<BookmarkItemModel>? items,
    List<SavedCollectionModel>? collections,
    bool? isLoading,
  }) {
    return BookmarksState(
      items: items ?? this.items,
      collections: collections ?? this.collections,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class BookmarksController extends Cubit<BookmarksState> {
  BookmarksController({
    BookmarksRepository? repository,
    SavedCollectionsRepository? collectionsRepository,
  }) : _repository = repository ?? BookmarksRepository(),
       _collectionsRepository =
           collectionsRepository ?? SavedCollectionsRepository(),
       super(const BookmarksState());

  final BookmarksRepository _repository;
  final SavedCollectionsRepository _collectionsRepository;

  bool isSaved(String postId) =>
      state.items.any((BookmarkItemModel item) => item.id == postId);

  BookmarkItemModel? itemById(String postId) {
    for (final BookmarkItemModel item in state.items) {
      if (item.id == postId) {
        return item;
      }
    }
    return null;
  }

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    final List<BookmarkItemModel> items = await _repository.read();
    final List<SavedCollectionModel> collections = await _collectionsRepository
        .read();
    emit(
      state.copyWith(
        items: _sortedItems(items),
        collections: collections,
        isLoading: false,
      ),
    );
  }

  void clearLocalState() {
    emit(const BookmarksState());
  }

  Future<SavedCollectionModel?> createCollection(String name) async {
    final String trimmed = name.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final SavedCollectionModel? existing = _collectionByName(trimmed);
    if (existing != null) {
      return existing;
    }

    final List<SavedCollectionModel> collections = await _collectionsRepository
        .create(trimmed);
    final SavedCollectionModel? collection = collections
        .where(
          (SavedCollectionModel item) =>
              item.name.toLowerCase() == trimmed.toLowerCase(),
        )
        .firstOrNull;
    if (collection == null) {
      return null;
    }
    emit(state.copyWith(collections: collections));
    return collection;
  }

  Future<void> savePost({
    required PostModel post,
    required UserModel author,
    String? collectionId,
  }) async {
    final BookmarkItemModel item = BookmarkItemModel.fromPost(
      post: post,
      author: author,
    );
    final List<BookmarkItemModel> items = <BookmarkItemModel>[
      item,
      ...state.items.where(
        (BookmarkItemModel current) => current.id != item.id,
      ),
    ];
    final List<SavedCollectionModel> collections = collectionId == null
        ? state.collections
        : _attachItemToCollection(
            collections: state.collections,
            collectionId: collectionId,
            itemId: item.id,
          );

    await _repository.add(item, items);
    if (collectionId != null) {
      await _collectionsRepository.addItem(collectionId, item.id);
    }
    emit(state.copyWith(items: _sortedItems(items), collections: collections));
  }

  Future<void> unsave(String postId) async {
    final List<BookmarkItemModel> items = state.items
        .where((BookmarkItemModel item) => item.id != postId)
        .toList(growable: false);
    final List<SavedCollectionModel> collections = state.collections
        .map(
          (SavedCollectionModel collection) => collection.copyWith(
            itemIds: collection.itemIds
                .where((String id) => id != postId)
                .toList(growable: false),
          ),
        )
        .toList(growable: false);

    await _repository.remove(postId, items);
    for (final SavedCollectionModel collection in collections) {
      await _collectionsRepository.updateItems(
        collection.id,
        collection.itemIds,
      );
    }
    emit(state.copyWith(items: items, collections: collections));
  }

  List<BookmarkItemModel> itemsForCollection(String collectionId) {
    final SavedCollectionModel? collection = collectionById(collectionId);
    if (collection == null) {
      return const <BookmarkItemModel>[];
    }

    final Set<String> ids = collection.itemIds.toSet();
    final List<BookmarkItemModel> items = state.items
        .where((BookmarkItemModel item) => ids.contains(item.id))
        .toList(growable: false);
    return _sortedItems(items);
  }

  SavedCollectionModel? collectionById(String collectionId) {
    for (final SavedCollectionModel collection in state.collections) {
      if (collection.id == collectionId) {
        return collection;
      }
    }
    return null;
  }

  SavedCollectionModel? _collectionByName(String name) {
    for (final SavedCollectionModel collection in state.collections) {
      if (collection.name.toLowerCase() == name.toLowerCase()) {
        return collection;
      }
    }
    return null;
  }

  List<SavedCollectionModel> _attachItemToCollection({
    required List<SavedCollectionModel> collections,
    required String collectionId,
    required String itemId,
  }) {
    return collections
        .map((SavedCollectionModel collection) {
          if (collection.id != collectionId ||
              collection.itemIds.contains(itemId)) {
            return collection;
          }
          return collection.copyWith(
            itemIds: <String>[itemId, ...collection.itemIds],
          );
        })
        .toList(growable: false);
  }

  List<BookmarkItemModel> _sortedItems(List<BookmarkItemModel> items) {
    final List<BookmarkItemModel> sorted = List<BookmarkItemModel>.from(items);
    sorted.sort(
      (BookmarkItemModel a, BookmarkItemModel b) =>
          b.savedAt.compareTo(a.savedAt),
    );
    return sorted;
  }
}
