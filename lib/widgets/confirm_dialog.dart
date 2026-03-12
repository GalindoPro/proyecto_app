import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_text_styles.dart';

class ConfirmDialog extends StatelessWidget {
  final String titulo;
  final String mensaje;
  final String textoConfirmar;
  final String textoCancelar;
  final bool esPeligroso;

  const ConfirmDialog({
    super.key,
    required this.titulo,
    required this.mensaje,
    this.textoConfirmar = 'Confirmar',
    this.textoCancelar = 'Cancelar',
    this.esPeligroso = false,
  });

  static Future<bool> show(
    BuildContext context, {
    required String titulo,
    required String mensaje,
    String? textoConfirmar,
    String? textoCancelar,
    bool esPeligroso = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        titulo: titulo,
        mensaje: mensaje,
        textoConfirmar: textoConfirmar ?? AppStrings.confirmar,
        textoCancelar: textoCancelar ?? AppStrings.cancelar,
        esPeligroso: esPeligroso,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(titulo, style: AppTextStyles.h4),
      content: Text(mensaje, style: AppTextStyles.bodyMedium),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(textoCancelar),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: esPeligroso
              ? ElevatedButton.styleFrom(backgroundColor: AppColors.error)
              : null,
          child: Text(textoConfirmar),
        ),
      ],
    );
  }
}
