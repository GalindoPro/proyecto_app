import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../providers/cliente_provider.dart';
import '../../providers/pago_provider.dart';
import '../../providers/prestamo_provider.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/pago_list_tile.dart';
import '../../widgets/seccion_header.dart';

class DetallePrestamoScreen extends ConsumerWidget {
  final String prestamoId;

  const DetallePrestamoScreen({super.key, required this.prestamoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prestamoAsync = ref.watch(prestamoProvider(prestamoId));
    final pagosAsync = ref.watch(pagosPorPrestamoProvider(prestamoId));

    return prestamoAsync.when(
      data: (prestamo) {
        if (prestamo == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const AppErrorWidget(mensaje: 'Préstamo no encontrado'),
          );
        }

        final clienteAsync = ref.watch(clienteProvider(prestamo.clienteId));
        final clienteNombre = clienteAsync.whenOrNull(
              data: (c) => c?.nombreCompleto,
            ) ??
            'Cliente';

        Color estadoColor;
        String estadoTexto;
        if (prestamo.estaVencido) {
          estadoColor = AppColors.prestamoVencido;
          estadoTexto = AppStrings.estadoVencido;
        } else {
          switch (prestamo.estado) {
            case 'activo':
              estadoColor = AppColors.prestamoActivo;
              estadoTexto = AppStrings.estadoActivo;
              break;
            case 'pagado':
              estadoColor = AppColors.prestamoPagado;
              estadoTexto = AppStrings.estadoPagado;
              break;
            case 'cancelado':
              estadoColor = AppColors.prestamoCancelado;
              estadoTexto = AppStrings.estadoCancelado;
              break;
            default:
              estadoColor = AppColors.textSecondary;
              estadoTexto = prestamo.estado;
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(AppStrings.detallePrestamo),
            actions: [
              if (prestamo.estaActivo)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () =>
                      context.go('/prestamos/${prestamo.id}/editar'),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(clienteNombre, style: AppTextStyles.h4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: estadoColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                estadoTexto,
                                style: AppTextStyles.labelBold.copyWith(
                                  color: estadoColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppFormatters.moneda(prestamo.montoOriginal),
                          style: AppTextStyles.moneda,
                        ),
                        const SizedBox(height: 16),
                        // Progreso
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: prestamo.porcentajePagado / 100,
                            backgroundColor: AppColors.divider,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(estadoColor),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pagado: ${prestamo.porcentajePagado.toStringAsFixed(1)}%',
                              style: AppTextStyles.bodySmall,
                            ),
                            Text(
                              'Saldo: ${AppFormatters.moneda(prestamo.saldoPendiente)}',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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
                          label: AppStrings.tasaInteres,
                          valor: AppFormatters.porcentaje(prestamo.tasaInteres),
                        ),
                        _DetalleRow(
                          label: AppStrings.plazoMeses,
                          valor: '${prestamo.plazoMeses} meses',
                        ),
                        _DetalleRow(
                          label: 'Cuota mensual',
                          valor: AppFormatters.moneda(prestamo.cuotaMensual),
                        ),
                        _DetalleRow(
                          label: AppStrings.fechaInicio,
                          valor: AppFormatters.fecha(prestamo.fechaInicio),
                        ),
                        _DetalleRow(
                          label: AppStrings.fechaVencimiento,
                          valor:
                              AppFormatters.fecha(prestamo.fechaVencimiento),
                        ),
                        if (prestamo.garantia != null)
                          _DetalleRow(
                            label: AppStrings.garantia,
                            valor: prestamo.garantia!,
                          ),
                        if (prestamo.notas != null)
                          _DetalleRow(
                            label: AppStrings.notas,
                            valor: prestamo.notas!,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Pagos del préstamo
                SeccionHeader(titulo: AppStrings.pagos),
                pagosAsync.when(
                  data: (pagos) {
                    if (pagos.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          AppStrings.sinPagos,
                          style: AppTextStyles.bodySmall,
                        ),
                      );
                    }
                    return Column(
                      children: pagos
                          .map((p) => PagoListTile(
                                pago: p,
                                onTap: () => context.go('/pagos/${p.id}'),
                              ))
                          .toList(),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => AppErrorWidget(mensaje: e.toString()),
                ),
              ],
            ),
          ),
          floatingActionButton: prestamo.estaActivo
              ? FloatingActionButton.extended(
                  onPressed: () => context.go(
                    '/pagos/nuevo?clienteId=${prestamo.clienteId}&prestamoId=${prestamo.id}',
                  ),
                  icon: const Icon(Icons.payment),
                  label: const Text(AppStrings.registrarPago),
                )
              : null,
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
          onRetry: () => ref.invalidate(prestamoProvider(prestamoId)),
        ),
      ),
    );
  }
}

class _DetalleRow extends StatelessWidget {
  final String label;
  final String valor;

  const _DetalleRow({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(
            valor,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
