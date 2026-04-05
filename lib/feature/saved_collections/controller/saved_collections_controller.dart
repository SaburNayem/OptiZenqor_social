import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/saved_collection_model.dart';
import '../repository/saved_collections_repository.dart';

class SavedCollectionsState {
  const SavedCollectionsState({
    this.collections = const <SavedCollectionModel>[],
    this.draftName = '',
  });

  final List<SavedCollectionModel> collections;
  final String draftName;

  SavedCollectionsState copyWith({
    List<SavedCollectionModel>? collections,
    String? draftName,
  }) {
    return SavedCollectionsState(
      collections: collections ?? this.collections,
      draftName: draftName ?? this.draftName,
    );
  }
}

class SavedCollectionsController extends Cubit<SavedCollectionsState> {
  SavedCollectionsController({SavedCollectionsRepository? repository})
    : _repository = repository ?? SavedCollectionsRepository(),
      super(const SavedCollectionsState());

  final SavedCollectionsRepository _repository;

  Future<void> load() async {
    final collections = await _repository.read();
    emit(state.copyWith(collections: collections));
  }

  void updateDraftName(String value) {
    emit(state.copyWith(draftName: value));
  }

  Future<void> create(String name) async {
    if (name.trim().isEmpty) {
      return;
    }
    final collections = <SavedCollectionModel>[
      SavedCollectionModel(
        id: 'col_${DateTime.now().millisecondsSinceEpoch}',
        name: name.trim(),
        itemIds: const <String>[],
      ),
      ...state.collections,
    ];
    await _repository.write(collections);
    emit(state.copyWith(collections: collections, draftName: ''));
  }

  Future<void> moveOrAdd(
    String sourceId,
    String targetId,
    String itemId,
  ) async {
    final collections = state.collections.map((collection) {
      if (collection.id == sourceId) {
        return collection.copyWith(
          itemIds: collection.itemIds.where((id) => id != itemId).toList(),
        );
      }
      if (collection.id == targetId && !collection.itemIds.contains(itemId)) {
        return collection.copyWith(
          itemIds: <String>[...collection.itemIds, itemId],
        );
      }
      return collection;
    }).toList();
    await _repository.write(collections);
    emit(state.copyWith(collections: collections));
  }

  Future<void> remove(String collectionId, String itemId) async {
    final collections = state.collections.map((collection) {
      if (collection.id != collectionId) {
        return collection;
      }
      return collection.copyWith(
        itemIds: collection.itemIds.where((id) => id != itemId).toList(),
      );
    }).toList();
    await _repository.write(collections);
    emit(state.copyWith(collections: collections));
  }
}
