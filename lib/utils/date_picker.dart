import 'package:flutter/material.dart';

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime _clamp(DateTime x, DateTime min, DateTime max) =>
    x.isBefore(min) ? min : (x.isAfter(max) ? max : x);

DateTime? _nearestAllowed(DateTime target, Iterable<DateTime> allowed) {
  if (allowed.isEmpty) return null;
  final t = _dateOnly(target);
  DateTime best = allowed.first;
  int bestDiff = (t.difference(best).inDays).abs();
  for (final d in allowed.skip(1)) {
    final diff = (t.difference(d).inDays).abs();
    if (diff < bestDiff || (diff == bestDiff && d.isBefore(best))) {
      best = d;
      bestDiff = diff;
    }
  }
  return best;
}

/// Shows a date picker where ONLY dates in [allowedDates] are selectable.
/// - If [initialDate] is not allowed, picks the nearest allowed date.
/// - [firstDate]/[lastDate] default to the min/max from [allowedDates] (and are clamped to include them).
Future<DateTime?> showAllowedDatesPicker({
  required BuildContext context,
  required List<DateTime> allowedDates,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
  Locale? locale,
  String? helpText,
  String? cancelText,
  String? confirmText,
  TextDirection? textDirection,
}) async {
  if (allowedDates.isEmpty) return null;

  // Normalize, unique, sort
  final normalized = {
    for (final d in allowedDates) _dateOnly(d),
  }.toList()
    ..sort();

  final allowedSet = normalized.toSet();
  final minAllowed = normalized.first;
  final maxAllowed = normalized.last;

  final first = firstDate != null ? _dateOnly(firstDate) : minAllowed;
  final last = lastDate != null ? _dateOnly(lastDate) : maxAllowed;

  // Ensure bounds include the allowed range
  final boundFirst = first.isBefore(minAllowed) ? first : minAllowed;
  final boundLast = last.isAfter(maxAllowed) ? last : maxAllowed;

  // Choose initial
  DateTime init = _dateOnly(initialDate ?? DateTime.now());
  if (!allowedSet.contains(init)) {
    final nearest = _nearestAllowed(init, allowedSet);
    if (nearest == null) return null;
    init = nearest;
  }
  init = _clamp(init, boundFirst, boundLast);

  Widget builder(BuildContext ctx, Widget? child) {
    if (child == null) return Container();
    if (textDirection != null) {
      return Directionality(textDirection: textDirection, child: child);
    }
    return child;
  }

  return showDatePicker(
    context: context,
    initialDate: init,
    firstDate: boundFirst,
    lastDate: boundLast,
    helpText: helpText,
    cancelText: cancelText,
    confirmText: confirmText,
    locale: locale,
    selectableDayPredicate: (day) => allowedSet.contains(_dateOnly(day)),
    builder: builder,
  );
}
