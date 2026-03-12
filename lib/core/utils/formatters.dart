import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  // === Moneda ===

  static final _currencyFormat = NumberFormat.currency(
    locale: 'es_GT',
    symbol: 'Q',
    decimalDigits: 2,
  );

  static String moneda(double monto) {
    return _currencyFormat.format(monto);
  }

  // === Teléfono ===

  static String telefono(String numero) {
    if (numero.length == 8) {
      return '${numero.substring(0, 4)}-${numero.substring(4)}';
    }
    return numero;
  }

  // === Fechas ===

  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final _monthYearFormat = DateFormat('MMMM yyyy', 'es');
  static final _shortDateFormat = DateFormat('dd MMM', 'es');

  static String fecha(DateTime date) {
    return _dateFormat.format(date);
  }

  static String fechaHora(DateTime date) {
    return _dateTimeFormat.format(date);
  }

  static String mesAnio(DateTime date) {
    return _monthYearFormat.format(date);
  }

  static String fechaCorta(DateTime date) {
    return _shortDateFormat.format(date);
  }

  static String fechaRelativa(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Hoy';
    } else if (diff.inDays == 1) {
      return 'Ayer';
    } else if (diff.inDays < 7) {
      return 'Hace ${diff.inDays} días';
    } else if (diff.inDays < 30) {
      final semanas = (diff.inDays / 7).floor();
      return 'Hace $semanas semana${semanas > 1 ? 's' : ''}';
    } else {
      return _dateFormat.format(date);
    }
  }

  // === Porcentaje ===

  static String porcentaje(double valor) {
    return '${valor.toStringAsFixed(1)}%';
  }

  // === Número ===

  static String numero(int valor) {
    return NumberFormat('#,##0', 'es').format(valor);
  }

  // === DPI ===

  static String dpi(String numero) {
    if (numero.length == 13) {
      return '${numero.substring(0, 4)} ${numero.substring(4, 9)} ${numero.substring(9)}';
    }
    return numero;
  }
}
