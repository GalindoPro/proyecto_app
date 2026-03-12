import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pago.dart';
import '../repositories/pago_repository.dart';
import '../repositories/prestamo_repository.dart';

class PagosNotifier extends AsyncNotifier<List<Pago>> {
  late final _repo = PagoRepository();
  late final _prestamoRepo = PrestamoRepository();

  @override
  Future<List<Pago>> build() async {
    return _repo.obtenerTodos();
  }

  Future<void> crear(Pago pago) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.crear(pago);

      // Si el pago está asociado a un préstamo, actualizar saldo
      if (pago.prestamoId != null && pago.estaCompletado) {
        final prestamo = await _prestamoRepo.obtenerPorId(pago.prestamoId!);
        if (prestamo != null) {
          final nuevoSaldo = prestamo.saldoPendiente - pago.monto;
          await _prestamoRepo.actualizarSaldo(prestamo.id, nuevoSaldo);
        }
      }

      return _repo.obtenerTodos();
    });
  }

  Future<void> actualizar(Pago pago) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.actualizar(pago);
      return _repo.obtenerTodos();
    });
  }

  Future<void> eliminar(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.eliminar(id);
      return _repo.obtenerTodos();
    });
  }
}

final pagosProvider =
    AsyncNotifierProvider<PagosNotifier, List<Pago>>(PagosNotifier.new);

// Provider para un pago individual
final pagoProvider = FutureProvider.family<Pago?, String>((ref, id) async {
  final repo = PagoRepository();
  return repo.obtenerPorId(id);
});

// Provider para pagos de un cliente
final pagosPorClienteProvider =
    FutureProvider.family<List<Pago>, String>((ref, clienteId) async {
  final repo = PagoRepository();
  return repo.obtenerPorCliente(clienteId);
});

// Provider para pagos de un préstamo
final pagosPorPrestamoProvider =
    FutureProvider.family<List<Pago>, String>((ref, prestamoId) async {
  final repo = PagoRepository();
  return repo.obtenerPorPrestamo(prestamoId);
});

// Provider para pagos recientes
final pagosRecientesProvider = FutureProvider<List<Pago>>((ref) async {
  final repo = PagoRepository();
  return repo.obtenerRecientes();
});
