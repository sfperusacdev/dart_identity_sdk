import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dart_identity_sdk/widgets/scaffold/state.dart';

class QueryManager<T> extends Cubit<QueryState<T>> {
  final Future<T> Function() query;
  final bool clearOnRefresh;

  final T Function(T list, String filter)? filterCallback;

  QueryManager({
    required this.query,
    this.clearOnRefresh = false,
    this.filterCallback,
  }) : super(QueryState<T>(isLoading: true));

  Future<void> fetch({bool silent = false}) async {
    if (!silent) {
      emit(QueryState<T>(
        isLoading: true,
        rawdata: clearOnRefresh ? null : state.rawdata,
        filter: state.filter,
      ));
    }
    try {
      final result = await query();
      emit(QueryState<T>(
        rawdata: result,
        filter: state.filter,
      ));
    } catch (e, stackTrace) {
      emit(QueryState<T>(
        errorMessage: e.toString(),
        rawdata: state.rawdata,
        filter: state.filter,
      ));
      if (kDebugMode) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
      }
    }
  }

  void clearFilter() => applyFilter("");

  void applyFilter(String filter) {
    emit(QueryState<T>(
      isLoading: state.isLoading,
      rawdata: state.rawdata,
      errorMessage: state.errorMessage,
      filter: filter,
    ));
  }

  Future<void> refresh({bool silent = true}) => fetch(silent: silent);

  T? get data {
    if (state.rawdata == null) return null;
    if (state.rawdata is List && state.filter.trim().length > 2) {
      return filterCallback?.call(
        state.rawdata as T,
        state.filter.trim(),
      );
    } else {
      return state.rawdata;
    }
  }
}
