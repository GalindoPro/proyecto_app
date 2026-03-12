class ResumenFinanciero {
  final double carteraActiva;
  final double cobradoMes;
  final double pendienteCobro;
  final int prestamosActivos;
  final int prestamosVencidos;
  final int clientesActivos;

  const ResumenFinanciero({
    required this.carteraActiva,
    required this.cobradoMes,
    required this.pendienteCobro,
    required this.prestamosActivos,
    required this.prestamosVencidos,
    required this.clientesActivos,
  });

  factory ResumenFinanciero.vacio() {
    return const ResumenFinanciero(
      carteraActiva: 0,
      cobradoMes: 0,
      pendienteCobro: 0,
      prestamosActivos: 0,
      prestamosVencidos: 0,
      clientesActivos: 0,
    );
  }

  factory ResumenFinanciero.fromMap(Map<String, dynamic> map) {
    return ResumenFinanciero(
      carteraActiva: (map['cartera_activa'] as num?)?.toDouble() ?? 0,
      cobradoMes: (map['cobrado_mes'] as num?)?.toDouble() ?? 0,
      pendienteCobro: (map['pendiente_total'] as num?)?.toDouble() ?? 0,
      prestamosActivos: (map['prestamos_activos'] as int?) ?? 0,
      prestamosVencidos: (map['prestamos_vencidos'] as int?) ?? 0,
      clientesActivos: (map['total_clientes'] as int?) ?? 0,
    );
  }
}
