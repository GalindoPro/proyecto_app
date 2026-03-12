import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../models/pago.dart';
import '../../providers/cliente_provider.dart';
import '../../providers/pago_provider.dart';
import '../../providers/prestamo_provider.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/loading_button.dart';

class FormPagoScreen extends ConsumerStatefulWidget {
  final String? clienteId;
  final String? prestamoId;

  const FormPagoScreen({super.key, this.clienteId, this.prestamoId});

  @override
  ConsumerState<FormPagoScreen> createState() => _FormPagoScreenState();
}

class _FormPagoScreenState extends ConsumerState<FormPagoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  final _conceptoController = TextEditingController();
  final _notasController = TextEditingController();

  String? _clienteSeleccionado;
  String? _prestamoSeleccionado;
  DateTime _fecha = DateTime.now();
  String _metodoPago = 'efectivo';
  String _estado = 'completado';
  bool _isLoading = false;

  final _metodosPago = [
    {'value': 'efectivo', 'label': AppStrings.efectivo, 'icon': Icons.money},
    {
      'value': 'transferencia',
      'label': AppStrings.transferencia,
      'icon': Icons.account_balance,
    },
    {'value': 'cheque', 'label': AppStrings.cheque, 'icon': Icons.description},
    {'value': 'tarjeta', 'label': AppStrings.tarjeta, 'icon': Icons.credit_card},
  ];

  final _estados = [
    {'value': 'completado', 'label': AppStrings.pagoCompletado},
    {'value': 'pendiente', 'label': AppStrings.pagoPendiente},
  ];

  @override
  void initState() {
    super.initState();
    _clienteSeleccionado = widget.clienteId;
    _prestamoSeleccionado = widget.prestamoId;
  }

  @override
  void dispose() {
    _montoController.dispose();
    _conceptoController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (fecha != null) {
      setState(() => _fecha = fecha);
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_clienteSeleccionado == null) {
      AppSnackBar.error(context, AppStrings.seleccioneCliente);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final pago = Pago(
        id: const Uuid().v4(),
        clienteId: _clienteSeleccionado!,
        prestamoId: _prestamoSeleccionado,
        monto: double.parse(_montoController.text.trim()),
        fecha: _fecha,
        metodoPago: _metodoPago,
        concepto: _conceptoController.text.trim(),
        estado: _estado,
        notas: _notasController.text.trim().isEmpty
            ? null
            : _notasController.text.trim(),
        fechaCreacion: DateTime.now(),
      );

      await ref.read(pagosProvider.notifier).crear(pago);

      // Invalidar providers relacionados
      ref.invalidate(resumenFinancieroProvider);
      if (_prestamoSeleccionado != null) {
        ref.invalidate(prestamoProvider(_prestamoSeleccionado!));
      }

      if (mounted) {
        AppSnackBar.exito(context, AppStrings.guardadoExito);
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, AppStrings.errorGuardar);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientesAsync = ref.watch(clientesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.nuevoPago),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selector de cliente
              Text(AppStrings.seleccioneCliente, style: AppTextStyles.label),
              const SizedBox(height: 8),
              clientesAsync.when(
                data: (clientes) => DropdownButtonFormField<String>(
                  initialValue: _clienteSeleccionado,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person),
                  ),
                  hint: const Text(AppStrings.seleccioneCliente),
                  items: clientes
                      .map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.nombreCompleto),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _clienteSeleccionado = value;
                      _prestamoSeleccionado = null;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return AppStrings.seleccioneCliente;
                    }
                    return null;
                  },
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
              ),
              const SizedBox(height: 16),

              // Selector de préstamo (opcional)
              if (_clienteSeleccionado != null) ...[
                Text('Asociar a préstamo (opcional)',
                    style: AppTextStyles.label),
                const SizedBox(height: 8),
                Consumer(
                  builder: (context, ref, _) {
                    final prestamosAsync = ref.watch(
                      prestamosPorClienteProvider(_clienteSeleccionado!),
                    );
                    return prestamosAsync.when(
                      data: (prestamos) {
                        final activos = prestamos
                            .where((p) => p.estaActivo)
                            .toList();
                        if (activos.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return DropdownButtonFormField<String>(
                          initialValue: _prestamoSeleccionado,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.description),
                          ),
                          hint: const Text('Sin préstamo'),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Sin préstamo'),
                            ),
                            ...activos.map((p) => DropdownMenuItem(
                                  value: p.id,
                                  child: Text(
                                    'Q${p.montoOriginal.toStringAsFixed(0)} — Saldo: Q${p.saldoPendiente.toStringAsFixed(0)}',
                                  ),
                                )),
                          ],
                          onChanged: (value) {
                            setState(
                                () => _prestamoSeleccionado = value);
                          },
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (e, _) => const SizedBox.shrink(),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],

              TextFormField(
                controller: _montoController,
                decoration: const InputDecoration(
                  labelText: AppStrings.monto,
                  prefixIcon: Icon(Icons.attach_money),
                  prefixText: 'Q ',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                validator: AppValidators.monto,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _conceptoController,
                decoration: const InputDecoration(
                  labelText: AppStrings.concepto,
                  prefixIcon: Icon(Icons.text_snippet),
                  hintText: 'Ej: Cuota mensual, Intereses...',
                ),
                textInputAction: TextInputAction.next,
                validator: AppValidators.requerido,
              ),
              const SizedBox(height: 16),

              // Fecha
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event),
                title: const Text(AppStrings.fecha),
                subtitle: Text(
                  '${_fecha.day}/${_fecha.month}/${_fecha.year}',
                  style: AppTextStyles.bodyMedium,
                ),
                trailing: const Icon(Icons.edit_calendar),
                onTap: _seleccionarFecha,
              ),
              const SizedBox(height: 16),

              // Método de pago
              Text(AppStrings.metodoPago, style: AppTextStyles.label),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _metodosPago.map((m) {
                  final selected = _metodoPago == m['value'];
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          m['icon'] as IconData,
                          size: 16,
                          color: selected ? Colors.white : null,
                        ),
                        const SizedBox(width: 4),
                        Text(m['label'] as String),
                      ],
                    ),
                    selected: selected,
                    onSelected: (_) {
                      setState(
                          () => _metodoPago = m['value'] as String);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Estado
              Text(AppStrings.estado, style: AppTextStyles.label),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _estados.map((e) {
                  final selected = _estado == e['value'];
                  return ChoiceChip(
                    label: Text(e['label'] as String),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _estado = e['value'] as String);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notasController,
                decoration: const InputDecoration(
                  labelText: '${AppStrings.notas} (${AppStrings.opcional})',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 32),

              LoadingButton(
                texto: AppStrings.registrarPago,
                onPressed: _guardar,
                isLoading: _isLoading,
                icono: Icons.payment,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
