import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../data/models/mood_entry.dart';

class MoodFace extends StatelessWidget {
  final MoodType type;
  final double size;
  final Color? color;

  const MoodFace({super.key, required this.type, this.size = 100, this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: MoodFacePainter(type: type, color: color ?? _getMoodColor(type)),
    );
  }

  Color _getMoodColor(MoodType type) {
    switch (type) {
      case MoodType.sad:
        return Colors.indigo.shade400;
      case MoodType.neutral:
        return Colors.amber.shade400;
      case MoodType.happy:
        return Colors.teal.shade400;
    }
  }
}

class MoodFacePainter extends CustomPainter {
  final MoodType type;
  final Color color;

  MoodFacePainter({required this.type, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Face Background
    final facePaint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, facePaint);

    // Face Border
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.05
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, borderPaint);

    final featurePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06
      ..strokeCap = StrokeCap.round;

    // Eyes
    final eyeRadius = size.width * 0.08;
    final eyeY = center.dy - size.height * 0.15;
    final eyeOffsetX = size.width * 0.2;

    // Left Eye
    canvas.drawCircle(
      Offset(center.dx - eyeOffsetX, eyeY),
      eyeRadius,
      Paint()..color = color,
    );

    // Right Eye
    canvas.drawCircle(
      Offset(center.dx + eyeOffsetX, eyeY),
      eyeRadius,
      Paint()..color = color,
    );

    // Mouth
    final mouthY = center.dy + size.height * 0.15;
    final mouthWidth = size.width * 0.4;
    final mouthRect = Rect.fromCenter(
      center: Offset(center.dx, mouthY),
      width: mouthWidth,
      height: size.height * 0.2,
    );

    switch (type) {
      case MoodType.happy:
        // Smile
        canvas.drawArc(mouthRect, 0, math.pi, false, featurePaint);
        // Happy eyebrows
        _drawEyebrow(
          canvas,
          center.dx - eyeOffsetX,
          eyeY - eyeRadius * 2.5,
          size.width * 0.15,
          -0.3,
          featurePaint,
        );
        _drawEyebrow(
          canvas,
          center.dx + eyeOffsetX,
          eyeY - eyeRadius * 2.5,
          size.width * 0.15,
          0.3,
          featurePaint,
        );
        break;
      case MoodType.neutral:
        // Straight line
        canvas.drawLine(
          Offset(center.dx - mouthWidth / 2, mouthY),
          Offset(center.dx + mouthWidth / 2, mouthY),
          featurePaint,
        );
        break;
      case MoodType.sad:
        // Frown
        canvas.drawArc(
          mouthRect.translate(0, size.height * 0.1),
          math.pi,
          math.pi,
          false,
          featurePaint,
        );
        // Sad eyebrows
        _drawEyebrow(
          canvas,
          center.dx - eyeOffsetX,
          eyeY - eyeRadius * 2,
          size.width * 0.15,
          0.4,
          featurePaint,
        );
        _drawEyebrow(
          canvas,
          center.dx + eyeOffsetX,
          eyeY - eyeRadius * 2,
          size.width * 0.15,
          -0.4,
          featurePaint,
        );
        break;
    }
  }

  void _drawEyebrow(
    Canvas canvas,
    double x,
    double y,
    double width,
    double tilt,
    Paint paint,
  ) {
    final path = Path();
    path.moveTo(x - width / 2, y + (width * tilt));
    path.lineTo(x + width / 2, y - (width * tilt));
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant MoodFacePainter oldDelegate) {
    return oldDelegate.type != type || oldDelegate.color != color;
  }
}
