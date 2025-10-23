import 'package:flutter/material.dart';

import 'chart_segment.dart';

class DonutPainter extends CustomPainter {
  final List<ChartSegment> segments;
  
  DonutPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.shortestSide / 2;

    final total = segments.fold<double>(0, (s, e) => s + e.value);
    double start = -90 * 3.1415926535 / 180; // start from top
    final stroke = radius * 0.32;
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.butt;

    if (total == 0) {
      paint.color = Colors.grey[200]!;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 0.8),
        0,
        6.283,
        false,
        paint,
      );
    } else {
      for (final s in segments) {
        final sweep = (s.value / total) * 6.28318530718;
        paint.color = s.color.withOpacity(0.9);
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius * 0.8),
          start,
          sweep,
          false,
          paint,
        );
        start += sweep;
      }
    }

    final innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius * 0.55, innerPaint);
  }

  @override
  bool shouldRepaint(covariant DonutPainter oldDelegate) {
    return oldDelegate.segments != segments;
  }
}