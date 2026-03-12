import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../models/cliente.dart';
import '../../providers/cliente_provider.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/loading_button.dart';

class FormClienteScreen extends ConsumerStatefulWidget {
  final String? clienteId;

  const FormClienteScreen({super.key, this.clienteId});

  bool get esEdicion => clienteId != null;

  @override
  ConsumerState<FormClienteScreen> createState() => _FormClienteScreenState();
}

class _FormClienteScreenState extends ConsumerState<FormClienteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _direccionController = TextEditingController();
  final _dpiController = TextEditingController();
  String? _fotoPath;
  bool _isLoading = false;
  bool _loaded = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _direccionController.dispose();
    _dpiController.dispose();
    super.dispose();
  }

  void _cargarDatos(Cliente cliente) {
    if (_loaded) {
      return;
    }
    _loaded = true;
    _nombreController.text = cliente.nombre;
    _apellidoController.text = cliente.apellido;
    _telefonoController.text = cliente.telefono;
    _emailController.text = cliente.email ?? '';
    _direccionController.text = cliente.direccion ?? '';
    _dpiController.text = cliente.dpi ?? '';
    _fotoPath = cliente.fotoPath;
  }

  Future<void> _seleccionarFoto() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
      );
      if (image != null) {
        setState(() {
          _fotoPath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, 'Error al seleccionar foto');
      }
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cliente = Cliente(
        id: widget.clienteId ?? const Uuid().v4(),
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        telefono: _telefonoController.text.replaceAll(RegExp(r'[\s\-]'), ''),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        direccion: _direccionController.text.trim().isEmpty
            ? null
            : _direccionController.text.trim(),
        dpi: _dpiController.text.trim().isEmpty
            ? null
            : _dpiController.text.trim(),
        fotoPath: _fotoPath,
        fechaRegistro: DateTime.now(),
        activo: true,
      );

      if (widget.esEdicion) {
        await ref.read(clientesProvider.notifier).actualizar(cliente);
      } else {
        await ref.read(clientesProvider.notifier).crear(cliente);
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
    // Si es edición, cargar datos del cliente
    if (widget.esEdicion) {
      final clienteAsync = ref.watch(clienteProvider(widget.clienteId!));
      clienteAsync.whenData((cliente) {
        if (cliente != null) {
          _cargarDatos(cliente);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.esEdicion ? AppStrings.editarCliente : AppStrings.nuevoCliente,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Foto
              GestureDetector(
                onTap: _seleccionarFoto,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  backgroundImage:
                      _fotoPath != null ? AssetImage(_fotoPath!) : null,
                  child: _fotoPath == null
                      ? const Icon(Icons.camera_alt, size: 32)
                      : null,
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: AppStrings.nombre,
                  prefixIcon: Icon(Icons.person),
                ),
                textInputAction: TextInputAction.next,
                validator: AppValidators.requerido,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _apellidoController,
                decoration: const InputDecoration(
                  labelText: AppStrings.apellido,
                  prefixIcon: Icon(Icons.person_outline),
                ),
                textInputAction: TextInputAction.next,
                validator: AppValidators.requerido,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(
                  labelText: AppStrings.telefono,
                  prefixIcon: Icon(Icons.phone),
                  hintText: '5555-1234',
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: AppValidators.telefono,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: '${AppStrings.email} (${AppStrings.opcional})',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(
                  labelText:
                      '${AppStrings.direccion} (${AppStrings.opcional})',
                  prefixIcon: Icon(Icons.location_on),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _dpiController,
                decoration: const InputDecoration(
                  labelText: '${AppStrings.dpi} (${AppStrings.opcional})',
                  prefixIcon: Icon(Icons.badge),
                  hintText: '1234567890123',
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                validator: AppValidators.dpi,
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
