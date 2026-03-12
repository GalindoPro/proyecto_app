import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/prestamo.dart';
import '../models/resumen_financiero.dart';
import '../repositories/prestamo_repository.dart';

class PrestamosNotifier extends AsyncNotifier<List<Prestamo>> {
  late final _repo = PrestamoRepository();

  @override
  Future<List<Prestamo>> build() async {
    return _repo.obtenerTodos();
  }

  Future<void> crear(Prestamo prestamo) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.crear(prestamo);
      return _repo.obtenerTodos();
    });
  }

  Future<void> actualizar(Prestamo prestamo) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.actualizar(prestamo);
      return _repo.obtenerTodos();
    });
  }

  Future<void> actualizarSaldo(String id, double nuevoSaldo) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.actualizarSaldo(id, nuevoSaldo);
      return _repo.obtenerTodos();
    });
  }
}

final prestamosProvider =
    AsyncNotifierProvider<PrestamosNotifier, List<Prestamo>>(
        PrestamosNotifier.new);

// Provider para un préstamo individual
final prestamoProvider =
    FutureProvider.family<Prestamo?, String>((ref, id) async {
  final repo = PrestamoRepository();
  return repo.obtenerPorId(id);
});

// Provider para préstamos de un cliente
final prestamosPorClienteProvider =
    FutureProvider.family<List<Prestamo>, String>((ref, clienteId) async {
  final repo = PrestamoRepository();
  return repo.obtenerPorCliente(clienteId);
});

// Provider para préstamos vencidos
final prestamosVencidosProvider = FutureProvider<List<Prestamo>>((ref) async {
  final repo = PrestamoRepository();
  return repo.obtenerVencidos();
});

// Provider para resumen financiero
final resumenFinancieroProvider =
    FutureProvider<ResumenFinanciero>((ref) async {
  final repo = PrestamoRepository();
  return repo.obtenerResumen();
});
