import 'package:my_money/core/api/api_service.dart';
import 'package:my_money/core/models/user_model.dart';

class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  // Iniciar sesión con email y contraseña
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      // Añade logs para depuración
      print('Respuesta de login: $response');

      // Guardar el token de acceso
      if (response['accessToken'] != null) {
        await _apiService.saveToken(response['accessToken']);
      }

      return response;
    } catch (error) {
      print('Error detallado de login: $error');
      rethrow;
    }
  }

  // Registrar un nuevo usuario
  Future<User> register(String name, String email, String password) async {
    try {
      final response = await _apiService.post(
        '/auth/register',
        data: {'name': name, 'email': email, 'password': password},
      );

      return User.fromJson(response);
    } catch (error) {
      rethrow;
    }
  }

  // Obtener el perfil del usuario actual
  Future<User> getCurrentUser() async {
    try {
      final response = await _apiService.get('/auth/profile');
      print('Respuesta del perfil: $response'); // Log para depuración

      // Si el backend no incluye el name en /profile, podemos usar
      // el email como nombre temporal
      if (response['name'] == null) {
        response['name'] = response['email']?.split('@')[0] ?? 'Usuario';
      }

      return User.fromJson(response);
    } catch (error) {
      print('Error al obtener perfil: $error');
      rethrow;
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    await _apiService.clearToken();
  }

  // Verificar si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    return _apiService.isAuthenticated();
  }
}
