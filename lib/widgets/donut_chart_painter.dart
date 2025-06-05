import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:plate_pal/utils/app_colors.dart';

class DonutChartPainter extends CustomPainter {
  final double proteinPercentage; // 0.0 to 1.0
  final double carbsPercentage;   // 0.0 to 1.0
  final double fatsPercentage;    // 0.0 to 1.0
  final double strokeWidth;

  DonutChartPainter({
    required this.proteinPercentage,
    required this.carbsPercentage,
    required this.fatsPercentage,
    this.strokeWidth = 20.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - strokeWidth / 2;
    const startAngle = -math.pi / 2; // Start from the top

    // Background circle (light grey or very light version of main colors)
    final backgroundPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, backgroundPaint);
    
    // Protein arc
    final proteinPaint = Paint()
      ..color = AppColors.proteinColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    double proteinSweepAngle = 2 * math.pi * proteinPercentage;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      proteinSweepAngle,
      false,
      proteinPaint,
    );

    // Carbs arc
    final carbsPaint = Paint()
      ..color = AppColors.carbsColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    double carbsSweepAngle = 2 * math.pi * carbsPercentage;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + proteinSweepAngle,
      carbsSweepAngle,
      false,
      carbsPaint,
    );

    // Fats arc
    final fatsPaint = Paint()
      ..color = AppColors.fatsColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    // Fats sweep angle fills the rest, ensuring it sums to 1.0 or 2*pi
    double fatsSweepAngle = 2 * math.pi * fatsPercentage;
     // To avoid overdrawing or gaps due to floating point inaccuracies:
    if (proteinPercentage + carbsPercentage + fatsPercentage > 0.999 && proteinPercentage + carbsPercentage + fatsPercentage < 1.001) {
       fatsSweepAngle = 2 * math.pi * (1.0 - proteinPercentage - carbsPercentage);
    }

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + proteinSweepAngle + carbsSweepAngle,
      fatsSweepAngle,
      false,
      fatsPaint,
    );
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) {
    return oldDelegate.proteinPercentage != proteinPercentage ||
        oldDelegate.carbsPercentage != carbsPercentage ||
        oldDelegate.fatsPercentage != fatsPercentage;
  }
}