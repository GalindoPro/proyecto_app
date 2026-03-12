import 'dart:io';

import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

class ClienteAvatar extends StatelessWidget {
  final String nombre;
  final String apellido;
  final String? fotoPath;
  final double radius;

  const ClienteAvatar({
    super.key,
    required this.nombre,
    required this.apellido,
    this.fotoPath,
    this.radius = 24,
  });

  String get _iniciales {
    final n = nombre.isNotEmpty ? nombre[0].toUpperCase() : '';
    final a = apellido.isNotEmpty ? apellido[0].toUpperCase() : '';
    return '$n$a';
  }

  @override
  Widget build(BuildContext context) {
    if (fotoPath != null && File(fotoPath!).existsSync()) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: FileImage(File(fotoPath!)),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primaryLight,
      child: Text(
        _iniciales,
        style: AppTextStyles.button.copyWith(
          fontSize: radius * 0.7,
          color: AppColors.textOnPrimary,
        ),
      ),
    );
  }
}
