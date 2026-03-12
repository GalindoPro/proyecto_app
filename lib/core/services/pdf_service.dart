import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import '../../models/cliente.dart';
import '../../models/prestamo.dart';
import '../../models/pago.dart';

class PdfService {
  PdfService._();

  static Future<Uint8List> generarResumenCliente({
    required Cliente cliente,
    required List<Prestamo> prestamos,
    required List<Pago> pagos,
  }) async {
    final pdf = pw.Document();
    final fechaHoy = DateFormat('dd/MM/yyyy').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(fechaHoy),
        build: (context) => [
          _buildClienteInfo(cliente),
          pw.SizedBox(height: 20),
          if (prestamos.isNotEmpty) ...[
            _buildSectionTitle('Préstamos'),
            _buildPrestamosTable(prestamos),
            pw.SizedBox(height: 20),
          ],
          if (pagos.isNotEmpty) ...[
            _buildSectionTitle('Historial de pagos'),
            _buildPagosTable(pagos),
          ],
        ],
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> generarResumenMensual({
    required String mes,
    required double totalCobrado,
    required double totalPendiente,
    required int totalPrestamosActivos,
    required int totalPrestamosVencidos,
    required List<Pago> pagos,
  }) async {
    final pdf = pw.Document();
    final fechaHoy = DateFormat('dd/MM/yyyy').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(fechaHoy),
        build: (context) => [
          pw.Center(
            child: pw.Text(
              'Resumen mensual — $mes',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),
          _buildResumenRow('Total cobrado', 'Q ${totalCobrado.toStringAsFixed(2)}'),
          _buildResumenRow('Total pendiente', 'Q ${totalPendiente.toStringAsFixed(2)}'),
          _buildResumenRow('Préstamos activos', '$totalPrestamosActivos'),
          _buildResumenRow('Préstamos vencidos', '$totalPrestamosVencidos'),
          pw.SizedBox(height: 20),
          if (pagos.isNotEmpty) ...[
            _buildSectionTitle('Detalle de pagos'),
            _buildPagosTable(pagos),
          ],
        ],
      ),
    );

    return pdf.save();
  }

  static Future<void> imprimirPdf(Uint8List pdfData, String nombre) async {
    await Printing.layoutPdf(
      onLayout: (_) => pdfData,
      name: nombre,
    );
  }

  static Future<void> compartirPdf(Uint8List pdfData, String nombre) async {
    await Printing.sharePdf(bytes: pdfData, filename: nombre);
  }

  // === Helpers privados ===

  static pw.Widget _buildHeader(String fecha) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Capital Pro',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(fecha, style: const pw.TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  static pw.Widget _buildClienteInfo(Cliente cliente) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '${cliente.nombre} ${cliente.apellido}',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text('Teléfono: ${cliente.telefono}'),
          if (cliente.email != null) pw.Text('Email: ${cliente.email}'),
          if (cliente.direccion != null) pw.Text('Dirección: ${cliente.direccion}'),
        ],
      ),
    );
  }

  static pw.Widget _buildSectionTitle(String titulo) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Text(
        titulo,
        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.Widget _buildPrestamosTable(List<Prestamo> prestamos) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignment: pw.Alignment.centerLeft,
      headers: ['Monto', 'Tasa', 'Plazo', 'Saldo', 'Estado'],
      data: prestamos
          .map((p) => [
                'Q ${p.montoOriginal.toStringAsFixed(2)}',
                '${p.tasaInteres}%',
                '${p.plazoMeses} meses',
                'Q ${p.saldoPendiente.toStringAsFixed(2)}',
                p.estado,
              ])
          .toList(),
    );
  }

  static pw.Widget _buildPagosTable(List<Pago> pagos) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignment: pw.Alignment.centerLeft,
      headers: ['Fecha', 'Concepto', 'Monto', 'Método', 'Estado'],
      data: pagos
          .map((p) => [
                dateFormat.format(p.fecha),
                p.concepto,
                'Q ${p.monto.toStringAsFixed(2)}',
                p.metodoPago,
                p.estado,
              ])
          .toList(),
    );
  }

  static pw.Widget _buildResumenRow(String label, String valor) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
          pw.Text(
            valor,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
