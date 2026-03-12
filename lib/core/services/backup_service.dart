import 'dart:io';

import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';

class BackupService {
  BackupService._();

  static Future<String> obtenerRutaDb() async {
    final dbPath = await getDatabasesPath();
    return join(dbPath, 'capital_pro.db');
  }

  static Future<File> exportarBackup() async {
    try {
      final dbPath = await obtenerRutaDb();
      final original = File(dbPath);

      if (!await original.exists()) {
        throw Exception('No se encontró la base de datos');
      }

      final dir = await getDatabasesPath();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupPath = join(dir, 'capital_pro_backup_$timestamp.db');

      return await original.copy(backupPath);
    } catch (e) {
      throw Exception('Error al exportar backup: $e');
    }
  }

  static Future<void> compartirBackup() async {
    try {
      final backup = await exportarBackup();
      await Share.shareXFiles(
        [XFile(backup.path)],
        text: 'Backup Capital Pro',
      );
    } catch (e) {
      throw Exception('Error al compartir backup: $e');
    }
  }

  static Future<void> importarBackup(String sourcePath) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        throw Exception('El archivo de backup no existe');
      }

      final dbPath = await obtenerRutaDb();

      // Cerrar la base de datos actual antes de reemplazar
      await deleteDatabase(dbPath);

      // Copiar el backup como la base de datos principal
      await sourceFile.copy(dbPath);
    } catch (e) {
      throw Exception('Error al importar backup: $e');
    }
  }
}
