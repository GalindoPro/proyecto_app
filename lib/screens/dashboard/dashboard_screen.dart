import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pago_provider.dart';
import '../../providers/prestamo_provider.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/pago_list_tile.dart';
import '../../widgets/seccion_header.dart';
import '../../widgets/stat_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumen = ref.watch(resumenFinancieroProvider);
    final pagosRecientes = ref.watch(pagosRecientesProvider);
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${AppStrings.bienvenido}, ${auth.userName ?? ""}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(resumenFinancieroProvider);
          ref.invalidate(pagosRecientesProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.resumenFinanciero, style: AppTextStyles.h3),
              const SizedBox(height: 12),
              resumen.when(
                data: (data) => GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.4,
                  children: [
                    StatCard(
                      titulo: AppStrings.carteraActiva,
                      valor: AppFormatters.moneda(data.carteraActiva),
                      icono: Icons.account_balance_wallet,
                      color: AppColors.primary,
                    ),
                    StatCard(
                      titulo: AppStrings.cobradoMes,
                      valor: AppFormatters.moneda(data.cobradoMes),
                      icono: Icons.trending_up,
                      color: AppColors.success,
                    ),
                    StatCard(
                      titulo: AppStrings.prestamosActivos,
                      valor: '${data.prestamosActivos}',
                      icono: Icons.description,
                      color: AppColors.prestamoActivo,
                      onTap: () => context.go(AppRoutes.prestamos),
                    ),
                    StatCard(
                      titulo: AppStrings.prestamosVencidos,
                      valor: '${data.prestamosVencidos}',
                      icono: Icons.warning,
                      color: AppColors.prestamoVencido,
                    ),
                    StatCard(
                      titulo: AppStrings.clientesActivos,
                      valor: '${data.clientesActivos}',
                      icono: Icons.people,
                      color: AppColors.secondary,
                      onTap: () => context.go(AppRoutes.clientes),
                    ),
                    StatCard(
                      titulo: AppStrings.pendienteCobro,
                      valor: AppFormatters.moneda(data.pendienteCobro),
                      icono: Icons.schedule,
                      color: AppColors.warning,
                    ),
                  ],
                ),
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => AppErrorWidget(
                  mensaje: e.toString(),
                  onRetry: () => ref.invalidate(resumenFinancieroProvider),
                ),
              ),
              const SizedBox(height: 24),
              SeccionHeader(
                titulo: AppStrings.actividadReciente,
                onVerTodos: () => context.go(AppRoutes.pagos),
              ),
              pagosRecientes.when(
                data: (pagos) {
                  if (pagos.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        AppStrings.sinPagos,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: pagos.length,
                    itemBuilder: (context, index) {
                      return PagoListTile(
                        pago: pagos[index],
                        onTap: () =>
                            context.go('/pagos/${pagos[index].id}'),
                      );
                    },
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => AppErrorWidget(
                  mensaje: e.toString(),
                  onRetry: () => ref.invalidate(pagosRecientesProvider),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              context.go(AppRoutes.clientes);
              break;
            case 2:
              context.go(AppRoutes.prestamos);
              break;
            case 3:
              context.go(AppRoutes.pagos);
              break;
            case 4:
              context.go(AppRoutes.reportes);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: AppStrings.dashboard,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: AppStrings.clientes,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: AppStrings.prestamos,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: AppStrings.pagos,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: AppStrings.reportes,
          ),
        ],
      ),
    );
  }
}
