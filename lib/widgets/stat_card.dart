import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

class StatCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color color;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardBackground,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icono, color: color, size: 24),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                valor,
                style: AppTextStyles.h3.copyWith(color: color),
              ),
              const SizedBox(height: 4),
              Text(
                titulo,
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
