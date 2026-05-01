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
    final collections = await _repository.create(name.trim());
    emit(state.copyWith(collections: collections, draftName: ''));
  }

  Future<void> moveOrAdd(
    String sourceId,
    String targetId,
    String itemId,
  ) async {
    SavedCollectionModel? sourceUpdated;
    SavedCollectionModel? targetUpdated;
    final SavedCollectionModel? source = state.collections
        .where((collection) => collection.id == sourceId)
        .firstOrNull;
    if (source != null) {
      sourceUpdated = await _repository.updateItems(
        sourceId,
        source.itemIds.where((id) => id != itemId).toList(growable: false),
      );
    }
    if (targetId.isNotEmpty) {
      targetUpdated = await _repository.addItem(targetId, itemId);
    }
    final collections = state.collections
        .map((collection) {
          if (sourceUpdated != null && collection.id == sourceUpdated.id) {
            return sourceUpdated;
          }
          if (targetUpdated != null && collection.id == targetUpdated.id) {
            return targetUpdated;
          }
          return collection;
        })
        .toList(growable: false);
    emit(state.copyWith(collections: collections));
  }

  Future<void> remove(String collectionId, String itemId) async {
    final SavedCollectionModel? source = state.collections
        .where((collection) => collection.id == collectionId)
        .firstOrNull;
    if (source == null) {
      return;
    }
    final SavedCollectionModel? updated = await _repository.updateItems(
      collectionId,
      source.itemIds.where((id) => id != itemId).toList(growable: false),
    );
    if (updated == null) {
      return;
    }
    emit(
      state.copyWith(
        collections: state.collections
            .map(
              (collection) =>
                  collection.id == updated.id ? updated : collection,
            )
            .toList(growable: false),
      ),
    );
  }
}
