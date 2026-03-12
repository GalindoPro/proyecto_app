import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'capital_pro.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        fecha_registro TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE clientes (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        apellido TEXT NOT NULL,
        telefono TEXT NOT NULL,
        email TEXT,
        direccion TEXT,
        dpi TEXT,
        foto_path TEXT,
        fecha_registro TEXT NOT NULL,
        activo INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE prestamos (
        id TEXT PRIMARY KEY,
        cliente_id TEXT NOT NULL,
        monto_original REAL NOT NULL,
        tasa_interes REAL NOT NULL,
        plazo_meses INTEGER NOT NULL,
        fecha_inicio TEXT NOT NULL,
        fecha_vencimiento TEXT NOT NULL,
        saldo_pendiente REAL NOT NULL,
        estado TEXT NOT NULL DEFAULT 'activo',
        garantia TEXT,
        notas TEXT,
        fecha_creacion TEXT NOT NULL,
        FOREIGN KEY (cliente_id) REFERENCES clientes(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE pagos (
        id TEXT PRIMARY KEY,
        cliente_id TEXT NOT NULL,
        prestamo_id TEXT,
        monto REAL NOT NULL,
        fecha TEXT NOT NULL,
        metodo_pago TEXT NOT NULL,
        concepto TEXT NOT NULL,
        estado TEXT NOT NULL DEFAULT 'completado',
        notas TEXT,
        comprobante_path TEXT,
        fecha_creacion TEXT NOT NULL,
        FOREIGN KEY (cliente_id) REFERENCES clientes(id),
        FOREIGN KEY (prestamo_id) REFERENCES prestamos(id)
      )
    ''');
  }

  // === CRUD genérico ===

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> queryAll(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
  }

  Future<Map<String, dynamic>?> queryById(String table, String id) async {
    final db = await database;
    final results = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) {
      return null;
    }
    return results.first;
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(
      table,
      data,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
