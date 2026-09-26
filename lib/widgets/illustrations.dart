import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Renders the Welcome Screen Avatar & 3D Question Mark illustration
class WelcomeIllustration extends StatelessWidget {
  final double size;

  const WelcomeIllustration({super.key, this.size = 240});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _WelcomePainter(),
      ),
    );
  }
}

class _WelcomePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Large Golden Yellow Question Mark in background
    final qMarkPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFDF00), Color(0xFFFFB703), Color(0xFFFB8500)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.16
      ..strokeCap = StrokeCap.round;

    final qPath = Path();
    qPath.moveTo(size.width * 0.32, size.height * 0.28);
    qPath.cubicTo(
      size.width * 0.35, size.height * 0.08,
      size.width * 0.72, size.height * 0.10,
      size.width * 0.70, size.height * 0.34,
    );
    qPath.cubicTo(
      size.width * 0.68, size.height * 0.50,
      size.width * 0.48, size.height * 0.52,
      size.width * 0.48, size.height * 0.64,
    );
    canvas.drawPath(qPath, qMarkPaint);

    // Question Mark Dot
    final dotPaint = Paint()
      ..color = const Color(0xFFFB8500)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.48, size.height * 0.74), size.width * 0.075, dotPaint);

    // 2. Floating Fun Elements
    // Pink question mark on right
    final pinkPaint = Paint()
      ..color = const Color(0xFFFF4D6D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.045
      ..strokeCap = StrokeCap.round;
    final smallQ = Path();
    smallQ.moveTo(size.width * 0.78, size.height * 0.38);
    smallQ.cubicTo(
      size.width * 0.82, size.height * 0.32,
      size.width * 0.88, size.height * 0.35,
      size.width * 0.85, size.height * 0.44,
    );
    smallQ.lineTo(size.width * 0.82, size.height * 0.50);
    canvas.drawPath(smallQ, pinkPaint);
    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.54), size.width * 0.018, Paint()..color = const Color(0xFFFF4D6D));

    // Green capsule pill on top left
    final capsulePaint = Paint()..color = const Color(0xFF2EC4B6);
    canvas.save();
    canvas.translate(size.width * 0.22, size.height * 0.32);
    canvas.rotate(-math.pi / 6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-20, -8, 40, 16), const Radius.circular(8)),
      capsulePaint,
    );
    canvas.restore();

    // Yellow floating orb on bottom left
    final orbPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFFEA79), Color(0xFFFFB703)],
        center: Alignment(-0.3, -0.3),
      ).createShader(Rect.fromCircle(center: Offset(size.width * 0.25, size.height * 0.58), radius: 18));
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.58), 18, orbPaint);

    // Purple Curved sparkles
    final sparklePaint = Paint()
      ..color = const Color(0xFF9D4EDD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(size.width * 0.24, size.height * 0.22), Offset(size.width * 0.29, size.height * 0.16), sparklePaint);
    canvas.drawLine(Offset(size.width * 0.68, size.height * 0.20), Offset(size.width * 0.72, size.height * 0.26), sparklePaint);

    // 3. Central Cute Avatar with Purple Hair & Cheerful Face
    final headCenter = Offset(size.width * 0.52, size.height * 0.45);
    final headRadius = size.width * 0.20;

    // Face base
    final skinPaint = Paint()..color = const Color(0xFFFFE0BD);
    canvas.drawCircle(headCenter, headRadius, skinPaint);

    // Ears
    canvas.drawCircle(Offset(headCenter.dx - headRadius * 0.95, headCenter.dy + 4), 10, skinPaint);
    canvas.drawCircle(Offset(headCenter.dx + headRadius * 0.95, headCenter.dy + 4), 10, skinPaint);

    // Purple Curly Hair
    final hairPaint = Paint()..color = const Color(0xFF7209B7);
    final hairPositions = [
      Offset(headCenter.dx - 35, headCenter.dy - 35),
      Offset(headCenter.dx - 15, headCenter.dy - 45),
      Offset(headCenter.dx + 15, headCenter.dy - 45),
      Offset(headCenter.dx + 35, headCenter.dy - 35),
      Offset(headCenter.dx - 40, headCenter.dy - 15),
      Offset(headCenter.dx + 40, headCenter.dy - 15),
      Offset(headCenter.dx, headCenter.dy - 40),
    ];
    for (final pos in hairPositions) {
      canvas.drawCircle(pos, 22, hairPaint);
    }

    // Eyes
    final eyePaint = Paint()..color = const Color(0xFF240046);
    canvas.drawOval(Rect.fromCenter(center: Offset(headCenter.dx - 16, headCenter.dy - 2), width: 8, height: 11), eyePaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(headCenter.dx + 16, headCenter.dy - 2), width: 8, height: 11), eyePaint);

    // Cheerful Rosy Blush
    final blushPaint = Paint()..color = const Color(0xFFFF85A1).withValues(alpha: 0.5);
    canvas.drawCircle(Offset(headCenter.dx - 24, headCenter.dy + 10), 9, blushPaint);
    canvas.drawCircle(Offset(headCenter.dx + 24, headCenter.dy + 10), 9, blushPaint);

    // Cute Smile
    final smilePaint = Paint()
      ..color = const Color(0xFF5A189A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(headCenter.dx, headCenter.dy + 10), width: 18, height: 14),
      0.2,
      math.pi - 0.4,
      false,
      smilePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Renders the Configuration Screen Gears & Sliders Illustration
class ConfigIllustration extends StatelessWidget {
  final double size;

  const ConfigIllustration({super.key, this.size = 180});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ConfigPainter(),
      ),
    );
  }
}

class _ConfigPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background soft blue card
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.5), width: w * 0.78, height: h * 0.78),
      const Radius.circular(24),
    );
    final cardPaint = Paint()..color = const Color(0xFFD6EFF8);
    canvas.drawRRect(cardRect, cardPaint);
    canvas.drawRRect(cardRect, Paint()..color = const Color(0xFF90E0EF)..style = PaintingStyle.stroke..strokeWidth = 2);

    // Gear on the top left
    final gearCenter = Offset(w * 0.32, h * 0.32);
    final gearPaint = Paint()..color = const Color(0xFFF4A261);
    canvas.drawCircle(gearCenter, w * 0.15, gearPaint);
    canvas.drawCircle(gearCenter, w * 0.06, Paint()..color = const Color(0xFFD6EFF8));

    // Gear teeth
    final teethPaint = Paint()
      ..color = const Color(0xFFF4A261)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4);
      final p1 = gearCenter + Offset(math.cos(angle) * (w * 0.14), math.sin(angle) * (w * 0.14));
      final p2 = gearCenter + Offset(math.cos(angle) * (w * 0.18), math.sin(angle) * (w * 0.18));
      canvas.drawLine(p1, p2, teethPaint);
    }

    // Toggle switch track 1
    final track1 = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.50, h * 0.28, w * 0.36, h * 0.12),
      const Radius.circular(16),
    );
    canvas.drawRRect(track1, Paint()..color = const Color(0xFFE63946));
    canvas.drawRRect(track1, Paint()..color = const Color(0xFF0077B6)..style = PaintingStyle.stroke..strokeWidth = 2);
    // Switch knob 1
    canvas.drawCircle(Offset(w * 0.78, h * 0.34), h * 0.05, Paint()..color = const Color(0xFFFFB5A7));

    // Toggle switch track 2
    final track2 = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.50, h * 0.46, w * 0.36, h * 0.12),
      const Radius.circular(16),
    );
    canvas.drawRRect(track2, Paint()..color = const Color(0xFFE63946));
    canvas.drawRRect(track2, Paint()..color = const Color(0xFF0077B6)..style = PaintingStyle.stroke..strokeWidth = 2);
    // Switch knob 2
    canvas.drawCircle(Offset(w * 0.56, h * 0.52), h * 0.05, Paint()..color = const Color(0xFFFFB5A7));

    // Stylized Hand pointing
    final armPaint = Paint()..color = const Color(0xFF0077B6);
    final handPaint = Paint()..color = const Color(0xFF6F4E37);

    // Sleeve
    final sleevePath = Path();
    sleevePath.moveTo(w * 0.22, h * 0.90);
    sleevePath.lineTo(w * 0.42, h * 0.65);
    sleevePath.lineTo(w * 0.52, h * 0.72);
    sleevePath.lineTo(w * 0.34, h * 0.95);
    sleevePath.close();
    canvas.drawPath(sleevePath, armPaint);

    // Hand & finger pointing to switch 1
    final handPath = Path();
    handPath.moveTo(w * 0.40, h * 0.68);
    handPath.lineTo(w * 0.55, h * 0.50);
    handPath.lineTo(w * 0.58, h * 0.35); // pointing finger tip
    handPath.lineTo(w * 0.64, h * 0.36);
    handPath.lineTo(w * 0.62, h * 0.54);
    handPath.lineTo(w * 0.50, h * 0.74);
    handPath.close();
    canvas.drawPath(handPath, handPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Renders Confetti Party Horn for High Score (Congratulation)
class ConfettiIllustration extends StatelessWidget {
  final double size;

  const ConfettiIllustration({super.key, this.size = 200});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ConfettiPainter(),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Party Popper Horn Cone
    final hornPath = Path();
    hornPath.moveTo(w * 0.65, h * 0.88); // tip of cone
    hornPath.lineTo(w * 0.36, h * 0.55); // left rim
    hornPath.lineTo(w * 0.76, h * 0.45); // right rim
    hornPath.close();

    // Horn base color (pink)
    final hornPaint = Paint()..color = const Color(0xFFFF758F);
    canvas.drawPath(hornPath, hornPaint);

    // White stripes on horn
    final stripePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w * 0.45, h * 0.65), Offset(w * 0.68, h * 0.60), stripePaint);
    canvas.drawLine(Offset(w * 0.55, h * 0.77), Offset(w * 0.67, h * 0.74), stripePaint);

    // Rim Oval opening
    canvas.save();
    canvas.translate(w * 0.56, h * 0.50);
    canvas.rotate(-0.25);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: w * 0.42, height: h * 0.16),
      Paint()..color = const Color(0xFFFFB3C1),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: w * 0.36, height: h * 0.12),
      Paint()..color = const Color(0xFFC9184A),
    );
    canvas.restore();

    // Confetti pieces bursting out!
    final confettiColors = [
      const Color(0xFF00B4D8), // Blue
      const Color(0xFFFFB703), // Yellow
      const Color(0xFF52B788), // Green
      const Color(0xFFFF4D6D), // Red-pink
      const Color(0xFF9D4EDD), // Purple
      const Color(0xFFFB8500), // Orange
    ];

    final confettiRects = [
      // Top left
      Rect.fromLTWH(w * 0.25, h * 0.18, 12, 6),
      Rect.fromLTWH(w * 0.38, h * 0.12, 10, 8),
      Rect.fromLTWH(w * 0.48, h * 0.20, 8, 14),
      // Top right
      Rect.fromLTWH(w * 0.62, h * 0.14, 14, 6),
      Rect.fromLTWH(w * 0.75, h * 0.22, 10, 10),
      Rect.fromLTWH(w * 0.80, h * 0.35, 7, 12),
      // Left streamers
      Rect.fromLTWH(w * 0.18, h * 0.32, 12, 5),
      Rect.fromLTWH(w * 0.28, h * 0.40, 15, 6),
    ];

    for (int i = 0; i < confettiRects.length; i++) {
      final paint = Paint()..color = confettiColors[i % confettiColors.length];
      canvas.save();
      final rect = confettiRects[i];
      canvas.translate(rect.center.dx, rect.center.dy);
      canvas.rotate(i * 0.65);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: rect.width, height: rect.height), const Radius.circular(3)),
        paint,
      );
      canvas.restore();
    }

    // Streamer Ribbons (curves)
    final ribbonPaint = Paint()
      ..color = const Color(0xFF0077B6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final ribbon1 = Path();
    ribbon1.moveTo(w * 0.40, h * 0.25);
    ribbon1.cubicTo(w * 0.38, h * 0.18, w * 0.45, h * 0.14, w * 0.42, h * 0.08);
    canvas.drawPath(ribbon1, ribbonPaint);

    final ribbon2 = Path();
    ribbon2.moveTo(w * 0.68, h * 0.28);
    ribbon2.cubicTo(w * 0.72, h * 0.20, w * 0.66, h * 0.14, w * 0.70, h * 0.08);
    canvas.drawPath(ribbon2, Paint()..color = const Color(0xFFFFB703)..style = PaintingStyle.stroke..strokeWidth = 3.5..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
