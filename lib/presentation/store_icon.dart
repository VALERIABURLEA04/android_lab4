import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

enum StoreGlyph {
  menu,
  notifications,
  women,
  men,
  glasses,
  lipstick,
  back,
  chevron,
  bag,
  pencil,
  star,
}

class StoreIcon extends StatelessWidget {
  const StoreIcon(
    this.glyph, {
    super.key,
    required this.width,
    required this.height,
    required this.color,
  });

  final StoreGlyph glyph;
  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size(width, height),
    painter: _StoreIconPainter(glyph, color),
  );
}

class _StoreIconPainter extends CustomPainter {
  const _StoreIconPainter(this.glyph, this.color);

  final StoreGlyph glyph;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);
    final line = Paint()
      ..color = color
      ..strokeWidth = 1.25
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = color;

    switch (glyph) {
      case StoreGlyph.menu:
        line.strokeWidth = 2.1;
        canvas.drawLine(const Offset(1.4, 1.4), const Offset(13.2, 1.4), line);
        canvas.drawLine(
          const Offset(1.4, 11.7),
          const Offset(22.6, 11.7),
          line,
        );
        canvas.drawLine(
          const Offset(1.4, 22.6),
          const Offset(22.6, 22.6),
          line,
        );
      case StoreGlyph.notifications:
        line.strokeWidth = 1.5;
        canvas.drawPath(
          Path()
            ..moveTo(5.1, 16.3)
            ..quadraticBezierTo(6.9, 14.9, 7, 11.4)
            ..lineTo(7.1, 9)
            ..cubicTo(7.3, 5.6, 9.2, 3.1, 12, 3.1)
            ..cubicTo(15.4, 3.1, 17.3, 5.4, 17.4, 8.9)
            ..lineTo(17.6, 11.4)
            ..quadraticBezierTo(17.7, 14.8, 19.5, 16.3)
            ..lineTo(19.5, 17.4)
            ..lineTo(5.1, 17.4)
            ..close()
            ..moveTo(10, 17.8)
            ..quadraticBezierTo(12.2, 22.4, 14.6, 17.8),
          line,
        );
        const badge = Offset(16.7, 7);
        canvas.drawCircle(badge, 3.75, Paint()..color = Colors.white);
        canvas.drawCircle(badge, 3.1, Paint()..color = const Color(0xFFF43F70));
      case StoreGlyph.women:
        canvas.drawCircle(const Offset(12, 8.2), 6.1, line);
        canvas.drawLine(const Offset(12, 14.3), const Offset(12, 23), line);
        canvas.drawLine(
          const Offset(8.5, 18.6),
          const Offset(15.5, 18.6),
          line,
        );
      case StoreGlyph.men:
        canvas.drawCircle(const Offset(9.2, 14.7), 6.2, line);
        canvas.drawPath(
          Path()
            ..moveTo(13.8, 10.3)
            ..lineTo(21.3, 2.8)
            ..moveTo(15.4, 2.8)
            ..lineTo(21.3, 2.8)
            ..lineTo(21.3, 8.7),
          line,
        );
      case StoreGlyph.glasses:
        for (final left in [1.8, 14.1]) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(left, 10.4, 8.1, 8.2),
              const Radius.circular(2.1),
            ),
            line,
          );
        }
        canvas.drawPath(
          Path()
            ..moveTo(9.9, 13.2)
            ..quadraticBezierTo(12, 11.6, 14.1, 13.2)
            ..moveTo(3, 10.5)
            ..lineTo(8, 5.3)
            ..lineTo(9.8, 5.3)
            ..moveTo(21, 10.5)
            ..lineTo(16, 5.3)
            ..lineTo(14.3, 5.3),
          line,
        );
      case StoreGlyph.lipstick:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(9.5, 13.2, 5, 9.1),
            const Radius.circular(1.1),
          ),
          line,
        );
        canvas.drawPath(
          Path()
            ..moveTo(12, 13.2)
            ..lineTo(12, 5.6)
            ..moveTo(9.7, 1.5)
            ..lineTo(14.3, 1.5)
            ..lineTo(13.1, 5.6)
            ..lineTo(10.9, 5.6)
            ..close(),
          line,
        );
      case StoreGlyph.back:
        line.strokeWidth = 4.2;
        canvas.drawPath(
          Path()
            ..moveTo(20, 2.5)
            ..lineTo(4, 12)
            ..lineTo(20, 21.5),
          line,
        );
      case StoreGlyph.chevron:
        line.strokeWidth = 3.7;
        canvas.drawPath(
          Path()
            ..moveTo(3, 5)
            ..lineTo(12, 19)
            ..lineTo(21, 5),
          line,
        );
      case StoreGlyph.bag:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(2.5, 7.3, 19, 14.8),
            const Radius.circular(3.5),
          ),
          fill,
        );
        line.strokeWidth = 1.8;
        canvas.drawPath(
          Path()
            ..moveTo(8.1, 9)
            ..lineTo(8.1, 6.4)
            ..cubicTo(8.1, 1.2, 15.9, 1.2, 15.9, 6.4)
            ..lineTo(15.9, 9),
          line,
        );
        final cutout = Paint()..color = const Color(0xFF343434);
        canvas.drawCircle(const Offset(8.1, 9.1), .8, cutout);
        canvas.drawCircle(const Offset(15.9, 9.1), .8, cutout);
      case StoreGlyph.pencil:
        canvas.drawPath(
          Path()
            ..moveTo(2.5, 21.5)
            ..lineTo(3.4, 15.7)
            ..lineTo(14.8, 4.3)
            ..lineTo(19.7, 9.2)
            ..lineTo(8.3, 20.6)
            ..close()
            ..moveTo(16, 3.1)
            ..lineTo(17.5, 1.6)
            ..quadraticBezierTo(18.3, .8, 19.1, 1.6)
            ..lineTo(22.4, 4.9)
            ..quadraticBezierTo(23.2, 5.7, 22.4, 6.5)
            ..lineTo(20.9, 8)
            ..close(),
          fill,
        );
      case StoreGlyph.star:
        final star = Path();
        for (var i = 0; i < 10; i++) {
          final angle = i * math.pi / 5 - math.pi / 2;
          final radius = i.isEven ? 12.4 : 5.4;
          final x = 12 + radius * math.cos(angle);
          final y = 12.6 + radius * math.sin(angle);
          if (i == 0) {
            star.moveTo(x, y);
          } else {
            star.lineTo(x, y);
          }
        }
        canvas.drawPath(star..close(), fill);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_StoreIconPainter oldDelegate) =>
      oldDelegate.glyph != glyph || oldDelegate.color != color;
}
