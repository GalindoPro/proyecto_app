class Prestamo {
  final String id;
  final String clienteId;
  final double montoOriginal;
  final double tasaInteres;
  final int plazoMeses;
  final DateTime fechaInicio;
  final DateTime fechaVencimiento;
  final double saldoPendiente;
  final String estado; // 'activo' | 'pagado' | 'vencido' | 'cancelado'
  final String? garantia;
  final String? notas;
  final DateTime fechaCreacion;

  const Prestamo({
    required this.id,
    required this.clienteId,
    required this.montoOriginal,
    required this.tasaInteres,
    required this.plazoMeses,
    required this.fechaInicio,
    required this.fechaVencimiento,
    required this.saldoPendiente,
    this.estado = 'activo',
    this.garantia,
    this.notas,
    required this.fechaCreacion,
  });

  bool get estaActivo => estado == 'activo';
  bool get estaPagado => estado == 'pagado';
  bool get estaVencido =>
      estado == 'activo' && DateTime.now().isAfter(fechaVencimiento);

  double get interesTotal => montoOriginal * (tasaInteres / 100) * plazoMeses;
  double get montoTotal => montoOriginal + interesTotal;
  double get montoPagado => montoOriginal - saldoPendiente;
  double get porcentajePagado =>
      montoOriginal > 0 ? (montoPagado / montoOriginal) * 100 : 0;
  double get cuotaMensual =>
      plazoMeses > 0 ? montoTotal / plazoMeses : montoTotal;

  factory Prestamo.fromMap(Map<String, dynamic> map) {
    return Prestamo(
      id: map['id'] as String,
      clienteId: map['cliente_id'] as String,
      montoOriginal: (map['monto_original'] as num).toDouble(),
      tasaInteres: (map['tasa_interes'] as num).toDouble(),
      plazoMeses: map['plazo_meses'] as int,
      fechaInicio: DateTime.parse(map['fecha_inicio'] as String),
      fechaVencimiento: DateTime.parse(map['fecha_vencimiento'] as String),
      saldoPendiente: (map['saldo_pendiente'] as num).toDouble(),
      estado: map['estado'] as String,
      garantia: map['garantia'] as String?,
      notas: map['notas'] as String?,
      fechaCreacion: DateTime.parse(map['fecha_creacion'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cliente_id': clienteId,
      'monto_original': montoOriginal,
      'tasa_interes': tasaInteres,
      'plazo_meses': plazoMeses,
      'fecha_inicio': fechaInicio.toIso8601String(),
      'fecha_vencimiento': fechaVencimiento.toIso8601String(),
      'saldo_pendiente': saldoPendiente,
      'estado': estado,
      'garantia': garantia,
      'notas': notas,
      'fecha_creacion': fechaCreacion.toIso8601String(),
    };
  }

  Prestamo copyWith({
    String? id,
    String? clienteId,
    double? montoOriginal,
    double? tasaInteres,
    int? plazoMeses,
    DateTime? fechaInicio,
    DateTime? fechaVencimiento,
    double? saldoPendiente,
    String? estado,
    String? garantia,
    String? notas,
    DateTime? fechaCreacion,
  }) {
    return Prestamo(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      montoOriginal: montoOriginal ?? this.montoOriginal,
      tasaInteres: tasaInteres ?? this.tasaInteres,
      plazoMeses: plazoMeses ?? this.plazoMeses,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      saldoPendiente: saldoPendiente ?? this.saldoPendiente,
      estado: estado ?? this.estado,
      garantia: garantia ?? this.garantia,
      notas: notas ?? this.notas,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }
}
