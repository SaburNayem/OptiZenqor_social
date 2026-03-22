import 'package:flutter/foundation.dart';

import '../model/explore_recommendation_model.dart';

class ExploreRecommendationController extends ChangeNotifier {
  List<ExploreRecommendationModel> items = const [
    ExploreRecommendationModel(
      title: 'People you may know',
      subtitle: 'Suggested from your interests and mutuals',
      type: 'people',
    ),
    ExploreRecommendationModel(
      title: 'Trending communities',
      subtitle: 'High engagement groups in your category',
      type: 'community',
    ),
    ExploreRecommendationModel(
      title: 'Recommended reels',
      subtitle: 'Based on your watch behavior',
      type: 'reels',
    ),
  ];
}
