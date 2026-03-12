import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService._();

  static final StorageService instance = StorageService._();

  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyIsLoggedIn = 'is_logged_in';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // === Sesión ===

  Future<void> guardarSesion({
    required String userId,
    required String nombre,
    required String email,
  }) async {
    final p = await prefs;
    await p.setString(_keyUserId, userId);
    await p.setString(_keyUserName, nombre);
    await p.setString(_keyUserEmail, email);
    await p.setBool(_keyIsLoggedIn, true);
  }

  Future<bool> estaLogueado() async {
    final p = await prefs;
    return p.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<String?> obtenerUserId() async {
    final p = await prefs;
    return p.getString(_keyUserId);
  }

  Future<String?> obtenerUserName() async {
    final p = await prefs;
    return p.getString(_keyUserName);
  }

  Future<String?> obtenerUserEmail() async {
    final p = await prefs;
    return p.getString(_keyUserEmail);
  }

  Future<void> cerrarSesion() async {
    final p = await prefs;
    await p.remove(_keyUserId);
    await p.remove(_keyUserName);
    await p.remove(_keyUserEmail);
    await p.setBool(_keyIsLoggedIn, false);
  }
}
