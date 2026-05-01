class StoryViewStateModel {
  const StoryViewStateModel({required this.currentIndex});

  final int currentIndex;

  StoryViewStateModel copyWith({int? currentIndex}) {
    return StoryViewStateModel(currentIndex: currentIndex ?? this.currentIndex);
  }
}
