import '../../model/community_group_model.dart';

class CommunitiesState {
  const CommunitiesState({
    this.groups = const <CommunityGroupModel>[],
    this.query = '',
    this.showJoinedOnly = false,
    this.isLoading = true,
  });

  final List<CommunityGroupModel> groups;
  final String query;
  final bool showJoinedOnly;
  final bool isLoading;

  List<CommunityGroupModel> get filteredGroups {
    return groups
        .where((group) {
          final matchesJoin = !showJoinedOnly || group.joined;
          final normalizedQuery = query.trim().toLowerCase();
          final matchesQuery =
              normalizedQuery.isEmpty ||
              group.name.toLowerCase().contains(normalizedQuery) ||
              group.category.toLowerCase().contains(normalizedQuery);
          return matchesJoin && matchesQuery;
        })
        .toList(growable: false);
  }

  CommunitiesState copyWith({
    List<CommunityGroupModel>? groups,
    String? query,
    bool? showJoinedOnly,
    bool? isLoading,
  }) {
    return CommunitiesState(
      groups: groups ?? this.groups,
      query: query ?? this.query,
      showJoinedOnly: showJoinedOnly ?? this.showJoinedOnly,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
