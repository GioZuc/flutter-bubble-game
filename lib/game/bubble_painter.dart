import 'package:flutter/material.dart';
import '../models/bubble.dart';

class BubblePainter extends CustomPainter {
  final List<Bubble> bubbles;

  BubblePainter(this.bubbles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final b in bubbles) {
      _drawBubble(canvas, b);
    }
  }

  void _drawBubble(Canvas canvas, Bubble b) {
    final center = Offset(b.x, b.y);
    final r = b.radius;

    // Outer ring
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.lightBlue.withOpacity(0.7);
    canvas.drawCircle(center, r, ringPaint);

    // Translucent fill
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.lightBlue.withOpacity(0.12);
    canvas.drawCircle(center, r, fillPaint);

    // Specular highlight (small white arc top-left)
    final highlightPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.6);
    canvas.drawCircle(
      Offset(b.x - r * 0.3, b.y - r * 0.35),
      r * 0.22,
      highlightPaint,
    );

    // Second smaller highlight
    final highlight2 = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.3);
    canvas.drawCircle(
      Offset(b.x + r * 0.25, b.y + r * 0.3),
      r * 0.1,
      highlight2,
    );
  }

  @override
  bool shouldRepaint(BubblePainter old) => true;
}
