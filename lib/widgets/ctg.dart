import 'package:flutter/material.dart';

class CtgPainter extends CustomPainter {
  final Animation<double> animation;
  final List<Offset> ctgDataPoints;

  CtgPainter(this.animation, this.ctgDataPoints) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Calcule le nombre de points à dessiner en fonction de la valeur de l'animation
    final numPoints = (animation.value * ctgDataPoints.length).floor();

    if (numPoints > 0) {
      path.moveTo(
        ctgDataPoints[0].dx * size.width,
        ctgDataPoints[0].dy * size.height,
      );
      for (int i = 1; i < numPoints; i++) {
        path.lineTo(
          ctgDataPoints[i].dx * size.width,
          ctgDataPoints[i].dy * size.height,
        );
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CtgPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
