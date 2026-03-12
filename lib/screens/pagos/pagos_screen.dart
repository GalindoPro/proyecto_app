import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../models/cliente.dart';
import '../../providers/cliente_provider.dart';
import '../../providers/pago_provider.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/pago_list_tile.dart';

class PagosScreen extends ConsumerWidget {
  const PagosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagos = ref.watch(pagosProvider);
    final clientes = ref.watch(clientesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.pagos),
      ),
      body: pagos.when(
        data: (lista) {
          if (lista.isEmpty) {
            return EmptyState(
              mensaje: AppStrings.sinPagos,
              icono: Icons.payment_outlined,
              accionTexto: AppStrings.nuevoPago,
              onAccion: () => context.push(AppRoutes.nuevoPago),
            );
          }

          final clienteMap = <String, Cliente>{};
          clientes.whenData((list) {
            for (final c in list) {
              clienteMap[c.id] = c;
            }
          });

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(pagosProvider),
            child: ListView.builder(
              itemCount: lista.length,
              itemBuilder: (context, index) {
                final pago = lista[index];
                return PagoListTile(
                  pago: pago,
                  cliente: clienteMap[pago.clienteId],
                  onTap: () => context.go('/pagos/${pago.id}'),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorWidget(
          mensaje: e.toString(),
          onRetry: () => ref.invalidate(pagosProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.nuevoPago),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
