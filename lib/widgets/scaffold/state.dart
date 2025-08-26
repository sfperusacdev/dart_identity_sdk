class QueryState<T> {
  final T? rawdata;
  final String filter; // only if T is array
  final bool isLoading;
  final String errorMessage;

  bool get hasError => errorMessage.isNotEmpty;
  const QueryState({
    this.rawdata,
    this.filter = "",
    this.isLoading = false,
    this.errorMessage = '',
  });
  QueryState<T> copyWith({
    T? data,
    bool? isLoading,
    String? errorMessage,
    String? filter,
  }) {
    return QueryState<T>(
      rawdata: data ?? this.rawdata,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      filter: filter ?? this.filter,
    );
  }
}
