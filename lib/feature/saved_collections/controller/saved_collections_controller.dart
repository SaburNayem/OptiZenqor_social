import 'package:flutter/foundation.dart';

import '../model/saved_collection_model.dart';
import '../repository/saved_collections_repository.dart';

class SavedCollectionsController extends ChangeNotifier {
  SavedCollectionsController({SavedCollectionsRepository? repository}) : _repository = repository ?? SavedCollectionsRepository();
  final SavedCollectionsRepository _repository;
  List<SavedCollectionModel> collections = <SavedCollectionModel>[];

  Future<void> load() async {
    collections = await _repository.read();
    notifyListeners();
  }

  Future<void> create(String name) async {
    if (name.trim().isEmpty) return;
    collections.insert(0, SavedCollectionModel(id: 'col_${DateTime.now().millisecondsSinceEpoch}', name: name.trim(), itemIds: const <String>[]));
    await _repository.write(collections);
    notifyListeners();
  }

  Future<void> moveOrAdd(String sourceId  Future<void> moveOrAdd(String sourcec {
    collections = collections.map((c) {
      if (c.id == sourceId) return c.copyWith(itemIds: c.itemIds.where((id) => id != itemId).toList());
      if (c.id == targetId && !c.itemIds.contains(itemId)) return c.copyWith(itemIds: <String>[...c.itemIds, itemId]);
      return c;
    }).toList();
    await _repository.write(collections);
    notifyListeners();
  }

  Future<void> remove(String collectionId, String itemId) async {
    collections = collections.map((c) => c.id == collectionId ? c.copyWith(itemIds: c.itemIds.where((id) => id != itemId).toList()) : c).toList();
    await _repository.write(collections);
    notifyListeners();
  }
}
