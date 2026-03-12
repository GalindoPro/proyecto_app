import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/formatters.dart';
import '../models/cliente.dart';
import '../models/pago.dart';

class PagoListTile extends StatelessWidget {
  final Pago pago;
  final Cliente? cliente;
  final VoidCallback? onTap;

  const PagoListTile({
    super.key,
    required this.pago,
    this.cliente,
    this.onTap,
  });

  Color get _estadoColor {
    switch (pago.estado) {
      case 'completado':
        return AppColors.pagoCompletado;
      case 'pendiente':
        return AppColors.pagoPendiente;
      case 'cancelado':
        return AppColors.pagoCancelado;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData get _metodoIcono {
    switch (pago.metodoPago) {
      case 'efectivo':
        return Icons.money;
      case 'transferencia':
        return Icons.account_balance;
      case 'cheque':
        return Icons.description;
      case 'tarjeta':
        return Icons.credit_card;
      default:
        return Icons.payment;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _estadoColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(_metodoIcono, color: _estadoColor),
      ),
      title: Text(
        pago.concepto,
        style: AppTextStyles.bodyMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        cliente != null
            ? '${cliente!.nombreCompleto} · ${AppFormatters.fechaRelativa(pago.fecha)}'
            : AppFormatters.fechaRelativa(pago.fecha),
        style: AppTextStyles.bodySmall,
      ),
      trailing: Text(
        AppFormatters.moneda(pago.monto),
        style: AppTextStyles.monedaSmall.copyWith(
          fontSize: 14,
          color: _estadoColor,
        ),
      ),
    );
  }
}
