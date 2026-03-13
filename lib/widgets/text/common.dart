import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dart_identity_sdk/kdialogs/kdialogs.dart';
import 'package:intl/intl.dart';

final formatoPeru = DateFormat('dd/MM/yyyy');
final formatoSQL = DateFormat('yyyy-MM-dd');

class TextEditingLabelState extends Cubit<String> {
  TextEditingLabelState() : super("");
  void emitVal(String newTitle) => emit(newTitle);
}

class TextEditingBottomLabelState extends Cubit<String> {
  TextEditingBottomLabelState() : super("");
  void emitVal(String newTitle) => emit(newTitle);
}

class TextEditingCController extends TextEditingController {
  final labelState = TextEditingLabelState();
  final bottomLabelState = TextEditingBottomLabelState();
  final focus = FocusNode();

  String? _internalID;
  dynamic _extra;

  int _wordCount = 0;
  int get wordCount => _wordCount;

  TextEditingCController();

  factory TextEditingCController.withText(
    String? text, {
    String? internalID,
    dynamic extras,
  }) {
    final c = TextEditingCController();
    c.text = text ?? "";
    c._internalID = internalID;
    c._extra = extras;
    return c;
  }

  factory TextEditingCController.withDatetime(DateTime? datetime) {
    if (datetime == null) return TextEditingCController();
    return TextEditingCController.withText(
      formatoPeru.format(datetime),
      internalID: formatoSQL.format(datetime),
      extras: datetime,
    );
  }

  factory TextEditingCController.withTime(TimeOfDay? time) {
    if (time == null) return TextEditingCController();

    final internal = _timeToInternal(time);
    final display = _timeToDisplay(time);

    return TextEditingCController.withText(
      display,
      internalID: internal,
      extras: time,
    );
  }

  @override
  void clear() {
    super.clear();
    _internalID = null;
    _extra = null;
    refreshWordsCount();
  }

  void refreshWordsCount() => _wordCount = text.length;

  void setText(String text, {String? internalID, dynamic extras}) {
    this.text = text;
    _internalID = internalID;
    _extra = extras;
  }

  void setDatetime(DateTime? datetime) {
    if (datetime == null) {
      clear();
      return;
    }

    setText(
      formatoPeru.format(datetime),
      internalID: formatoSQL.format(datetime),
      extras: datetime,
    );
  }

  void setTime(TimeOfDay? time) {
    if (time == null) {
      clear();
      return;
    }

    setText(
      _timeToDisplay(time),
      internalID: _timeToInternal(time),
      extras: time,
    );
  }

  void setLabel(String newTitle) => labelState.emitVal(newTitle);
  void setBottomLabel(String text) => bottomLabelState.emitVal(text);

  String getValue() {
    if (_internalID == null || _internalID!.isEmpty) return text;
    return _internalID!;
  }

  String? getValueOrNull({bool trim = false}) {
    var value = getValue();
    if (trim) value = value.trim();
    return value.isEmpty ? null : value;
  }

  DateTime? getDatetimeOrNull() {
    final value = getValueOrNull();
    if (value == null) return null;

    final sql = DateTime.tryParse(value);
    if (sql != null) return sql;

    try {
      return formatoPeru.parse(value);
    } catch (_) {}

    final time = _parseInternalTime(value);
    if (time != null) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, time.hour, time.minute);
    }

    return null;
  }

  TimeOfDay? getTimeOrNull() {
    final value = getValueOrNull();
    if (value == null) return null;
    return _parseInternalTime(value);
  }

  dynamic getExtras() => _extra;
  String? getInternalID() => _internalID;

  static String _timeToInternal(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  static String _timeToDisplay(TimeOfDay time) {
    final h12 = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final m = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? "AM" : "PM";
    return "${h12.toString().padLeft(2, '0')}:$m $period";
  }

  static TimeOfDay? _parseInternalTime(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return null;

    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;

    return TimeOfDay(hour: h, minute: m);
  }

  @override
  void dispose() {
    focus.dispose();
    labelState.close();
    bottomLabelState.close();
    super.dispose();
  }
}

class SelectOptionOnChangeEventData<T extends SelectOption> {
  final TextEditingCController controller;
  final List<T> data;
  final T? selected;

  const SelectOptionOnChangeEventData(
    this.controller,
    this.data, {
    this.selected,
  });
}
