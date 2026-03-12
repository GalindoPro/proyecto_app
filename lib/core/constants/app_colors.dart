import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primarios
  static const Color primary = Color(0xFF1B5E20);
  static const Color primaryLight = Color(0xFF4C8C4A);
  static const Color primaryDark = Color(0xFF003300);

  // Secundarios
  static const Color secondary = Color(0xFF2E7D32);
  static const Color secondaryLight = Color(0xFF60AD5E);
  static const Color secondaryDark = Color(0xFF005005);

  // Acentos
  static const Color accent = Color(0xFFFFC107);
  static const Color accentLight = Color(0xFFFFF350);
  static const Color accentDark = Color(0xFFC79100);

  // Semánticos
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  // Neutros
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE0E0E0);

  // Texto
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnAccent = Color(0xFF212121);

  // Estados de préstamos
  static const Color prestamoActivo = Color(0xFF2196F3);
  static const Color prestamoPagado = Color(0xFF4CAF50);
  static const Color prestamoVencido = Color(0xFFE53935);
  static const Color prestamoCancelado = Color(0xFF9E9E9E);

  // Estados de pagos
  static const Color pagoCompletado = Color(0xFF4CAF50);
  static const Color pagoPendiente = Color(0xFFFF9800);
  static const Color pagoCancelado = Color(0xFFE53935);

  // Métodos de pago
  static const Color efectivo = Color(0xFF4CAF50);
  static const Color transferencia = Color(0xFF2196F3);
  static const Color cheque = Color(0xFF9C27B0);
  static const Color tarjeta = Color(0xFFFF9800);
}
