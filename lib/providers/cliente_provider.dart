import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cliente.dart';
import '../repositories/cliente_repository.dart';

class ClientesNotifier extends AsyncNotifier<List<Cliente>> {
  late final _repo = ClienteRepository();

  @override
  Future<List<Cliente>> build() async {
    return _repo.obtenerTodos();
  }

  Future<void> crear(Cliente cliente) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.crear(cliente);
      return _repo.obtenerTodos();
    });
  }

  Future<void> actualizar(Cliente cliente) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.actualizar(cliente);
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

  Future<List<Cliente>> buscar(String query) async {
    return _repo.buscar(query);
  }
}

final clientesProvider =
    AsyncNotifierProvider<ClientesNotifier, List<Cliente>>(ClientesNotifier.new);

// Provider para un cliente individual
final clienteProvider =
    FutureProvider.family<Cliente?, String>((ref, id) async {
  final repo = ClienteRepository();
  return repo.obtenerPorId(id);
});
