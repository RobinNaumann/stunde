import 'dart:math' as math;

import 'package:elbe/elbe.dart';

class DonutChart extends StatelessWidget {
  final double holeSection;
  final double size;
  final List<DonutChartSegment> segments;

  const DonutChart(
      {super.key,
      required this.segments,
      required this.size,
      this.holeSection = 0.5});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(context.rem(size)),
      painter: _DonutChartPainter(segments, holeSection),
    );
  }
}

Color _stringColor(String? key) => HSLColor.fromColor(const Color(0xFF888888))
    .withSaturation(key == null ? 0 : .7)
    .withHue("d$key".hashCode % 360)
    .toColor();

class DonutChartSegment {
  final double value;
  final String? key;
  final String label;

  DonutChartSegment(
      {required this.value, required this.key, required this.label});

  Color get color => _stringColor(key);
}

class _DonutChartPainter extends CustomPainter {
  final double holeSection;
  final List<DonutChartSegment> segments;

  _DonutChartPainter(this.segments, this.holeSection);

  @override
  void paint(Canvas canvas, Size size) {
    double wd = (math.min(size.width, size.height) / 2) * holeSection;
    final total = segments.fold(0.0, (sum, segment) => sum + segment.value);
    if (total == 0) return;
    double startAngle = -math.pi / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = wd;

    for (var segment in segments) {
      final sweepAngle = (segment.value / total) * 2 * math.pi;
      paint.color = segment.color;
      canvas.drawArc(
        Rect.fromLTWH(wd / 2, wd / 2, size.width - wd, size.height - wd),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
