import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../models/cliente.dart';
import '../../providers/cliente_provider.dart';
import '../../providers/prestamo_provider.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/prestamo_card.dart';

class PrestamosScreen extends ConsumerWidget {
  const PrestamosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prestamos = ref.watch(prestamosProvider);
    final clientes = ref.watch(clientesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.prestamos),
      ),
      body: prestamos.when(
        data: (lista) {
          if (lista.isEmpty) {
            return EmptyState(
              mensaje: AppStrings.sinPrestamos,
              icono: Icons.description_outlined,
              accionTexto: AppStrings.nuevoPrestamo,
              onAccion: () => context.push(AppRoutes.nuevoPrestamo),
            );
          }

          // Crear mapa de clientes para lookup
          final clienteMap = <String, Cliente>{};
          clientes.whenData((list) {
            for (final c in list) {
              clienteMap[c.id] = c;
            }
          });

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(prestamosProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: lista.length,
              itemBuilder: (context, index) {
                final prestamo = lista[index];
                return PrestamoCard(
                  prestamo: prestamo,
                  cliente: clienteMap[prestamo.clienteId],
                  onTap: () => context.go('/prestamos/${prestamo.id}'),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorWidget(
          mensaje: e.toString(),
          onRetry: () => ref.invalidate(prestamosProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.nuevoPrestamo),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
