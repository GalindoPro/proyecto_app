import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../core/database/database_helper.dart';
import '../core/services/storage_service.dart';

class AuthState {
  final bool isLoading;
  final bool isLoggedIn;
  final String? userId;
  final String? userName;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isLoggedIn = false,
    this.userId,
    this.userName,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isLoggedIn,
    String? userId,
    String? userName,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  final _db = DatabaseHelper.instance;
  final _storage = StorageService.instance;

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<void> verificarSesion() async {
    state = state.copyWith(isLoading: true);
    try {
      final logueado = await _storage.estaLogueado();
      if (logueado) {
        final userId = await _storage.obtenerUserId();
        final userName = await _storage.obtenerUserName();
        state = AuthState(
          isLoggedIn: true,
          userId: userId,
          userName: userName,
        );
      } else {
        state = const AuthState(isLoggedIn: false);
      }
    } catch (e) {
      state = AuthState(error: 'Error al verificar sesión: $e');
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final hash = _hashPassword(password);
      final results = await _db.rawQuery(
        'SELECT * FROM usuarios WHERE email = ? AND password_hash = ?',
        [email.trim().toLowerCase(), hash],
      );

      if (results.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'Correo o contraseña incorrectos',
        );
        return;
      }

      final user = results.first;
      await _storage.guardarSesion(
        userId: user['id'] as String,
        nombre: user['nombre'] as String,
        email: user['email'] as String,
      );

      state = AuthState(
        isLoggedIn: true,
        userId: user['id'] as String,
        userName: user['nombre'] as String,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al iniciar sesión: $e',
      );
    }
  }

  Future<void> registro(String nombre, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Verificar si el email ya existe
      final existing = await _db.rawQuery(
        'SELECT id FROM usuarios WHERE email = ?',
        [email.trim().toLowerCase()],
      );
      if (existing.isNotEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'Este correo ya está registrado',
        );
        return;
      }

      final id = const Uuid().v4();
      final hash = _hashPassword(password);

      await _db.insert('usuarios', {
        'id': id,
        'nombre': nombre.trim(),
        'email': email.trim().toLowerCase(),
        'password_hash': hash,
        'fecha_registro': DateTime.now().toIso8601String(),
      });

      await _storage.guardarSesion(
        userId: id,
        nombre: nombre.trim(),
        email: email.trim().toLowerCase(),
      );

      state = AuthState(
        isLoggedIn: true,
        userId: id,
        userName: nombre.trim(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al registrar: $e',
      );
    }
  }

  Future<void> logout() async {
    try {
      await _storage.cerrarSesion();
      state = const AuthState(isLoggedIn: false);
    } catch (e) {
      state = state.copyWith(error: 'Error al cerrar sesión: $e');
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
