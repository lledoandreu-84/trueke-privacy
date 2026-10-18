import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Identidad principal de TRUEKE: esmeralda y petróleo.
  static const Color primary = Color(0xFF059669);
  static const Color secondary = Color(0xFF155E75);

  // Paleta de acentos avanzada.
  static const Color emerald = Color(0xFF059669);
  static const Color mint = Color(0xFF10B981);
  static const Color mintLight = Color(0xFFECFDF5);
  static const Color petrolBlue = Color(0xFF155E75);
  static const Color indigo = Color(0xFF4F46E5);
  static const Color skyBlue = Color(0xFF38BDF8);
  static const Color amber = Color(0xFFF59E0B);
  static const Color coral = Color(0xFFF97373);

  // Fondos y superficies.
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMint = Color(0xFFECFDF5);

  // Tipografía y legibilidad.
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF64748B);

  // Estados semánticos.
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF155E75);

  // Bordes y divisores.
  static const Color border = Color(0xFFE2E8F0);

  // Degradados de alta gama para TRUEKE
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF155E75), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
