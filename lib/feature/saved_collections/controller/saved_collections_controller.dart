import 'package:flutter/foundation.dart';

import '../model/saved_collection_model.dart';
import '../repository/saved_collections_repository.dart';

class SavedCollectionsController extends ChangeNotifier {
  SavedCollectionsController({SavedCollectionsRepository? repository})
      : _repository = repository ?? SavedCollectionsRepository();

  final SavedCollectionsRepository _repository;

  List<SavedCollectionModel> collections = <SavedCollectionModel>[];

  Future<void> load() async {
    collections = await _repository.read();
    notifyListeners();
  }

  Future<void> create(String name) async {
    if (name.trim().isEmpty) {
      return;
    }
    collections.insert(
      0,
      SavedCollectionModel(
        id: 'col_${DateTime.now().millisecondsSinceEpoch}',
        name: name.trim(),
        itemIds: const <String>[],
      ),
    );
    await _repository.write(collections);
    notifyListeners();
  }

  Future<void> moveOrAdd(String sourceId, String targetId, String itemId) async {
    collections = collections.map((collection) {
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
    notifyListeners();
  }

  Future<void> remove(String collectionId, String itemId) async {
    collections = collections.map((collection) {
      if (collection.id != collectionId) {
        return collection;
      }
      return collection.copyWith(
        itemIds: collection.itemIds.where((id) => id != itemId).toList(),
      );
    }).toList();
    await _repository.write(collections);
    notifyListeners();
  }
}
