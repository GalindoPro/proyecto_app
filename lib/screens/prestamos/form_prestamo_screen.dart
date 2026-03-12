import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../models/prestamo.dart';
import '../../providers/cliente_provider.dart';
import '../../providers/prestamo_provider.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/loading_button.dart';

class FormPrestamoScreen extends ConsumerStatefulWidget {
  final String? prestamoId;
  final String? clienteId;

  const FormPrestamoScreen({super.key, this.prestamoId, this.clienteId});

  bool get esEdicion => prestamoId != null;

  @override
  ConsumerState<FormPrestamoScreen> createState() => _FormPrestamoScreenState();
}

class _FormPrestamoScreenState extends ConsumerState<FormPrestamoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  final _tasaController = TextEditingController();
  final _plazoController = TextEditingController();
  final _garantiaController = TextEditingController();
  final _notasController = TextEditingController();

  String? _clienteSeleccionado;
  DateTime _fechaInicio = DateTime.now();
  bool _isLoading = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _clienteSeleccionado = widget.clienteId;
  }

  @override
  void dispose() {
    _montoController.dispose();
    _tasaController.dispose();
    _plazoController.dispose();
    _garantiaController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  void _cargarDatos(Prestamo prestamo) {
    if (_loaded) {
      return;
    }
    _loaded = true;
    _montoController.text = prestamo.montoOriginal.toStringAsFixed(2);
    _tasaController.text = prestamo.tasaInteres.toString();
    _plazoController.text = prestamo.plazoMeses.toString();
    _garantiaController.text = prestamo.garantia ?? '';
    _notasController.text = prestamo.notas ?? '';
    _clienteSeleccionado = prestamo.clienteId;
    _fechaInicio = prestamo.fechaInicio;
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaInicio,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (fecha != null) {
      setState(() => _fechaInicio = fecha);
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
      final monto = double.parse(_montoController.text.trim());
      final plazo = int.parse(_plazoController.text.trim());
      final fechaVencimiento =
          DateTime(_fechaInicio.year, _fechaInicio.month + plazo, _fechaInicio.day);

      final prestamo = Prestamo(
        id: widget.prestamoId ?? const Uuid().v4(),
        clienteId: _clienteSeleccionado!,
        montoOriginal: monto,
        tasaInteres: double.parse(_tasaController.text.trim()),
        plazoMeses: plazo,
        fechaInicio: _fechaInicio,
        fechaVencimiento: fechaVencimiento,
        saldoPendiente: widget.esEdicion ? monto : monto,
        estado: 'activo',
        garantia: _garantiaController.text.trim().isEmpty
            ? null
            : _garantiaController.text.trim(),
        notas: _notasController.text.trim().isEmpty
            ? null
            : _notasController.text.trim(),
        fechaCreacion: DateTime.now(),
      );

      if (widget.esEdicion) {
        await ref.read(prestamosProvider.notifier).actualizar(prestamo);
      } else {
        await ref.read(prestamosProvider.notifier).crear(prestamo);
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
    if (widget.esEdicion) {
      final prestamoAsync = ref.watch(prestamoProvider(widget.prestamoId!));
      prestamoAsync.whenData((prestamo) {
        if (prestamo != null) {
          _cargarDatos(prestamo);
        }
      });
    }

    final clientesAsync = ref.watch(clientesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.esEdicion
              ? AppStrings.editarPrestamo
              : AppStrings.nuevoPrestamo,
        ),
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
                  onChanged: widget.esEdicion
                      ? null
                      : (value) {
                          setState(() => _clienteSeleccionado = value);
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

              TextFormField(
                controller: _montoController,
                decoration: const InputDecoration(
                  labelText: AppStrings.montoOriginal,
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
                controller: _tasaController,
                decoration: const InputDecoration(
                  labelText: AppStrings.tasaInteres,
                  prefixIcon: Icon(Icons.percent),
                  suffixText: '%',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                validator: AppValidators.porcentaje,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _plazoController,
                decoration: const InputDecoration(
                  labelText: AppStrings.plazoMeses,
                  prefixIcon: Icon(Icons.calendar_month),
                  suffixText: 'meses',
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: AppValidators.enteroPositivo,
              ),
              const SizedBox(height: 16),

              // Fecha de inicio
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event),
                title: const Text(AppStrings.fechaInicio),
                subtitle: Text(
                  '${_fechaInicio.day}/${_fechaInicio.month}/${_fechaInicio.year}',
                  style: AppTextStyles.bodyMedium,
                ),
                trailing: const Icon(Icons.edit_calendar),
                onTap: _seleccionarFecha,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _garantiaController,
                decoration: const InputDecoration(
                  labelText:
                      '${AppStrings.garantia} (${AppStrings.opcional})',
                  prefixIcon: Icon(Icons.security),
                ),
                textInputAction: TextInputAction.next,
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
                texto: AppStrings.guardar,
                onPressed: _guardar,
                isLoading: _isLoading,
                icono: Icons.save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
