import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

Future<Uint8List> _readBytesFromAssets(String assetPath) async {
  ByteData data = await rootBundle.load(assetPath);
  return data.buffer.asUint8List();
}

class SoundService {
  static final AudioPlayer _player = AudioPlayer();
  static Uint8List? _qrmp3;
  static Uint8List? _errormp3;
  static Future<void> init() async {
    if (Platform.isLinux || Platform.isWindows) return;

    try {
      _qrmp3 = await _readBytesFromAssets(
        "packages/dart_identity_sdk/assets/sounds/qr.mp3",
      );
      debugPrint("QR scan sound initialized successfully.");
    } catch (e, stackTrace) {
      debugPrint(
          "Error initializing QR scan sound: $e\nStackTrace: $stackTrace");
    }

    try {
      _errormp3 = await _readBytesFromAssets(
        "packages/dart_identity_sdk/assets/sounds/error.mp3",
      );
      debugPrint("Error sound initialized successfully.");
    } catch (e, stackTrace) {
      debugPrint("Error initializing error sound: $e\nStackTrace: $stackTrace");
    }
  }

  static void cameraSound({bool vibration = true}) async {
    try {
      if (_qrmp3 != null) {
        await _player.play(BytesSource(_qrmp3!));
      }
      if (vibration) HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint("Error playing camera sound: $e");
    }
  }

  static void errorSound({bool vibration = true}) async {
    try {
      if (_errormp3 != null) {
        await _player.play(BytesSource(_errormp3!));
      }
      if (vibration) HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint("Error playing error sound: $e");
    }
  }
}
