import 'dart:async';

import 'package:dart_identity_sdk/widgets/scaffold/state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QueryController<T, Q> extends Cubit<QueryState<T>> {
  final FutureOr<T> Function(Q query) _fetchCallback;
  final bool _clearOnRefresh;
  final T Function(T data, String filter)? _filterCallback;
  final bool Function(T data)? _onLoad;
  final void Function(T data)? _onUpdate;

  Q? _query;
  bool _hasLoadedOnce = false;

  QueryController({
    required FutureOr<T> Function(Q query) fetchCallback,
    Q? initialQuery,
    bool clearOnRefresh = false,
    T Function(T data, String filter)? filterCallback,
    bool Function(T data)? onDataLoadDecision,
    void Function(T data)? onUpdate,
  })  : _fetchCallback = fetchCallback,
        _query = initialQuery,
        _clearOnRefresh = clearOnRefresh,
        _filterCallback = filterCallback,
        _onLoad = onDataLoadDecision,
        _onUpdate = onUpdate,
        super(QueryState<T>(isLoading: true)) {
    if (_query != null) {
      fetch();
    }
  }

  Q? get query => _query;

  Future<void> fetch({Q? query, bool silent = false}) async {
    if (query != null) {
      _query = query;
    }

    final currentQuery = _query;
    if (currentQuery == null) return;

    if (!silent) {
      emit(
        QueryState<T>(
          isLoading: true,
          rawdata: _clearOnRefresh ? null : state.rawdata,
          filter: state.filter,
        ),
      );
    }

    try {
      final result = await _fetchCallback(currentQuery);

      if (!_hasLoadedOnce) {
        if (_onLoad != null) {
          final shouldContinue = _onLoad!.call(result);
          if (!shouldContinue) return;
        }
        _hasLoadedOnce = true;
      }

      emit(QueryState<T>(rawdata: result, filter: state.filter));
      _onUpdate?.call(result);
    } catch (e, stackTrace) {
      final errorMessage = parseErrorMessage(e);
      emit(
        QueryState<T>(
          errorMessage: errorMessage,
          rawdata: state.rawdata,
          filter: state.filter,
        ),
      );

      if (kDebugMode) {
        print('QueryController error: $e');
        print('StackTrace: $stackTrace');
      }
    }
  }

  void updateQuery(Q query) {
    _query = query;
  }

  Future<void> refetch() => fetch(query: _query);

  Future<void> refresh({bool silent = true}) => fetch(silent: silent);

  void clearFilter() => applyFilter('');

  void applyFilter(String filter) {
    emit(
      QueryState<T>(
        isLoading: state.isLoading,
        rawdata: state.rawdata,
        errorMessage: state.errorMessage,
        filter: filter,
      ),
    );
  }

  T? get data {
    final currentData = state.rawdata;
    if (currentData == null) return null;

    if (currentData is List && state.filter.trim().length > 2) {
      return _filterCallback?.call(currentData as T, state.filter.trim());
    }

    return currentData;
  }
}

String parseErrorMessage(dynamic err) {
  if (err == null) return 'Error desconocido';

  if (err is String && err.isNotEmpty) {
    return err;
  }

  if (err is Exception) {
    return err.toString();
  }

  if (err is Error) {
    return err.toString();
  }

  return 'Ha ocurrido un error inesperado';
}
