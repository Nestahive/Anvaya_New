import 'package:flutter/material.dart';

/// Official Google multicolor "G" logo without any white circle.
/// Exact official Google brand geometry and brand colors.
class GoogleLogo extends StatelessWidget {
  final double size;

  const GoogleLogo({super.key, this.size = 24.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    // Official Google Brand Colors
    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // 1. Blue path: right arm and horizontal crossbar
    final bluePath = Path()
      ..moveTo(22.56, 12.25)
      ..cubicTo(22.56, 11.47, 22.49, 10.72, 22.36, 10.0)
      ..lineTo(12.0, 10.0)
      ..lineTo(12.0, 14.26)
      ..lineTo(17.92, 14.26)
      ..cubicTo(17.66, 15.63, 16.88, 16.79, 15.71, 17.57)
      ..lineTo(15.71, 20.34)
      ..lineTo(19.28, 20.34)
      ..cubicTo(21.36, 18.42, 22.56, 15.6, 22.56, 12.25)
      ..close();
    canvas.drawPath(bluePath, bluePaint);

    // 2. Green path: bottom arc
    final greenPath = Path()
      ..moveTo(12.0, 23.0)
      ..cubicTo(14.97, 23.0, 17.46, 22.02, 19.28, 20.34)
      ..lineTo(15.71, 17.57)
      ..cubicTo(14.73, 18.23, 13.48, 18.63, 12.0, 18.63)
      ..cubicTo(9.14, 18.63, 6.71, 16.7, 5.84, 14.1)
      ..lineTo(2.18, 14.1)
      ..lineTo(2.18, 16.94)
      ..cubicTo(3.99, 20.53, 7.7, 23.0, 12.0, 23.0)
      ..close();
    canvas.drawPath(greenPath, greenPaint);

    // 3. Yellow path: left arc
    final yellowPath = Path()
      ..moveTo(5.84, 14.09)
      ..cubicTo(5.62, 13.43, 5.49, 12.73, 5.49, 12.0)
      ..cubicTo(5.49, 11.27, 5.62, 10.57, 5.84, 9.91)
      ..lineTo(5.84, 7.06)
      ..lineTo(2.18, 7.06)
      ..cubicTo(1.43, 8.55, 1.0, 10.22, 1.0, 12.0)
      ..cubicTo(1.0, 13.78, 1.43, 15.45, 2.18, 16.94)
      ..lineTo(5.03, 14.72)
      ..close();
    canvas.drawPath(yellowPath, yellowPaint);

    // 4. Red path: top arc
    final redPath = Path()
      ..moveTo(12.0, 5.38)
      ..cubicTo(13.62, 5.38, 15.06, 5.94, 16.21, 7.02)
      ..lineTo(19.36, 3.87)
      ..cubicTo(17.45, 2.09, 14.97, 1.0, 12.0, 1.0)
      ..cubicTo(7.7, 1.0, 3.99, 3.47, 2.18, 7.06)
      ..lineTo(5.84, 9.9)
      ..cubicTo(6.71, 7.3, 9.14, 5.38, 12.0, 5.38)
      ..close();
    canvas.drawPath(redPath, redPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Official geometric MetaMask Fox logo matching brand specs.
class MetaMaskLogo extends StatelessWidget {
  final double size;

  const MetaMaskLogo({super.key, this.size = 24.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MetaMaskLogoPainter(),
      ),
    );
  }
}

class _MetaMaskLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 32.0;
    canvas.save();
    canvas.scale(scale, scale);

    void drawPoly(List<Offset> points, Color color) {
      if (points.isEmpty) return;
      final path = Path()..moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      path.close();
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill
          ..isAntiAlias = true,
      );
    }

    // Outer ears / head geometry
    drawPoly([const Offset(2.0, 3.0), const Offset(9.0, 10.0), const Offset(6.0, 18.0)], const Color(0xFFE2761B));
    drawPoly([const Offset(30.0, 3.0), const Offset(26.0, 18.0), const Offset(23.0, 10.0)], const Color(0xFFE2761B));

    // Ear inside
    drawPoly([const Offset(2.0, 3.0), const Offset(6.0, 18.0), const Offset(9.0, 14.0)], const Color(0xFF763D16));
    drawPoly([const Offset(30.0, 3.0), const Offset(23.0, 14.0), const Offset(26.0, 18.0)], const Color(0xFF763D16));

    // Central forehead
    drawPoly([const Offset(9.0, 10.0), const Offset(16.0, 6.0), const Offset(23.0, 10.0), const Offset(16.0, 15.0)], const Color(0xFFF6851B));

    // Side cheeks
    drawPoly([const Offset(6.0, 18.0), const Offset(10.0, 23.0), const Offset(12.0, 18.0), const Offset(9.0, 10.0)], const Color(0xFFE2761B));
    drawPoly([const Offset(26.0, 18.0), const Offset(23.0, 10.0), const Offset(20.0, 18.0), const Offset(22.0, 23.0)], const Color(0xFFE2761B));

    // Center bridge
    drawPoly([const Offset(12.0, 18.0), const Offset(16.0, 15.0), const Offset(20.0, 18.0), const Offset(16.0, 23.0)], const Color(0xFFE2761B));

    // Cheeks lower
    drawPoly([const Offset(6.0, 18.0), const Offset(10.0, 23.0), const Offset(7.0, 27.0)], const Color(0xFFCD6116));
    drawPoly([const Offset(26.0, 18.0), const Offset(25.0, 27.0), const Offset(22.0, 23.0)], const Color(0xFFCD6116));

    // Muzzle / white patches
    drawPoly([const Offset(10.0, 23.0), const Offset(16.0, 23.0), const Offset(16.0, 28.0), const Offset(7.0, 27.0)], const Color(0xFFF6851B));
    drawPoly([const Offset(22.0, 23.0), const Offset(25.0, 27.0), const Offset(16.0, 28.0), const Offset(16.0, 23.0)], const Color(0xFFF6851B));

    // Eyes
    drawPoly([const Offset(10.0, 18.0), const Offset(13.0, 17.0), const Offset(12.0, 19.5)], const Color(0xFF24292E));
    drawPoly([const Offset(22.0, 18.0), const Offset(20.0, 19.5), const Offset(19.0, 17.0)], const Color(0xFF24292E));

    // Snout tip / nose
    drawPoly([const Offset(14.5, 27.0), const Offset(17.5, 27.0), const Offset(16.0, 29.5)], const Color(0xFF161616));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
