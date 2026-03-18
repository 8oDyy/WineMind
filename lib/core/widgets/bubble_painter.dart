import 'package:flutter/material.dart';

class BubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[100]!
      ..style = PaintingStyle.fill;

    final path = Path();
    const double radius = 16;
    const double pointerWidth = 12;
    const double pointerHeight = 10;

    path.moveTo(radius + pointerWidth, 0);
    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius);
    path.lineTo(size.width, size.height - radius);
    path.quadraticBezierTo(
        size.width, size.height, size.width - radius, size.height);
    path.lineTo(radius + pointerWidth, size.height);
    path.quadraticBezierTo(
        pointerWidth, size.height, pointerWidth, size.height - radius);

    final double pointerY = size.height - pointerHeight * 2;
    path.lineTo(pointerWidth, pointerY + pointerHeight / 2);
    path.lineTo(0, pointerY);
    path.lineTo(pointerWidth, pointerY - pointerHeight / 2);
    path.lineTo(pointerWidth, radius);
    path.quadraticBezierTo(pointerWidth, 0, radius + pointerWidth, 0);
    path.close();

    canvas.drawShadow(path, Colors.grey.withValues(alpha: 0.4), 3, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
