import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/services/whatsapp_service.dart';

class WhatsAppButton extends StatelessWidget {
  final String telefono;
  final String mensaje;

  const WhatsAppButton({
    super.key,
    required this.telefono,
    this.mensaje = '',
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        try {
          await WhatsAppService.enviarMensaje(
            telefono: telefono,
            mensaje: mensaje,
          );
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al abrir WhatsApp: $e')),
            );
          }
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF25D366),
        foregroundColor: AppColors.textOnPrimary,
      ),
      icon: const Icon(Icons.message, size: 20),
      label: Text('WhatsApp', style: AppTextStyles.button),
    );
  }
}
