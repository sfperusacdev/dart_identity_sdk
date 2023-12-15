import 'dart:io';

import 'package:soundpool/soundpool.dart';
import 'package:flutter/services.dart';

class SoundService {
  static final _instance = SoundService._private();
  SoundService._private();
  factory SoundService() => _instance;
  Soundpool? _pool;
  int? _soundId;
  int? _errorSoundID;
  Future init() async {
    if (Platform.isLinux || Platform.isWindows) return;
    _pool = Soundpool.fromOptions();
    _soundId = await rootBundle.load("packages/dart_identity_sdk/assets/sounds/qr.mp3").then((ByteData soundData) {
      return _pool!.load(soundData);
    });
    _errorSoundID =
        await rootBundle.load("packages/dart_identity_sdk/assets/sounds/error.mp3").then((ByteData soundData) {
      return _pool!.load(soundData);
    });
  }

  void cameraSound({vibration = true}) {
    if (_pool != null && _soundId != null) _pool!.play(_soundId!);
    if (vibration) HapticFeedback.heavyImpact();
  }

  void erorrSound({vibration = true}) {
    if (_pool != null && _errorSoundID != null) _pool!.play(_errorSoundID!);
    if (vibration) HapticFeedback.heavyImpact();
  }
}
