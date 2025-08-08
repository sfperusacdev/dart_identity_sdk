import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrCardReader extends StatefulWidget {
  final double? width;
  final double? height;
  final bool onlyOneScan;
  final Function(String code) onScan;

  const QrCardReader({
    required this.onScan,
    this.width,
    this.height,
    this.onlyOneScan = true,
    super.key,
  });

  @override
  State<QrCardReader> createState() => _QrCardReaderState();
}

class _QrCardReaderState extends State<QrCardReader> {
  bool hasScanned = false;
  final MobileScannerController scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
  );

  @override
  void initState() {
    super.initState();
    scannerController.start();
  }

  @override
  void dispose() {
    scannerController.stop().then((_) => scannerController.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return ClipRRect(
      borderRadius: BorderRadiusGeometry.circular(18.0),
      child: SizedBox(
        width: widget.width ?? screenSize.width * 0.8,
        height: widget.height ?? screenSize.width,
        child: Stack(
          children: [
            MobileScanner(
              controller: scannerController,
              fit: BoxFit.fill,
              onDetect: (capture) {
                final String? code = capture.barcodes.first.rawValue;
                if (code == null || code.isEmpty) return;
                if (widget.onlyOneScan && hasScanned) return;

                hasScanned = true;
                widget.onScan(code);
              },
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () async => await scannerController.toggleTorch(),
                    child: const Icon(Icons.flash_on, color: Colors.white),
                  ),
                  const SizedBox(width: 10.0),
                  InkWell(
                    onTap: () async => await scannerController.switchCamera(),
                    child: const Icon(
                      Icons.flip_camera_android,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
