import '../core/database/database_helper.dart';
import '../models/prestamo.dart';
import '../models/resumen_financiero.dart';

class PrestamoRepository {
  final _db = DatabaseHelper.instance;

  Future<List<Prestamo>> obtenerTodos() async {
    try {
      final rows = await _db.queryAll(
        'prestamos',
        orderBy: 'fecha_creacion DESC',
      );
      return rows.map(Prestamo.fromMap).toList();
    } catch (e) {
      throw Exception('Error al obtener préstamos: $e');
    }
  }

  Future<List<Prestamo>> obtenerPorCliente(String clienteId) async {
    try {
      final rows = await _db.queryAll(
        'prestamos',
        where: 'cliente_id = ?',
        whereArgs: [clienteId],
        orderBy: 'fecha_creacion DESC',
      );
      return rows.map(Prestamo.fromMap).toList();
    } catch (e) {
      throw Exception('Error al obtener préstamos del cliente: $e');
    }
  }

  Future<List<Prestamo>> obtenerActivos() async {
    try {
      final rows = await _db.queryAll(
        'prestamos',
        where: 'estado = ?',
        whereArgs: ['activo'],
        orderBy: 'fecha_vencimiento ASC',
      );
      return rows.map(Prestamo.fromMap).toList();
    } catch (e) {
      throw Exception('Error al obtener préstamos activos: $e');
    }
  }

  Future<List<Prestamo>> obtenerVencidos() async {
    try {
      final now = DateTime.now().toIso8601String();
      final rows = await _db.rawQuery(
        '''
        SELECT * FROM prestamos
        WHERE estado = 'activo' AND fecha_vencimiento < ?
        ORDER BY fecha_vencimiento ASC
        ''',
        [now],
      );
      return rows.map(Prestamo.fromMap).toList();
    } catch (e) {
      throw Exception('Error al obtener préstamos vencidos: $e');
    }
  }

  Future<Prestamo?> obtenerPorId(String id) async {
    try {
      final map = await _db.queryById('prestamos', id);
      if (map == null) {
        return null;
      }
      return Prestamo.fromMap(map);
    } catch (e) {
      throw Exception('Error al obtener préstamo: $e');
    }
  }

  Future<void> crear(Prestamo prestamo) async {
    try {
      await _db.insert('prestamos', prestamo.toMap());
    } catch (e) {
      throw Exception('Error al crear préstamo: $e');
    }
  }

  Future<void> actualizar(Prestamo prestamo) async {
    try {
      await _db.update(
        'prestamos',
        prestamo.toMap(),
        where: 'id = ?',
        whereArgs: [prestamo.id],
      );
    } catch (e) {
      throw Exception('Error al actualizar préstamo: $e');
    }
  }

  Future<void> actualizarSaldo(String id, double nuevoSaldo) async {
    try {
      final data = <String, dynamic>{'saldo_pendiente': nuevoSaldo};
      if (nuevoSaldo <= 0) {
        data['estado'] = 'pagado';
        data['saldo_pendiente'] = 0.0;
      }
      await _db.update(
        'prestamos',
        data,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Error al actualizar saldo: $e');
    }
  }

  Future<ResumenFinanciero> obtenerResumen() async {
    try {
      final now = DateTime.now().toIso8601String();
      final mesActual =
          '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';

      final result = await _db.rawQuery('''
        SELECT
          (SELECT COALESCE(SUM(saldo_pendiente), 0) FROM prestamos WHERE estado = 'activo') AS cartera_activa,
          (SELECT COALESCE(SUM(monto), 0) FROM pagos
           WHERE estado = 'completado'
           AND strftime('%Y-%m', fecha) = ?) AS cobrado_mes,
          (SELECT COALESCE(SUM(monto), 0) FROM pagos WHERE estado = 'pendiente') AS pendiente_total,
          (SELECT COUNT(*) FROM prestamos WHERE estado = 'activo') AS prestamos_activos,
          (SELECT COUNT(*) FROM prestamos
           WHERE estado = 'activo' AND fecha_vencimiento < ?) AS prestamos_vencidos,
          (SELECT COUNT(*) FROM clientes WHERE activo = 1) AS total_clientes
      ''', [mesActual, now]);

      if (result.isEmpty) {
        return ResumenFinanciero.vacio();
      }
      return ResumenFinanciero.fromMap(result.first);
    } catch (e) {
      throw Exception('Error al obtener resumen: $e');
    }
  }
}
