import 'package:flutter/foundation.dart';

import '../model/draft_item_model.dart';

class DraftsAndSchedulingController extends ChangeNotifier {
  List<DraftItemModel> drafts = const [
    DraftItemModel(id: 'd1', title: 'Weekend photo dump', type: PublishType.post),
    DraftItemModel(
      id: 'd2',
      title: 'Creator tip reel',
      type: PublishType.reel,
      scheduledAt: null,
    ),
  ];

  Future<void> scheduleDraft(String id, DateTime when) async {
    drafts = drafts
        .map((item) => item.id == id
            ? DraftItemModel(
                id: item.id,
                title: item.title,
                type: item.type,
                scheduledAt: when,
              )
            : item)
        .toList();
    notifyListeners();
  }
}
