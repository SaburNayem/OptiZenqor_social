class PaginationStateModel {
  const PaginationStateModel({
    this.page = 1,
    this.pageSize = 10,
    this.hasMore = true,
  });

  final int page;
  final int pageSize;
  final bool hasMore;

  PaginationStateModel copyWith({int? page, int? pageSize, bool? hasMore}) {
    return PaginationStateModel(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
