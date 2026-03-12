import '../core/database/database_helper.dart';
import '../models/pago.dart';

class PagoRepository {
  final _db = DatabaseHelper.instance;

  Future<List<Pago>> obtenerTodos() async {
    try {
      final rows = await _db.queryAll(
        'pagos',
        orderBy: 'fecha DESC',
      );
      return rows.map(Pago.fromMap).toList();
    } catch (e) {
      throw Exception('Error al obtener pagos: $e');
    }
  }

  Future<List<Pago>> obtenerPorCliente(String clienteId) async {
    try {
      final rows = await _db.queryAll(
        'pagos',
        where: 'cliente_id = ?',
        whereArgs: [clienteId],
        orderBy: 'fecha DESC',
      );
      return rows.map(Pago.fromMap).toList();
    } catch (e) {
      throw Exception('Error al obtener pagos del cliente: $e');
    }
  }

  Future<List<Pago>> obtenerPorPrestamo(String prestamoId) async {
    try {
      final rows = await _db.queryAll(
        'pagos',
        where: 'prestamo_id = ?',
        whereArgs: [prestamoId],
        orderBy: 'fecha DESC',
      );
      return rows.map(Pago.fromMap).toList();
    } catch (e) {
      throw Exception('Error al obtener pagos del préstamo: $e');
    }
  }

  Future<List<Pago>> obtenerRecientes({int limite = 10}) async {
    try {
      final rows = await _db.rawQuery(
        'SELECT * FROM pagos ORDER BY fecha DESC LIMIT ?',
        [limite],
      );
      return rows.map(Pago.fromMap).toList();
    } catch (e) {
      throw Exception('Error al obtener pagos recientes: $e');
    }
  }

  Future<List<Pago>> obtenerPorMes(int anio, int mes) async {
    try {
      final mesStr = '$anio-${mes.toString().padLeft(2, '0')}';
      final rows = await _db.rawQuery(
        '''
        SELECT * FROM pagos
        WHERE strftime('%Y-%m', fecha) = ?
        ORDER BY fecha DESC
        ''',
        [mesStr],
      );
      return rows.map(Pago.fromMap).toList();
    } catch (e) {
      throw Exception('Error al obtener pagos del mes: $e');
    }
  }

  Future<Pago?> obtenerPorId(String id) async {
    try {
      final map = await _db.queryById('pagos', id);
      if (map == null) {
        return null;
      }
      return Pago.fromMap(map);
    } catch (e) {
      throw Exception('Error al obtener pago: $e');
    }
  }

  Future<void> crear(Pago pago) async {
    try {
      await _db.insert('pagos', pago.toMap());
    } catch (e) {
      throw Exception('Error al crear pago: $e');
    }
  }

  Future<void> actualizar(Pago pago) async {
    try {
      await _db.update(
        'pagos',
        pago.toMap(),
        where: 'id = ?',
        whereArgs: [pago.id],
      );
    } catch (e) {
      throw Exception('Error al actualizar pago: $e');
    }
  }

  Future<void> eliminar(String id) async {
    try {
      await _db.delete(
        'pagos',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Error al eliminar pago: $e');
    }
  }

  Future<double> totalCobradoMes(int anio, int mes) async {
    try {
      final mesStr = '$anio-${mes.toString().padLeft(2, '0')}';
      final result = await _db.rawQuery(
        '''
        SELECT COALESCE(SUM(monto), 0) as total FROM pagos
        WHERE estado = 'completado'
        AND strftime('%Y-%m', fecha) = ?
        ''',
        [mesStr],
      );
      return (result.first['total'] as num).toDouble();
    } catch (e) {
      throw Exception('Error al calcular total cobrado: $e');
    }
  }
}
