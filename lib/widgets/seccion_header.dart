import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_text_styles.dart';

class SeccionHeader extends StatelessWidget {
  final String titulo;
  final VoidCallback? onVerTodos;

  const SeccionHeader({
    super.key,
    required this.titulo,
    this.onVerTodos,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(titulo, style: AppTextStyles.h4),
          if (onVerTodos != null)
            TextButton(
              onPressed: onVerTodos,
              child: Text(
                AppStrings.verTodos,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
