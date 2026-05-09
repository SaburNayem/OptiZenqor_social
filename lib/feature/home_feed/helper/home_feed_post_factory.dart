class HomeFeedPostFactory {
  HomeFeedPostFactory._();

  static Map<String, List<String>> buildRecommendationPreferences({
    required Set<String> lessLikeThisPostIds,
    required Set<String> hiddenCreatorIds,
    required Set<String> hiddenTopics,
  }) {
    return <String, List<String>>{
      'lessLikeThis': lessLikeThisPostIds.toList(),
      'hiddenCreators': hiddenCreatorIds.toList(),
      'hiddenTopics': hiddenTopics.toList(),
    };
  }
}
