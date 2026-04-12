import 'package:flutter/foundation.dart';

import '../model/draft_item_model.dart';
import '../repository/drafts_and_scheduling_repository.dart';

class DraftsAndSchedulingController extends ChangeNotifier {
  DraftsAndSchedulingController({
    DraftsAndSchedulingRepository? repository,
  }) : _repository = repository ?? DraftsAndSchedulingRepository() {
    load();
  }

  final DraftsAndSchedulingRepository _repository;

  List<DraftItemModel> drafts = <DraftItemModel>[];

  Future<void> load() async {
    drafts = await _repository.read();
    notifyListeners();
  }

  Future<void> scheduleDraft(String id, DateTime when) async {
    drafts = drafts
        .map(
          (item) => item.id == id
              ? item.copyWith(
                  scheduledAt: when,
                  editHistory: <String>[
                    ...item.editHistory,
                    'Scheduled for ${when.toLocal()}',
                  ],
                )
              : item,
        )
        .toList();
    await _repository.write(drafts);
    notifyListeners();
  }

  Future<void> saveDraft(DraftItemModel draft) async {
    drafts = <DraftItemModel>[
      draft,
      ...drafts.where((item) => item.id != draft.id),
    ];
    await _repository.write(drafts);
    notifyListeners();
  }
}
