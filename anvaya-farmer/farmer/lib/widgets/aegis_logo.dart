import 'package:flutter/material.dart';

/// Pixel-accurate vector representation of the Aegis / Anvaya leaf-and-stem mark.
class AegisLogoMark extends StatelessWidget {
  final double size;
  final Color color;

  const AegisLogoMark({
    super.key,
    this.size = 38.0,
    this.color = const Color(0xFFE2E8F0),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 0.9,
      height: size,
      child: CustomPaint(
        painter: _AegisMarkPainter(color: color),
      ),
    );
  }
}

class _AegisMarkPainter extends CustomPainter {
  final Color color;

  _AegisMarkPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final w = size.width;
    final h = size.height;

    // 1. Left organic leaf petal
    final leaf = Path();
    leaf.moveTo(w * 0.05, h * 0.65);
    leaf.cubicTo(
      w * 0.02, h * 0.50,
      w * 0.22, h * 0.44,
      w * 0.38, h * 0.44,
    );
    leaf.cubicTo(
      w * 0.36, h * 0.58,
      w * 0.22, h * 0.68,
      w * 0.05, h * 0.65,
    );
    leaf.close();
    canvas.drawPath(leaf, paint);

    // 2. Right slanted pillar of the letter "A"
    final stem = Path();
    stem.moveTo(w * 0.46, h * 0.02); // top-left
    stem.lineTo(w * 0.64, h * 0.02); // top-right
    stem.lineTo(w * 0.98, h * 0.98); // bottom-right
    stem.lineTo(w * 0.70, h * 0.98); // bottom-left
    stem.close();
    canvas.drawPath(stem, paint);
  }

  @override
  bool shouldRepaint(covariant _AegisMarkPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Full elegant Aegis / Anvaya wordmark matching Image 1.
class AegisWordmark extends StatelessWidget {
  final double height;
  final Color color;

  const AegisWordmark({
    super.key,
    this.height = 70.0,
    this.color = const Color(0xFFE2E8F0),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        AegisLogoMark(size: height * 0.88, color: color),
        const SizedBox(width: 2),
        Text(
          'egis',
          style: TextStyle(
            color: color,
            fontSize: height * 0.85,
            fontFamily: 'serif',
            fontWeight: FontWeight.w600,
            letterSpacing: -1.2,
          ),
        ),
      ],
    );
  }
}
