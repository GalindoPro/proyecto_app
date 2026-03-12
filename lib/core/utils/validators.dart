import '../constants/app_strings.dart';

class AppValidators {
  AppValidators._();

  static String? requerido(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.campoRequerido;
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.campoRequerido;
    }
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value.trim())) {
      return AppStrings.emailInvalido;
    }
    return null;
  }

  static String? telefono(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.campoRequerido;
    }
    final limpio = value.replaceAll(RegExp(r'[\s\-]'), '');
    if (limpio.length != 8 || !RegExp(r'^\d{8}$').hasMatch(limpio)) {
      return AppStrings.telefonoInvalido;
    }
    return null;
  }

  static String? monto(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.campoRequerido;
    }
    final numero = double.tryParse(value.trim());
    if (numero == null || numero <= 0) {
      return AppStrings.montoInvalido;
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.campoRequerido;
    }
    if (value.length < 6) {
      return AppStrings.passwordCorto;
    }
    return null;
  }

  static String? confirmarPassword(String? value, String password) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.campoRequerido;
    }
    if (value != password) {
      return AppStrings.passwordsNoCoinciden;
    }
    return null;
  }

  static String? dpi(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // DPI es opcional
    }
    final limpio = value.replaceAll(RegExp(r'[\s]'), '');
    if (limpio.length != 13 || !RegExp(r'^\d{13}$').hasMatch(limpio)) {
      return AppStrings.dpiInvalido;
    }
    return null;
  }

  static String? enteroPositivo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.campoRequerido;
    }
    final numero = int.tryParse(value.trim());
    if (numero == null || numero <= 0) {
      return 'Ingrese un número entero mayor a 0';
    }
    return null;
  }

  static String? porcentaje(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.campoRequerido;
    }
    final numero = double.tryParse(value.trim());
    if (numero == null || numero <= 0 || numero > 100) {
      return 'Ingrese un porcentaje válido (0-100)';
    }
    return null;
  }
}
