import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

final _picker = ImagePicker();
Future<File?> pickImage({bool useCamera = false}) async {
  final pickedFile = await _picker.pickImage(
    source: useCamera ? ImageSource.camera : ImageSource.gallery,
  );
  if (pickedFile != null) {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      return File(pickedFile.path);
    }
    final compressedFile = await _compressImage(File(pickedFile.path));
    if (compressedFile != null) return compressedFile;
  }
  return null;
}

Future<File?> _compressImage(File file) async {
  final compressed = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    '${file.path}_compressed.jpg',
    minHeight: (1080 / 4).toInt(),
    minWidth: (1920 / 4).toInt(),
    quality: 70,
  );
  return File(compressed!.path);
}

Future<Uint8List> decodeBase64ToBytes(String base64Image) async {
  final bytes = base64Decode(base64Image);
  final codec = await instantiateImageCodec(bytes, targetWidth: 32);
  final frame = await codec.getNextFrame();
  final image = frame.image;

  final byteData = await image.toByteData(format: ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

class FullScreenZoomableImage extends StatelessWidget {
  final Uint8List imageBytes;
  const FullScreenZoomableImage({super.key, required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).maybePop(),
        child: InteractiveViewer(
          minScale: 1.0,
          maxScale: 5.0,
          panEnabled: true,
          child: Center(child: Image.memory(imageBytes, fit: BoxFit.cover)),
        ),
      ),
    );
  }
}

Future<void> showFullScreenZoomableImage(
  BuildContext context, {
  required Uint8List imageBytes,
}) async {
  await Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      pageBuilder: (_, __, ___) =>
          FullScreenZoomableImage(imageBytes: imageBytes),
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
    ),
  );
}
