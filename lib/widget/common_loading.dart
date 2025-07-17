import 'package:base_app/core/extension/theme_extension.dart';
import 'package:flutter/material.dart';

class CommonLoading extends StatefulWidget {
  const CommonLoading({
    Key? key,
  }) : super(key: key);

  @override
  State<CommonLoading> createState() => _CommonLoadingState();
}

class _CommonLoadingState extends State<CommonLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 30,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: TwoColorCircularPainter(
              progress: _controller.value,
              color1: context.colors.primary,
              color2: context.colors.secondary,
              strokeWidth: 8,
            ),
          );
        },
      ),
    );
  }
}

class TwoColorCircularPainter extends CustomPainter {
  final double progress;
  final Color color1;
  final Color color2;
  final double strokeWidth;

  TwoColorCircularPainter({
    required this.progress,
    required this.color1,
    required this.color2,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle (optional)
    final backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Calculate rotation angle
    final startAngle = -90 * (3.14159 / 180) + (progress * 2 * 3.14159);

    // First arc (color1)
    final paint1 = Paint()
      ..color = color1
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      3.14159, // 180 degrees
      false,
      paint1,
    );

    // Second arc (color2)
    final paint2 = Paint()
      ..color = color2
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + 3.14159, // Start where first arc ends
      3.14159, // 180 degrees
      false,
      paint2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
