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
import '../../widgets/cliente_avatar.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/pago_list_tile.dart';
import '../../widgets/prestamo_card.dart';
import '../../widgets/seccion_header.dart';
import '../../widgets/whatsapp_button.dart';

class DetalleClienteScreen extends ConsumerWidget {
  final String clienteId;

  const DetalleClienteScreen({super.key, required this.clienteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clienteAsync = ref.watch(clienteProvider(clienteId));
    final prestamosAsync = ref.watch(prestamosPorClienteProvider(clienteId));
    final pagosAsync = ref.watch(pagosPorClienteProvider(clienteId));

    return clienteAsync.when(
      data: (cliente) {
        if (cliente == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const AppErrorWidget(mensaje: 'Cliente no encontrado'),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(AppStrings.detalleCliente),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () =>
                    context.go('/clientes/${cliente.id}/editar'),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final confirmar = await ConfirmDialog.show(
                    context,
                    titulo: AppStrings.eliminar,
                    mensaje: AppStrings.confirmarEliminarCliente,
                    esPeligroso: true,
                  );
                  if (confirmar) {
                    await ref
                        .read(clientesProvider.notifier)
                        .eliminar(cliente.id);
                    if (context.mounted) {
                      AppSnackBar.exito(context, AppStrings.eliminadoExito);
                      context.pop();
                    }
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header del cliente
                Center(
                  child: Column(
                    children: [
                      ClienteAvatar(
                        nombre: cliente.nombre,
                        apellido: cliente.apellido,
                        fotoPath: cliente.fotoPath,
                        radius: 40,
                      ),
                      const SizedBox(height: 12),
                      Text(cliente.nombreCompleto, style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Text(
                        AppFormatters.telefono(cliente.telefono),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Botones de acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    WhatsAppButton(telefono: cliente.telefono),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => context.go(
                        '/pagos/nuevo?clienteId=${cliente.id}',
                      ),
                      icon: const Icon(Icons.payment),
                      label: const Text(AppStrings.registrarPago),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Información
                if (cliente.email != null) ...[
                  _InfoRow(
                    icono: Icons.email,
                    label: AppStrings.email,
                    valor: cliente.email!,
                  ),
                ],
                if (cliente.direccion != null) ...[
                  _InfoRow(
                    icono: Icons.location_on,
                    label: AppStrings.direccion,
                    valor: cliente.direccion!,
                  ),
                ],
                if (cliente.dpi != null) ...[
                  _InfoRow(
                    icono: Icons.badge,
                    label: AppStrings.dpi,
                    valor: AppFormatters.dpi(cliente.dpi!),
                  ),
                ],
                _InfoRow(
                  icono: Icons.calendar_today,
                  label: 'Registrado',
                  valor: AppFormatters.fecha(cliente.fechaRegistro),
                ),

                const SizedBox(height: 24),

                // Préstamos
                SeccionHeader(
                  titulo: AppStrings.prestamos,
                  onVerTodos: () =>
                      context.go('/prestamos?clienteId=${cliente.id}'),
                ),
                prestamosAsync.when(
                  data: (prestamos) {
                    if (prestamos.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          AppStrings.sinPrestamos,
                          style: AppTextStyles.bodySmall,
                        ),
                      );
                    }
                    return Column(
                      children: prestamos
                          .take(3)
                          .map((p) => PrestamoCard(
                                prestamo: p,
                                cliente: cliente,
                                onTap: () =>
                                    context.go('/prestamos/${p.id}'),
                              ))
                          .toList(),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => AppErrorWidget(mensaje: e.toString()),
                ),

                const SizedBox(height: 24),

                // Pagos
                SeccionHeader(
                  titulo: AppStrings.pagos,
                  onVerTodos: () =>
                      context.go('/pagos?clienteId=${cliente.id}'),
                ),
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
                          .take(5)
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
          onRetry: () => ref.invalidate(clienteProvider(clienteId)),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icono;
  final String label;
  final String valor;

  const _InfoRow({
    required this.icono,
    required this.label,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icono, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.label),
              Text(valor, style: AppTextStyles.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}
