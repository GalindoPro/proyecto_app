import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

class LoadingButton extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icono;

  const LoadingButton({
    super.key,
    required this.texto,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icono,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          child: _buildChild(AppColors.primary),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: _buildChild(AppColors.textOnPrimary),
      ),
    );
  }

  Widget _buildChild(Color textColor) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    if (icono != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono, size: 20),
          const SizedBox(width: 8),
          Text(texto, style: AppTextStyles.button.copyWith(color: textColor)),
        ],
      );
    }

    return Text(texto, style: AppTextStyles.button.copyWith(color: textColor));
  }
}
