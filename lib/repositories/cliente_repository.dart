import '../core/database/database_helper.dart';
import '../models/cliente.dart';

class ClienteRepository {
  final _db = DatabaseHelper.instance;

  Future<List<Cliente>> obtenerTodos() async {
    try {
      final rows = await _db.queryAll(
        'clientes',
        where: 'activo = ?',
        whereArgs: [1],
        orderBy: 'nombre ASC',
      );
      return rows.map(Cliente.fromMap).toList();
    } catch (e) {
      throw Exception('Error al obtener clientes: $e');
    }
  }

  Future<Cliente?> obtenerPorId(String id) async {
    try {
      final map = await _db.queryById('clientes', id);
      if (map == null) {
        return null;
      }
      return Cliente.fromMap(map);
    } catch (e) {
      throw Exception('Error al obtener cliente: $e');
    }
  }

  Future<List<Cliente>> buscar(String query) async {
    try {
      final rows = await _db.rawQuery(
        '''
        SELECT * FROM clientes
        WHERE activo = 1
          AND (nombre LIKE ? OR apellido LIKE ? OR telefono LIKE ?)
        ORDER BY nombre ASC
        ''',
        ['%$query%', '%$query%', '%$query%'],
      );
      return rows.map(Cliente.fromMap).toList();
    } catch (e) {
      throw Exception('Error al buscar clientes: $e');
    }
  }

  Future<void> crear(Cliente cliente) async {
    try {
      await _db.insert('clientes', cliente.toMap());
    } catch (e) {
      throw Exception('Error al crear cliente: $e');
    }
  }

  Future<void> actualizar(Cliente cliente) async {
    try {
      await _db.update(
        'clientes',
        cliente.toMap(),
        where: 'id = ?',
        whereArgs: [cliente.id],
      );
    } catch (e) {
      throw Exception('Error al actualizar cliente: $e');
    }
  }

  Future<void> eliminar(String id) async {
    try {
      // Soft delete
      await _db.update(
        'clientes',
        {'activo': 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Error al eliminar cliente: $e');
    }
  }

  Future<int> contarActivos() async {
    try {
      final result = await _db.rawQuery(
        'SELECT COUNT(*) as total FROM clientes WHERE activo = 1',
      );
      return result.first['total'] as int;
    } catch (e) {
      throw Exception('Error al contar clientes: $e');
    }
  }
}
