import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dart_identity_sdk/kdialogs/kdialogs.dart';

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

  TextEditingCController() : super();

  factory TextEditingCController.withText(String? text,
      {String? internalID, dynamic extras}) {
    final customController = TextEditingCController()..text = text ?? "";
    customController._internalID = internalID;
    customController._extra = extras;
    return customController;
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

  String getValue() {
    if (_internalID == null) return text;
    if (_internalID!.isEmpty) return text;
    return _internalID!;
  }

  String? getValueOrNull({bool trim = false}) {
    var value = getValue();
    if (trim) value = value.trim();
    return value.isEmpty ? null : value;
  }

  dynamic getExtras() => _extra;
  String? getInternalID() => _internalID;

  void updateLabel(String newTitle) => labelState.emitVal(newTitle);
  void updateBottomLabel(String text) => bottomLabelState.emitVal(text);
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
