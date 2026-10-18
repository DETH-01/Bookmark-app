import 'package:flutter/material.dart';

/// โลโก้แอพ (หนังสือเปิด + ริบบิ้นคั่นหนังสือ) วาดด้วยโค้ด ขยายได้ไม่แตก
class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _LogoPainter()),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 1024, size.height / 1024);

    const full = Rect.fromLTWH(0, 0, 1024, 1024);
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1B2F55), Color(0xFF0B1220)],
      ).createShader(full);
    canvas.drawRRect(
        RRect.fromRectAndRadius(full, const Radius.circular(230)), bgPaint);

    final left = Path()
      ..moveTo(190, 330)
      ..lineTo(512, 390)
      ..lineTo(512, 780)
      ..lineTo(190, 720)
      ..close();
    final right = Path()
      ..moveTo(834, 330)
      ..lineTo(512, 390)
      ..lineTo(512, 780)
      ..lineTo(834, 720)
      ..close();
    canvas.drawPath(left, Paint()..color = const Color(0xFFF4F7FA));
    canvas.drawPath(right, Paint()..color = const Color(0xFFC9D6E3));

    final line = Paint()
      ..color = const Color(0xFF0B1220).withValues(alpha: 0.22)
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final y = 450.0 + i * 90;
      canvas.drawLine(Offset(250, y), Offset(460, y + 39), line);
      canvas.drawLine(Offset(774, y), Offset(564, y + 39), line);
    }

    canvas.drawLine(
      const Offset(512, 390),
      const Offset(512, 780),
      Paint()
        ..color = const Color(0xFF0B1220)
        ..strokeWidth = 10,
    );

    final ribbon = Path()
      ..moveTo(620, 300)
      ..lineTo(720, 300)
      ..lineTo(720, 570)
      ..lineTo(670, 520)
      ..lineTo(620, 570)
      ..close();
    canvas.drawPath(ribbon, Paint()..color = const Color(0xFFFFB020));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
