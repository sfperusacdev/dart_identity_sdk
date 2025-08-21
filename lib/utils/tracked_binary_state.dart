import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class TrackedBinaryState {
  Uint8List? _data;
  bool _isInitialized = false;
  bool _isModified = false;

  TrackedBinaryState();

  /// Creates an instance with synced bytes (not modified).
  factory TrackedBinaryState.fromSyncedBytes(Uint8List? bytes) {
    final asset = TrackedBinaryState();
    asset._setData(bytes, markModified: false);
    return asset;
  }

  /// Creates an instance with synced base64 string (not modified).
  factory TrackedBinaryState.fromSyncedBase64(String? base64) {
    final asset = TrackedBinaryState();
    final bytes =
        (base64 != null && base64.isNotEmpty) ? base64Decode(base64) : null;
    asset._setData(bytes, markModified: false);
    return asset;
  }

  /// Creates an instance with synced file (not modified).
  static Future<TrackedBinaryState> fromSyncedFile(File file) async {
    final asset = TrackedBinaryState();
    await asset._setDataFromFile(file, markModified: false);
    return asset;
  }

  /// Replaces data from bytes without marking as modified.
  void syncFromBytes(Uint8List? bytes) {
    _setData(bytes, markModified: false);
  }

  /// Replaces data from base64 string without marking as modified.
  void syncFromBase64(String? base64) {
    final bytes =
        (base64 != null && base64.isNotEmpty) ? base64Decode(base64) : null;
    _setData(bytes, markModified: false);
  }

  /// Replaces data from file without marking as modified.
  Future<void> syncFromFile(File file) async {
    await _setDataFromFile(file, markModified: false);
  }

  // === Update methods (user change, marked as modified) ===

  /// Updates data from bytes and marks as modified.
  void updateFromBytes(Uint8List bytes) {
    _setData(bytes, markModified: true);
  }

  /// Updates data from base64 and marks as modified.
  void updateFromBase64(String base64) {
    _setData(base64Decode(base64), markModified: true);
  }

  /// Updates data from file and marks as modified.
  Future<void> updateFromFile(File file) async {
    await _setDataFromFile(file, markModified: true);
  }

  /// Returns whether the asset has been initialized.
  bool isInitialized() => _isInitialized;

  /// Returns raw byte data.
  Uint8List? getBytes() => _data;
  Uint8List? getBytesIfModified() => isInitialized() ? getBytes() : null;

  /// Returns base64 string of data.
  String? getBase64() => _data != null ? base64Encode(_data!) : null;
  String? getBase64IfModified() => isInitialized() ? getBase64() : null;

  /// Returns whether the data has been modified.
  bool isModified() => _isModified;

  /// Returns true if there's no data.
  bool isEmpty() => _data == null || _data!.isEmpty;
  bool isNotEmpty() => !isEmpty();

  /// Marks the asset as unmodified.
  void markUnmodified() {
    _isModified = false;
  }

  void _setData(Uint8List? data, {required bool markModified}) {
    _data = data;
    _isInitialized = true;
    _isModified = markModified;
  }

  Future<void> _setDataFromFile(File file, {required bool markModified}) async {
    final data = await file.readAsBytes();
    _setData(data, markModified: markModified);
  }
}
