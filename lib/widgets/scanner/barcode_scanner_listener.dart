import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// {@template barcode_scanner_listener}
/// [BarcodeScannerListener] is a widget that detects rapid input from
/// physical keyboards or barcode scanners operating in HID (keyboard emulation) mode,
/// such as those found in industrial PDA devices.
///
/// It listens to key events from `HardwareKeyboard.instance`, accumulates printable
/// characters, and triggers the [onScanDetected] callback when a valid scan sequence
/// is detected.
///
/// ### Features:
/// - Supports HID-mode scanners and physical keyboards.
/// - Optional alphanumeric-only filtering.
/// - Configurable character delay ([interKeyDelay]) and scan finalization delay ([scanFinalizeDelay]).
/// - Allows stopping key event propagation via [stopKeyEventPropagation].
///
/// ### Typical usage:
/// ```dart
/// BarcodeScannerListener(
///   onScanDetected: (value) => print('Scanned: $value'),
///   child: MyApp(),
/// )
/// ```
///
/// Requires Flutter 3.22 or later.
/// {@endtemplate}

class BarcodeScannerListener extends StatefulWidget {
  const BarcodeScannerListener({
    super.key,
    required this.child,
    this.onBarcodeScanned,
    this.minBarcodeLength = 4,
    this.characterDelayThreshold = const Duration(milliseconds: 50),
    this.finalizationDelay = const Duration(milliseconds: 50),
    this.alphanumericOnly = false,
    this.stopKeyEventPropagation = false,
  });

  final ValueChanged<String>? onBarcodeScanned;
  final Widget child;
  final bool alphanumericOnly;
  final int minBarcodeLength;
  final Duration characterDelayThreshold;
  final Duration finalizationDelay;
  final bool stopKeyEventPropagation;

  @override
  State<BarcodeScannerListener> createState() => _BarcodeScannerListenerState();
}

class _BarcodeScannerListenerState extends State<BarcodeScannerListener> {
  final StringBuffer _barcodeBuffer = StringBuffer();
  DateTime _lastCharacterTime = DateTime(0);
  Timer? _finalizationTimer;

  final _alphanumericRegex = RegExp(r'[a-zA-Z0-9]');
  final _printableCharRegex = RegExp(r'[\x20-\x7E]'); // incluye espacio

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKeyEvent);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKeyEvent);
    _finalizationTimer?.cancel();
    super.dispose();
  }

  bool _onKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return false;

    final char = event.character;
    if (char == null || char.isEmpty) return false;

    final now = DateTime.now();
    final timeSinceLastChar = now.difference(_lastCharacterTime);
    _lastCharacterTime = now;

    if (_barcodeBuffer.isNotEmpty &&
        timeSinceLastChar > widget.characterDelayThreshold) {
      _barcodeBuffer.clear();
    }

    if (widget.alphanumericOnly) {
      if (_alphanumericRegex.hasMatch(char)) {
        _barcodeBuffer.write(char);
      }
    } else if (_printableCharRegex.hasMatch(char)) {
      _barcodeBuffer.write(char);
    }

    _finalizationTimer?.cancel();
    _finalizationTimer = Timer(widget.finalizationDelay, () {
      final barcode = _barcodeBuffer.toString();
      if (barcode.length >= widget.minBarcodeLength) {
        widget.onBarcodeScanned?.call(barcode);
      }
      _barcodeBuffer.clear();
    });

    return widget.stopKeyEventPropagation;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
