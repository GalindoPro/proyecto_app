class Pago {
  final String id;
  final String clienteId;
  final String? prestamoId;
  final double monto;
  final DateTime fecha;
  final String metodoPago; // 'efectivo' | 'transferencia' | 'cheque' | 'tarjeta'
  final String concepto;
  final String estado; // 'pendiente' | 'completado' | 'cancelado'
  final String? notas;
  final String? comprobantePath;
  final DateTime fechaCreacion;

  const Pago({
    required this.id,
    required this.clienteId,
    this.prestamoId,
    required this.monto,
    required this.fecha,
    required this.metodoPago,
    required this.concepto,
    this.estado = 'completado',
    this.notas,
    this.comprobantePath,
    required this.fechaCreacion,
  });

  bool get estaCompletado => estado == 'completado';
  bool get estaPendiente => estado == 'pendiente';
  bool get estaCancelado => estado == 'cancelado';
  bool get tienePrestamo => prestamoId != null;

  factory Pago.fromMap(Map<String, dynamic> map) {
    return Pago(
      id: map['id'] as String,
      clienteId: map['cliente_id'] as String,
      prestamoId: map['prestamo_id'] as String?,
      monto: (map['monto'] as num).toDouble(),
      fecha: DateTime.parse(map['fecha'] as String),
      metodoPago: map['metodo_pago'] as String,
      concepto: map['concepto'] as String,
      estado: map['estado'] as String,
      notas: map['notas'] as String?,
      comprobantePath: map['comprobante_path'] as String?,
      fechaCreacion: DateTime.parse(map['fecha_creacion'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cliente_id': clienteId,
      'prestamo_id': prestamoId,
      'monto': monto,
      'fecha': fecha.toIso8601String(),
      'metodo_pago': metodoPago,
      'concepto': concepto,
      'estado': estado,
      'notas': notas,
      'comprobante_path': comprobantePath,
      'fecha_creacion': fechaCreacion.toIso8601String(),
    };
  }

  Pago copyWith({
    String? id,
    String? clienteId,
    String? prestamoId,
    double? monto,
    DateTime? fecha,
    String? metodoPago,
    String? concepto,
    String? estado,
    String? notas,
    String? comprobantePath,
    DateTime? fechaCreacion,
  }) {
    return Pago(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      prestamoId: prestamoId ?? this.prestamoId,
      monto: monto ?? this.monto,
      fecha: fecha ?? this.fecha,
      metodoPago: metodoPago ?? this.metodoPago,
      concepto: concepto ?? this.concepto,
      estado: estado ?? this.estado,
      notas: notas ?? this.notas,
      comprobantePath: comprobantePath ?? this.comprobantePath,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }
}
