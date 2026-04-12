import 'package:flutter/foundation.dart';

import '../model/post_draft_model.dart';
import '../repository/posts_repository.dart';

class PostsController extends ChangeNotifier {
  PostsController({PostsRepository? repository})
      : _repository = repository ?? PostsRepository();

  final PostsRepository _repository;
  List<PostDraftModel> drafts = <PostDraftModel>[];
  bool isLoading = false;

  Future<void> loadDrafts() async {
    isLoading = true;
    notifyListeners();
    final raw = await _repository.getDrafts();
    drafts = raw.map(PostDraftModel.fromMap).toList();
    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteDraft(String id) async {
    await _repository.deleteDraft(id);
    drafts.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}
