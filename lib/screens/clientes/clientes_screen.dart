import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/formatters.dart';
import '../../providers/cliente_provider.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/cliente_avatar.dart';
import '../../widgets/empty_state.dart';

class ClientesScreen extends ConsumerStatefulWidget {
  const ClientesScreen({super.key});

  @override
  ConsumerState<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends ConsumerState<ClientesScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientes = ref.watch(clientesProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textOnPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '${AppStrings.buscar}...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textOnPrimary.withValues(alpha: 0.7),
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (_) => setState(() {}),
              )
            : const Text(AppStrings.clientes),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
        ],
      ),
      body: clientes.when(
        data: (lista) {
          var filtrada = lista;
          if (_searchController.text.isNotEmpty) {
            final query = _searchController.text.toLowerCase();
            filtrada = lista
                .where((c) =>
                    c.nombre.toLowerCase().contains(query) ||
                    c.apellido.toLowerCase().contains(query) ||
                    c.telefono.contains(query))
                .toList();
          }

          if (filtrada.isEmpty) {
            return EmptyState(
              mensaje: _searchController.text.isNotEmpty
                  ? AppStrings.sinResultados
                  : AppStrings.sinClientes,
              icono: Icons.people_outline,
              accionTexto: _searchController.text.isEmpty
                  ? AppStrings.nuevoCliente
                  : null,
              onAccion: _searchController.text.isEmpty
                  ? () => context.push(AppRoutes.nuevoCliente)
                  : null,
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(clientesProvider),
            child: ListView.builder(
              itemCount: filtrada.length,
              itemBuilder: (context, index) {
                final cliente = filtrada[index];
                return ListTile(
                  leading: ClienteAvatar(
                    nombre: cliente.nombre,
                    apellido: cliente.apellido,
                    fotoPath: cliente.fotoPath,
                  ),
                  title: Text(
                    cliente.nombreCompleto,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    AppFormatters.telefono(cliente.telefono),
                    style: AppTextStyles.bodySmall,
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                  onTap: () => context.go('/clientes/${cliente.id}'),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorWidget(
          mensaje: e.toString(),
          onRetry: () => ref.invalidate(clientesProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.nuevoCliente),
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
