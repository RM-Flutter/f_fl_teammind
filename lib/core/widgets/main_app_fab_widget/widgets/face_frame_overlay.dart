import 'package:app_test/core/constants/app_sizes.dart';
import 'package:flutter/material.dart';

/// Face guide drawn over a camera preview: an oval frame (outside dimmed), what to do above it
/// and why it is asked below it, so the employee knows what is expected when the camera opens.
class FaceFrameOverlay extends StatelessWidget {
  const FaceFrameOverlay({
    super.key,
    required this.instruction,
    required this.reason,
    this.tip,
    this.status,
    this.hint,
    this.frameColor = Colors.white,
  });

  /// What to do now (e.g. "Place your face inside the frame", "Smile")
  final String instruction;

  /// Why the face is checked
  final String reason;

  /// Short advice for a good photo
  final String? tip;

  /// Live feedback (e.g. "No face detected"), shown under the instruction
  final String? status;

  /// Optional animated hint shown with the instruction
  final Widget? hint;

  final Color frameColor;

  /// Oval position inside a box of [size] (shared by the painter and the texts)
  static Rect ovalRect(Size size) {
    final double width = size.width * 0.66;
    final double height = width * 1.3;
    final Offset center = Offset(size.width / 2, size.height * 0.56);
    return Rect.fromCenter(center: center, width: width, height: height);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final size = Size(constraints.maxWidth, constraints.maxHeight);
      final oval = ovalRect(size);
      return Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _FaceFramePainter(oval: oval, color: frameColor)),
            ),
          ),
          // what to do: above the frame
          Positioned(
            left: 20,
            right: 20,
            bottom: size.height - oval.top + 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16, vertical: AppSizes.s12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    instruction,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                  if (hint != null) ...[const SizedBox(height: AppSizes.s6), hint!],
                  if (status != null && status!.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.s6),
                    Text(
                      status!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.yellow, fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // why: below the frame
          Positioned(
            left: 20,
            right: 20,
            top: oval.bottom + 12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: AppSizes.s2),
                      child: Icon(Icons.info_outline, color: Colors.white70, size: 18),
                    ),
                    const SizedBox(width: AppSizes.s8),
                    Expanded(
                      child: Text(
                        reason,
                        style: const TextStyle(color: Colors.white, fontSize: 13.5, height: 1.4),
                      ),
                    ),
                  ],
                ),
                if (tip != null) ...[
                  const SizedBox(height: AppSizes.s6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: AppSizes.s2),
                        child: Icon(Icons.lightbulb_outline, color: Colors.white70, size: 18),
                      ),
                      const SizedBox(width: AppSizes.s8),
                      Expanded(
                        child: Text(
                          tip!,
                          style: const TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _FaceFramePainter extends CustomPainter {
  _FaceFramePainter({required this.oval, required this.color});

  final Rect oval;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final outside = Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & size),
      Path()..addOval(oval),
    );
    canvas.drawPath(outside, Paint()..color = Colors.black.withValues(alpha: 0.55));
    canvas.drawOval(
      oval,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5,
    );
  }

  @override
  bool shouldRepaint(_FaceFramePainter old) => old.oval != oval || old.color != color;
}
