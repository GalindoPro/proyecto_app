import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../providers/cliente_provider.dart';
import '../../providers/pago_provider.dart';
import '../../widgets/app_error_widget.dart';

class DetallePagoScreen extends ConsumerWidget {
  final String pagoId;

  const DetallePagoScreen({super.key, required this.pagoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagoAsync = ref.watch(pagoProvider(pagoId));

    return pagoAsync.when(
      data: (pago) {
        if (pago == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const AppErrorWidget(mensaje: 'Pago no encontrado'),
          );
        }

        final clienteAsync = ref.watch(clienteProvider(pago.clienteId));
        final clienteNombre = clienteAsync.whenOrNull(
              data: (c) => c?.nombreCompleto,
            ) ??
            'Cliente';

        Color estadoColor;
        switch (pago.estado) {
          case 'completado':
            estadoColor = AppColors.pagoCompletado;
            break;
          case 'pendiente':
            estadoColor = AppColors.pagoPendiente;
            break;
          case 'cancelado':
            estadoColor = AppColors.pagoCancelado;
            break;
          default:
            estadoColor = AppColors.textSecondary;
        }

        String estadoTexto;
        switch (pago.estado) {
          case 'completado':
            estadoTexto = AppStrings.pagoCompletado;
            break;
          case 'pendiente':
            estadoTexto = AppStrings.pagoPendiente;
            break;
          case 'cancelado':
            estadoTexto = AppStrings.pagoCancelado;
            break;
          default:
            estadoTexto = pago.estado;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(AppStrings.detallePago),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Monto y estado
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          AppFormatters.moneda(pago.monto),
                          style: AppTextStyles.moneda.copyWith(fontSize: 32),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: estadoColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            estadoTexto,
                            style: AppTextStyles.labelBold.copyWith(
                              color: estadoColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Detalles
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _DetalleRow(
                          icono: Icons.person,
                          label: 'Cliente',
                          valor: clienteNombre,
                        ),
                        const Divider(),
                        _DetalleRow(
                          icono: Icons.text_snippet,
                          label: AppStrings.concepto,
                          valor: pago.concepto,
                        ),
                        const Divider(),
                        _DetalleRow(
                          icono: Icons.calendar_today,
                          label: AppStrings.fecha,
                          valor: AppFormatters.fecha(pago.fecha),
                        ),
                        const Divider(),
                        _DetalleRow(
                          icono: Icons.payment,
                          label: AppStrings.metodoPago,
                          valor: pago.metodoPago[0].toUpperCase() +
                              pago.metodoPago.substring(1),
                        ),
                        if (pago.tienePrestamo) ...[
                          const Divider(),
                          _DetalleRow(
                            icono: Icons.description,
                            label: 'Préstamo asociado',
                            valor: 'Sí',
                          ),
                        ],
                        if (pago.notas != null) ...[
                          const Divider(),
                          _DetalleRow(
                            icono: Icons.note,
                            label: AppStrings.notas,
                            valor: pago.notas!,
                          ),
                        ],
                        const Divider(),
                        _DetalleRow(
                          icono: Icons.access_time,
                          label: 'Registrado',
                          valor: AppFormatters.fechaHora(pago.fechaCreacion),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: AppErrorWidget(
          mensaje: e.toString(),
          onRetry: () => ref.invalidate(pagoProvider(pagoId)),
        ),
      ),
    );
  }
}

class _DetalleRow extends StatelessWidget {
  final IconData icono;
  final String label;
  final String valor;

  const _DetalleRow({
    required this.icono,
    required this.label,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icono, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.label),
                const SizedBox(height: 2),
                Text(valor, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
