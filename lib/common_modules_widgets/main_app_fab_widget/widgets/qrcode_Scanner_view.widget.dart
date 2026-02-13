import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerView extends StatefulWidget {
  const QRScannerView({super.key});

  @override
  QRScannerViewState createState() => QRScannerViewState();
}

class QRScannerViewState extends State<QRScannerView> {
  bool _hasPopped = false;
  // Higher resolution + unrestricted detection + longer timeout for reliable QR reading
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.unrestricted,
    detectionTimeoutMs: 750,
    cameraResolution: const Size(1280, 720),
    formats: [BarcodeFormat.qrCode],
    facing: CameraFacing.back,
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (_hasPopped) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final Barcode barcode = barcodes.first;
    // rawValue can be null for some QR codes; fallback to displayValue
    final String? value = barcode.rawValue ?? barcode.displayValue;
    final String trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return;
    _hasPopped = true;
    controller.stop();
    if (!mounted) return;
    Navigator.of(context).pop(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () {
              controller.toggleTorch();
            },
          ),
        ],
      ),
      body: MobileScanner(
        controller: controller,
        onDetect: _onBarcodeDetected,
      ),
    );
  }
}
