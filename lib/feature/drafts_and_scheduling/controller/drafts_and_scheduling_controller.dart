import 'package:flutter/foundation.dart';

import '../model/draft_item_model.dart';
import '../repository/drafts_and_scheduling_repository.dart';

class DraftsAndSchedulingController extends ChangeNotifier {
  DraftsAndSchedulingController({DraftsAndSchedulingRepository? repository})
    : _repository = repository ?? DraftsAndSchedulingRepository() {
    load();
  }

  final DraftsAndSchedulingRepository _repository;

  List<DraftItemModel> drafts = <DraftItemModel>[];

  Future<void> load() async {
    drafts = await _repository.read();
    notifyListeners();
  }

  Future<void> scheduleDraft(String id, DateTime when) async {
    DraftItemModel? updatedDraft;
    for (final DraftItemModel item in drafts) {
      if (item.id == id) {
        updatedDraft = item.copyWith(
          scheduledAt: when,
          editHistory: <String>[
            ...item.editHistory,
            'Scheduled for ${when.toLocal()}',
          ],
        );
        break;
      }
    }
    if (updatedDraft == null) {
      return;
    }
    final DraftItemModel persisted = await _repository.upsertDraft(
      updatedDraft,
    );
    drafts = drafts.map((item) => item.id == id ? persisted : item).toList();
    notifyListeners();
  }

  Future<void> saveDraft(DraftItemModel draft) async {
    final DraftItemModel persisted = await _repository.upsertDraft(draft);
    drafts = <DraftItemModel>[
      persisted,
      ...drafts.where((item) => item.id != persisted.id),
    ];
    notifyListeners();
  }
}
