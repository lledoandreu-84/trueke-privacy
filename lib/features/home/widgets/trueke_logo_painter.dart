import 'package:flutter/material.dart';

class TruekeLogoPainter extends CustomPainter {
  const TruekeLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paintEmerald = Paint()
      ..color = const Color(0xFF059669)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final paintMint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final pathLeftHand = Path();
    // Mano izquierda (Línea curva fluida que abraza el centro)
    pathLeftHand.moveTo(size.width * 0.25, size.height * 0.5);
    pathLeftHand.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.25,
      size.width * 0.5,
      size.height * 0.35,
    );
    pathLeftHand.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.45,
      size.width * 0.45,
      size.height * 0.6,
    );
    pathLeftHand.lineTo(size.width * 0.35, size.height * 0.6);

    final pathRightHand = Path();
    // Mano derecha (Se entrelaza de forma simétrica inversa)
    pathRightHand.moveTo(size.width * 0.75, size.height * 0.5);
    pathRightHand.quadraticBezierTo(
      size.width * 0.65,
      size.height * 0.75,
      size.width * 0.5,
      size.height * 0.65,
    );
    pathRightHand.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.55,
      size.width * 0.55,
      size.height * 0.4,
    );
    pathRightHand.lineTo(size.width * 0.65, size.height * 0.4);

    canvas.drawPath(pathLeftHand, paintEmerald);
    canvas.drawPath(pathRightHand, paintMint);

    // Punto central de unión que simboliza el trato cerrado (Trueke)
    final paintNode = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      4,
      paintNode,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
