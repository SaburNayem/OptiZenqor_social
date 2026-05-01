enum ReelFeedFilter { forYou, following, saved }

class ReelFilterModel {
  const ReelFilterModel({required this.filter});

  final ReelFeedFilter filter;

  String label() {
    switch (filter) {
      case ReelFeedFilter.forYou:
        return 'For You';
      case ReelFeedFilter.following:
        return 'Following';
      case ReelFeedFilter.saved:
        return 'Saved';
    }
  }
}
