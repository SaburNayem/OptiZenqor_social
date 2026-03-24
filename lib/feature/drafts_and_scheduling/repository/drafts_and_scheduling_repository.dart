import '../../../core/constants/storage_keys.dart';
import '../../../core/services/local_storage_service.dart';
import '../model/draft_item_model.dart';

class DraftsAndSchedulingRepository {
  DraftsAndSchedulingRepository({LocalStorageService? storage})
    : _storage = storage ?? LocalStorageService();

  final LocalStorageService _storage;

  Future<List<DraftItemModel>> read() async {
    final items = await _storage.readJsonList(StorageKeys.draftPosts);
    if (items.isEmpty) {
      return <DraftItemModel>[
        const DraftItemModel(
          id: 'd1',
          title: 'Weekend photo dump draft',
          type: PublishType.post,
          audience: 'Followers',
          location: 'Dhaka, Bangladesh',
          taggedPeople: <String>['@nexa.studio'],
          altText: 'Incomplete carousel draft from creator meetup',
          versionHistory: <String>['v1 moodboard', 'v2 caption polish'],
          editHistory: <String>['Audience changed to Followers', 'Still incomplete'],
        ),
        DraftItemModel(
          id: 's1',
          title: 'Creator tip reel scheduled upload',
          type: PublishType.reel,
          scheduledAt: DateTime(2026, 3, 25, 18, 30),
          audience: 'Everyone',
          location: 'Creator Studio',
          coAuthors: <String>['@mayaquinn'],
          altText: 'Scheduled creator tips reel for tomorrow evening',
          versionHistory: <String>['Hook rewrite', 'Cover updated'],
          editHistory: <String>['Scheduled for creator upload window'],
        ),
      ];
    }
    return items
        .map(
          (item) => DraftItemModel(
            id: item['id'] as String? ?? '',
            title: item['title'] as String? ?? '',
            type: PublishType.values.firstWhere(
              (value) => value.name == item['type'],
              orElse: () => PublishType.post,
            ),
            scheduledAt: item['scheduledAt'] == null
                ? null
                : DateTime.tryParse(item['scheduledAt'] as String),
            audience: item['audience'] as String? ?? 'Everyone',
            location: item['location'] as String?,
            taggedPeople: List<String>.from(
              item['taggedPeople'] as List<dynamic>? ?? const <dynamic>[],
            ),
            coAuthors: List<String>.from(
              item['coAuthors'] as List<dynamic>? ?? const <dynamic>[],
            ),
            altText: item['altText'] as String?,
            versionHistory: List<String>.from(
              item['versionHistory'] as List<dynamic>? ?? const <dynamic>[],
            ),
            editHistory: List<String>.from(
              item['editHistory'] as List<dynamic>? ?? const <dynamic>[],
            ),
          ),
        )
        .where((item) => item.id.isNotEmpty)
        .toList();
  }

  Future<void> write(List<DraftItemModel> drafts) {
    return _storage.writeJsonList(
      StorageKeys.draftPosts,
      drafts
          .map(
            (item) => <String, dynamic>{
              'id': item.id,
              'title': item.title,
              'type': item.type.name,
              'scheduledAt': item.scheduledAt?.toIso8601String(),
              'audience': item.audience,
              'location': item.location,
              'taggedPeople': item.taggedPeople,
              'coAuthors': item.coAuthors,
              'altText': item.altText,
              'versionHistory': item.versionHistory,
              'editHistory': item.editHistory,
            },
          )
          .toList(),
    );
  }
}
