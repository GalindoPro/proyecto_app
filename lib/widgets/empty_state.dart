import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

class EmptyState extends StatelessWidget {
  final String mensaje;
  final IconData icono;
  final String? accionTexto;
  final VoidCallback? onAccion;

  const EmptyState({
    super.key,
    required this.mensaje,
    this.icono = Icons.inbox_outlined,
    this.accionTexto,
    this.onAccion,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icono,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              mensaje,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (accionTexto != null && onAccion != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onAccion,
                child: Text(accionTexto!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
