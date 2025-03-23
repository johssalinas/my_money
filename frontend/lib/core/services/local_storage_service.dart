import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static late SharedPreferences _prefs;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Inicializar las preferencias compartidas
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Gestión de token de autenticación
  static Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  static Future<void> removeToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  // Gestión de datos del usuario
  static Future<void> saveUserData(String userData) async {
    await _prefs.setString(_userKey, userData);
  }

  static String? getUserData() {
    return _prefs.getString(_userKey);
  }

  static Future<void> removeUserData() async {
    await _prefs.remove(_userKey);
  }

  // Limpieza de todos los datos almacenados
  static Future<void> clearAllData() async {
    await _prefs.clear();
    await _secureStorage.deleteAll();
  }
}
