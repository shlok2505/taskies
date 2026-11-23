import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SkylineBackground extends StatelessWidget {
  const SkylineBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: SizedBox(
        height: 300,
        width: double.infinity,
        child: CustomPaint(painter: _SkylinePainter()),
      ),
    );
  }
}

class _SkylinePainter extends CustomPainter {
  const _SkylinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Glowing moon
    final moon = Offset(w * 0.68, h * 0.6);
    canvas.drawCircle(
      moon,
      95,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.primary.withAlpha(140),
            AppColors.primary.withAlpha(0),
          ],
        ).createShader(Rect.fromCircle(center: moon, radius: 95)),
    );
    canvas.drawCircle(
      moon,
      50,
      Paint()..color = AppColors.primary.withAlpha(110),
    );

    // Mountains
    final mountains = Path()
      ..moveTo(0, h * 0.78)
      ..lineTo(w * 0.16, h * 0.52)
      ..lineTo(w * 0.3, h * 0.68)
      ..lineTo(w * 0.48, h * 0.42)
      ..lineTo(w * 0.68, h * 0.72)
      ..lineTo(w * 0.84, h * 0.58)
      ..lineTo(w, h * 0.74)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(mountains, Paint()..color = const Color(0xFF120B22));

    // City skyline on the right
    final buildings = Paint()..color = const Color(0xFF0D0818);
    const heights = [0.22, 0.34, 0.26, 0.42, 0.3, 0.38, 0.24];
    final start = w * 0.55;
    final bw = (w - start) / heights.length;
    for (var i = 0; i < heights.length; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
          start + i * bw,
          h - h * heights[i],
          bw - 3,
          h * heights[i],
        ),
        buildings,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
