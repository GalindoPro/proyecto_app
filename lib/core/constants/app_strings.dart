class AppStrings {
  AppStrings._();

  // General
  static const String appName = 'Capital Pro';
  static const String guardar = 'Guardar';
  static const String cancelar = 'Cancelar';
  static const String eliminar = 'Eliminar';
  static const String editar = 'Editar';
  static const String buscar = 'Buscar';
  static const String cargando = 'Cargando...';
  static const String sinResultados = 'No se encontraron resultados';
  static const String confirmar = 'Confirmar';
  static const String aceptar = 'Aceptar';
  static const String si = 'Sí';
  static const String no = 'No';
  static const String todos = 'Todos';
  static const String verTodos = 'Ver todos';
  static const String notas = 'Notas';
  static const String opcional = 'Opcional';

  // Éxito
  static const String guardadoExito = 'Guardado exitosamente';
  static const String eliminadoExito = 'Eliminado exitosamente';
  static const String actualizadoExito = 'Actualizado exitosamente';

  // Errores
  static const String errorGeneral = 'Ocurrió un error inesperado';
  static const String errorConexion = 'Error de conexión';
  static const String errorCargar = 'Error al cargar los datos';
  static const String errorGuardar = 'Error al guardar';
  static const String errorEliminar = 'Error al eliminar';
  static const String intentarDeNuevo = 'Intentar de nuevo';

  // Validaciones
  static const String campoRequerido = 'Este campo es requerido';
  static const String emailInvalido = 'Ingrese un email válido';
  static const String telefonoInvalido = 'Ingrese un teléfono válido (8 dígitos)';
  static const String montoInvalido = 'Ingrese un monto válido';
  static const String passwordCorto = 'La contraseña debe tener al menos 6 caracteres';
  static const String passwordsNoCoinciden = 'Las contraseñas no coinciden';
  static const String dpiInvalido = 'El DPI debe tener 13 dígitos';

  // Auth
  static const String iniciarSesion = 'Iniciar sesión';
  static const String registrarse = 'Registrarse';
  static const String cerrarSesion = 'Cerrar sesión';
  static const String email = 'Correo electrónico';
  static const String password = 'Contraseña';
  static const String confirmarPassword = 'Confirmar contraseña';
  static const String nombre = 'Nombre';
  static const String noTienesCuenta = '¿No tienes cuenta?';
  static const String yaTienesCuenta = '¿Ya tienes cuenta?';
  static const String credencialesInvalidas = 'Correo o contraseña incorrectos';
  static const String emailYaRegistrado = 'Este correo ya está registrado';
  static const String bienvenido = 'Bienvenido';

  // Dashboard
  static const String dashboard = 'Dashboard';
  static const String resumenFinanciero = 'Resumen financiero';
  static const String carteraActiva = 'Cartera activa';
  static const String cobradoMes = 'Cobrado este mes';
  static const String pendienteCobro = 'Pendiente de cobro';
  static const String prestamosActivos = 'Préstamos activos';
  static const String prestamosVencidos = 'Préstamos vencidos';
  static const String clientesActivos = 'Clientes activos';
  static const String actividadReciente = 'Actividad reciente';

  // Clientes
  static const String clientes = 'Clientes';
  static const String nuevoCliente = 'Nuevo cliente';
  static const String editarCliente = 'Editar cliente';
  static const String detalleCliente = 'Detalle del cliente';
  static const String apellido = 'Apellido';
  static const String telefono = 'Teléfono';
  static const String direccion = 'Dirección';
  static const String dpi = 'DPI';
  static const String foto = 'Foto';
  static const String sinClientes = 'No hay clientes registrados';
  static const String confirmarEliminarCliente = '¿Está seguro de eliminar este cliente?';
  static const String eliminarClienteDetalle =
      'Se desactivará el cliente y ya no aparecerá en las listas.';
  static const String enviarWhatsapp = 'Enviar WhatsApp';
  static const String llamar = 'Llamar';

  // Préstamos
  static const String prestamos = 'Préstamos';
  static const String nuevoPrestamo = 'Nuevo préstamo';
  static const String editarPrestamo = 'Editar préstamo';
  static const String detallePrestamo = 'Detalle del préstamo';
  static const String montoOriginal = 'Monto original';
  static const String tasaInteres = 'Tasa de interés (% mensual)';
  static const String plazoMeses = 'Plazo (meses)';
  static const String fechaInicio = 'Fecha de inicio';
  static const String fechaVencimiento = 'Fecha de vencimiento';
  static const String saldoPendiente = 'Saldo pendiente';
  static const String garantia = 'Garantía';
  static const String sinPrestamos = 'No hay préstamos registrados';
  static const String seleccioneCliente = 'Seleccione un cliente';

  // Estados de préstamos
  static const String estadoActivo = 'Activo';
  static const String estadoPagado = 'Pagado';
  static const String estadoVencido = 'Vencido';
  static const String estadoCancelado = 'Cancelado';

  // Pagos
  static const String pagos = 'Pagos';
  static const String nuevoPago = 'Nuevo pago';
  static const String detallePago = 'Detalle del pago';
  static const String monto = 'Monto';
  static const String fecha = 'Fecha';
  static const String metodoPago = 'Método de pago';
  static const String concepto = 'Concepto';
  static const String estado = 'Estado';
  static const String comprobante = 'Comprobante';
  static const String sinPagos = 'No hay pagos registrados';
  static const String registrarPago = 'Registrar pago';

  // Métodos de pago
  static const String efectivo = 'Efectivo';
  static const String transferencia = 'Transferencia';
  static const String cheque = 'Cheque';
  static const String tarjeta = 'Tarjeta';

  // Estados de pagos
  static const String pagoCompletado = 'Completado';
  static const String pagoPendiente = 'Pendiente';
  static const String pagoCancelado = 'Cancelado';

  // Reportes
  static const String reportes = 'Reportes';
  static const String generarReporte = 'Generar reporte';
  static const String exportarPdf = 'Exportar PDF';
  static const String exportarDatos = 'Exportar datos';
  static const String importarDatos = 'Importar datos';
  static const String resumenMensual = 'Resumen mensual';
  static const String historialPagos = 'Historial de pagos';

  // Confirmaciones
  static const String confirmarCerrarSesion = '¿Está seguro de cerrar sesión?';
  static const String confirmarEliminar = '¿Está seguro de eliminar?';
  static const String accionIrreversible = 'Esta acción no se puede deshacer.';
}
