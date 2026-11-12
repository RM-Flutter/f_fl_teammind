import 'package:app_test/core/constants/app_sizes.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerView extends StatefulWidget {
  const QRScannerView({super.key});

  @override
  QRScannerViewState createState() => QRScannerViewState();
}

class QRScannerViewState extends State<QRScannerView> with SingleTickerProviderStateMixin {
  bool _hasPopped = false;
  bool _torchOn = false;
  // Higher resolution + unrestricted detection + longer timeout for reliable QR reading
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.unrestricted,
    detectionTimeoutMs: 750,
    cameraResolution: const Size(1280, 720),
    formats: [BarcodeFormat.qrCode],
    facing: CameraFacing.back,
  );
  late final AnimationController _scanLine =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);

  @override
  void dispose() {
    _scanLine.dispose();
    controller.dispose();
    super.dispose();
  }

  /// Clear message when the camera can't be opened (e.g. a PC without a webcam,
  /// or camera access blocked in the browser).
  Widget _buildCameraError(BuildContext context, MobileScannerException error) {
    final String messageKey = switch (error.errorCode) {
      MobileScannerErrorCode.permissionDenied => 'qr_scan_camera_denied',
      MobileScannerErrorCode.unsupported => 'qr_scan_no_camera',
      _ => 'qr_scan_camera_error',
    };
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.s24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.no_photography_outlined, color: Colors.white, size: 48),
              const SizedBox(height: AppSizes.s16),
              Text(
                messageKey.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('qr_scan_title'.tr(), style: const TextStyle(color: Colors.white)),
        actions: [
          // Browsers don't support the flashlight
          if (!kIsWeb) IconButton(
            icon: Icon(_torchOn ? Icons.flash_on : Icons.flash_off),
            tooltip: 'qr_scan_torch'.tr(),
            onPressed: () {
              controller.toggleTorch();
              setState(() => _torchOn = !_torchOn);
            },
          ),
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final double side = size.width * 0.7;
        final Rect frame = Rect.fromCenter(
          center: Offset(size.width / 2, size.height * 0.46),
          width: side,
          height: side,
        );
        return Stack(
          children: [
            // the whole preview is scanned; the frame only shows where to aim
            Positioned.fill(
              child: MobileScanner(
                controller: controller,
                onDetect: _onBarcodeDetected,
                errorBuilder: _buildCameraError,
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _scanLine,
                  builder: (_, __) => CustomPaint(
                    painter: _QrFramePainter(frame: frame, lineProgress: _scanLine.value),
                  ),
                ),
              ),
            ),
            // what to do: above the frame
            Positioned(
              left: 24,
              right: 24,
              bottom: size.height - frame.top + 16,
              child: Text(
                'qr_scan_instruction'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
              ),
            ),
            // why + tip: below the frame
            Positioned(
              left: 24,
              right: 24,
              top: frame.bottom + 18,
              child: Column(
                children: [
                  _InfoRow(icon: Icons.info_outline, text: 'qr_scan_reason'.tr(), color: Colors.white),
                  const SizedBox(height: AppSizes.s8),
                  _InfoRow(icon: Icons.lightbulb_outline, text: 'qr_scan_tip'.tr(), color: Colors.white70),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(top: AppSizes.s2), child: Icon(icon, color: color, size: 18)),
        const SizedBox(width: AppSizes.s8),
        Expanded(child: Text(text, style: TextStyle(color: color, fontSize: 13.5, height: 1.4))),
      ],
    );
  }
}

/// Dims everything outside the square, draws corner brackets and a moving scan line.
class _QrFramePainter extends CustomPainter {
  _QrFramePainter({required this.frame, required this.lineProgress});

  final Rect frame;
  final double lineProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final rounded = RRect.fromRectAndRadius(frame, const Radius.circular(16));
    canvas.drawPath(
      Path.combine(PathOperation.difference, Path()..addRect(Offset.zero & size), Path()..addRRect(rounded)),
      Paint()..color = Colors.black.withValues(alpha: 0.6),
    );

    // thin outline + thick corners
    canvas.drawRRect(
      rounded,
      Paint()
        ..color = Colors.white24
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    final corner = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final double len = frame.width * 0.16;
    final l = frame.left, t = frame.top, r = frame.right, b = frame.bottom;
    for (final path in [
      Path()..moveTo(l, t + len)..lineTo(l, t + 16)..quadraticBezierTo(l, t, l + 16, t)..lineTo(l + len, t),
      Path()..moveTo(r - len, t)..lineTo(r - 16, t)..quadraticBezierTo(r, t, r, t + 16)..lineTo(r, t + len),
      Path()..moveTo(l, b - len)..lineTo(l, b - 16)..quadraticBezierTo(l, b, l + 16, b)..lineTo(l + len, b),
      Path()..moveTo(r - len, b)..lineTo(r - 16, b)..quadraticBezierTo(r, b, r, b - 16)..lineTo(r, b - len),
    ]) {
      canvas.drawPath(path, corner);
    }

    // scan line
    final double y = frame.top + 12 + (frame.height - 24) * lineProgress;
    canvas.drawLine(
      Offset(frame.left + 14, y),
      Offset(frame.right - 14, y),
      Paint()
        ..shader = LinearGradient(colors: [
          Colors.greenAccent.withValues(alpha: 0),
          Colors.greenAccent,
          Colors.greenAccent.withValues(alpha: 0),
        ]).createShader(Rect.fromLTWH(frame.left, y - 1, frame.width, 2))
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(_QrFramePainter old) => old.lineProgress != lineProgress || old.frame != frame;
}
