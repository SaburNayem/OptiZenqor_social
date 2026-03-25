class LoadStateModel {
  const LoadStateModel({
    this.isLoading = false,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.isSuccess = false,
    this.isEmpty = false,
    this.hasError = false,
    this.errorMessage,
  });

  final bool isLoading;
  final bool isRefreshing;
  final bool isLoadingMore;
  final bool isSuccess;
  final bool isEmpty;
  final bool hasError;
  final String? errorMessage;

  LoadStateModel copyWith({
    bool? isLoading,
    bool? isRefreshing,
    bool? isLoadingMore,
    bool? isSuccess,
    bool? isEmpty,
    bool? hasError,
    String? errorMessage,
  }) {
    return LoadStateModel(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSuccess: isSuccess ?? this.isSuccess,
      isEmpty: isEmpty ?? this.isEmpty,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage,
    );
  }

  static const idle = LoadStateModel();
}
