class SavedCollectionModel {
  const SavedCollectionModel({
    required this.id,
    required this.name,
    required this.itemIds,
  });
  final String id;
  final String name;
  final List<String> itemIds;
  SavedCollectionModel copyWith({List<String>? itemIds}) =>
      SavedCollectionModel(
        id: id,
        name: name,
        itemIds: itemIds ?? this.itemIds,
      );
}
