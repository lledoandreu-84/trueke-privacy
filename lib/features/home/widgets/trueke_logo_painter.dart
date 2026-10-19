import 'package:flutter/material.dart';
import 'package:trueke/core/theme/app_colors.dart';

class TruekeLogoPainter extends CustomPainter {
  const TruekeLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    // Fondo verde circular corporativo
    final Paint bgPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Dibujo vectorial/icono de manos entrelazadas (Handshake) en blanco
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: String.fromCharCode(Icons.handshake_rounded.codePoint),
        style: TextStyle(
          fontSize: size.width * 0.58,
          fontFamily: Icons.handshake_rounded.fontFamily,
          package: Icons.handshake_rounded.fontPackage,
          color: Colors.white,
        ),
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - (textPainter.width / 2),
        center.dy - (textPainter.height / 2),
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
