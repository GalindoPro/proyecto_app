import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/services/backup_service.dart';
import '../../core/utils/formatters.dart';
import '../../providers/prestamo_provider.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/stat_card.dart';

class ReportesScreen extends ConsumerWidget {
  const ReportesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumen = ref.watch(resumenFinancieroProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.reportes),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.resumenFinanciero, style: AppTextStyles.h3),
            const SizedBox(height: 12),
            resumen.when(
              data: (data) => Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          titulo: AppStrings.carteraActiva,
                          valor: AppFormatters.moneda(data.carteraActiva),
                          icono: Icons.account_balance_wallet,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: StatCard(
                          titulo: AppStrings.cobradoMes,
                          valor: AppFormatters.moneda(data.cobradoMes),
                          icono: Icons.trending_up,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          titulo: AppStrings.pendienteCobro,
                          valor: AppFormatters.moneda(data.pendienteCobro),
                          icono: Icons.schedule,
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: StatCard(
                          titulo: AppStrings.prestamosVencidos,
                          valor: '${data.prestamosVencidos}',
                          icono: Icons.warning,
                          color: AppColors.error,
                        ),
                      ),
                    ],
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
            const SizedBox(height: 32),

            // Acciones
            Text('Acciones', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            _AccionTile(
              icono: Icons.backup,
              titulo: AppStrings.exportarDatos,
              subtitulo: 'Compartir backup de la base de datos',
              onTap: () async {
                try {
                  await BackupService.compartirBackup();
                } catch (e) {
                  if (context.mounted) {
                    AppSnackBar.error(context, 'Error al exportar: $e');
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AccionTile extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  const _AccionTile({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icono, color: AppColors.primary),
        ),
        title: Text(titulo, style: AppTextStyles.bodyMedium),
        subtitle: Text(subtitulo, style: AppTextStyles.bodySmall),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
