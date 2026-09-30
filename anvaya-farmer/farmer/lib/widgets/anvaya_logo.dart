import 'package:flutter/material.dart';

/// Pixel-accurate Anvaya mark widget using the official asset with vector fallback.
class AnvayaLogoMark extends StatelessWidget {
  final double size;
  final Color? color;

  const AnvayaLogoMark({
    super.key,
    this.size = 38.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/anvaya_mark.png',
      width: size * 0.9,
      height: size,
      fit: BoxFit.contain,
      color: color,
      errorBuilder: (context, error, stackTrace) {
        // High-fidelity fallback painter if asset fails
        return SizedBox(
          width: size * 0.9,
          height: size,
          child: CustomPaint(
            painter: _AnvayaMarkPainter(color: color ?? const Color(0xFFE2E8F0)),
          ),
        );
      },
    );
  }
}

class _AnvayaMarkPainter extends CustomPainter {
  final Color color;

  _AnvayaMarkPainter({required this.color});

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
    stem.moveTo(w * 0.46, h * 0.02);
    stem.lineTo(w * 0.64, h * 0.02);
    stem.lineTo(w * 0.98, h * 0.98);
    stem.lineTo(w * 0.70, h * 0.98);
    stem.close();
    canvas.drawPath(stem, paint);
  }

  @override
  bool shouldRepaint(covariant _AnvayaMarkPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Full elegant Anvaya wordmark using the official upscaled image asset.
class AnvayaWordmark extends StatelessWidget {
  final double height;
  final double? width;
  final Color? color;

  const AnvayaWordmark({
    super.key,
    this.height = 70.0,
    this.width,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/anvaya_upscaled.png',
      height: height,
      width: width,
      fit: BoxFit.contain,
      color: color,
    );
  }
}

// Backward-compatible aliases
typedef AegisLogoMark = AnvayaLogoMark;
typedef AegisWordmark = AnvayaWordmark;
