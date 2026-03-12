import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/formatters.dart';
import '../models/cliente.dart';
import '../models/prestamo.dart';

class PrestamoCard extends StatelessWidget {
  final Prestamo prestamo;
  final Cliente? cliente;
  final VoidCallback? onTap;

  const PrestamoCard({
    super.key,
    required this.prestamo,
    this.cliente,
    this.onTap,
  });

  Color get _estadoColor {
    if (prestamo.estaVencido) {
      return AppColors.prestamoVencido;
    }
    switch (prestamo.estado) {
      case 'activo':
        return AppColors.prestamoActivo;
      case 'pagado':
        return AppColors.prestamoPagado;
      case 'vencido':
        return AppColors.prestamoVencido;
      case 'cancelado':
        return AppColors.prestamoCancelado;
      default:
        return AppColors.textSecondary;
    }
  }

  String get _estadoTexto {
    if (prestamo.estaVencido) {
      return 'Vencido';
    }
    switch (prestamo.estado) {
      case 'activo':
        return 'Activo';
      case 'pagado':
        return 'Pagado';
      case 'vencido':
        return 'Vencido';
      case 'cancelado':
        return 'Cancelado';
      default:
        return prestamo.estado;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  Expanded(
                    child: Text(
                      cliente?.nombreCompleto ?? 'Cliente',
                      style: AppTextStyles.h4,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _estadoColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _estadoTexto,
                      style: AppTextStyles.labelBold.copyWith(
                        color: _estadoColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _InfoItem(
                    label: 'Monto',
                    valor: AppFormatters.moneda(prestamo.montoOriginal),
                  ),
                  _InfoItem(
                    label: 'Tasa',
                    valor: AppFormatters.porcentaje(prestamo.tasaInteres),
                  ),
                  _InfoItem(
                    label: 'Plazo',
                    valor: '${prestamo.plazoMeses}m',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Barra de progreso
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: prestamo.porcentajePagado / 100,
                  backgroundColor: AppColors.divider,
                  valueColor: AlwaysStoppedAnimation<Color>(_estadoColor),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Saldo: ${AppFormatters.moneda(prestamo.saldoPendiente)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Vence: ${AppFormatters.fecha(prestamo.fechaVencimiento)}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String valor;

  const _InfoItem({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.label),
          Text(valor, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
