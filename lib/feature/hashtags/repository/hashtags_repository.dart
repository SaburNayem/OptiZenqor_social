import '../model/hashtag_model.dart';

class HashtagsRepository {
  List<HashtagModel> trending() => const <HashtagModel>[
        HashtagModel(tag: '#flutter', count: 12000),
        HashtagModel(tag: '#creator', count: 8700),
        HashtagModel(tag: '#startup', count: 6500),
      ];
}
