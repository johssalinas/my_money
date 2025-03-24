import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // URL base del backend
  final String _baseUrl = 'http://192.168.4.159:3000/api';

  ApiService() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    // Configurar interceptores para manejar tokens
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Agregar token de autenticación si existe
          final token = await _storage.read(key: 'token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Manejar errores de token expirado (401)
          if (error.response?.statusCode == 401) {
            // Aquí podríamos implementar lógica para refrescar el token
            // o redirigir al usuario a la pantalla de login
          }
          return handler.next(error);
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) {
          print('API LOG: $obj');
        },
      ),
    );
  }

  // Método genérico para realizar solicitudes GET
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      // Obtener el token guardado
      final token = await getToken();

      // Configurar las opciones de la petición
      final options = Options(
        headers: {
          'Content-Type': 'application/json',
          // Añadir el header de autorización si hay token
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      );

      print(
        'Realizando GET a $path con token: ${token != null ? 'Bearer $token' : 'No hay token'}',
      );

      // Realizar la petición incluyendo las opciones con el token
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Método genérico para realizar solicitudes POST
  Future<dynamic> post(String path, {dynamic data}) async {
    try {
      // Obtener el token guardado (excepto para login/register donde no es necesario)
      final token = await getToken();
      final bool isAuthEndpoint =
          path.contains('/auth/login') || path.contains('/auth/register');

      // Configurar las opciones de la petición
      final options = Options(
        headers: {
          'Content-Type': 'application/json',
          // Añadir el header de autorización si hay token y no es un endpoint de auth
          if (!isAuthEndpoint && token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      );

      // Realizar la petición incluyendo las opciones
      final response = await _dio.post(path, data: data, options: options);

      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Método genérico para realizar solicitudes PUT
  Future<dynamic> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Método genérico para realizar solicitudes PATCH
  Future<dynamic> patch(String path, {dynamic data}) async {
    try {
      final response = await _dio.patch(path, data: data);
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Método genérico para realizar solicitudes DELETE
  Future<dynamic> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Manejador de errores centralizado
  void _handleError(DioException error) {
    final errorMessage = _getErrorMessage(error);
    print('Error en la API: $errorMessage');
    // Aquí podríamos implementar un sistema de logging o notificaciones
  }

  // Extraer mensaje de error de las excepciones de Dio
  String _getErrorMessage(DioException error) {
    if (error.response != null) {
      if (error.response!.data is Map) {
        return error.response!.data['message'] ?? 'Error desconocido';
      }
      return error.response!.statusMessage ?? 'Error desconocido';
    }
    return error.message ?? 'Error de conexión';
  }

  // Método para obtener el token
  Future<String?> getToken() async {
    // Implementa según tu almacenamiento
    // Por ejemplo, si usas shared_preferences:
    // final prefs = await SharedPreferences.getInstance();
    // return prefs.getString('auth_token');

    // Si usas secure_storage:
    // final storage = FlutterSecureStorage();
    // return await storage.read(key: 'auth_token');

    // Temporalmente, puedes implementar un mock para pruebas:
    print('Obteniendo token guardado...');
    return _token; // Asumiendo que tienes una variable _token en la clase
  }

  // Método para guardar el token
  Future<void> saveToken(String token) async {
    print('Guardando token: $token');
    _token = token;
    // También guárdalo en tu almacenamiento persistente preferido
  }

  // Variable para almacenar temporalmente el token
  String? _token;

  // Método para limpiar el token
  Future<void> clearToken() async {
    _token = null;
    // También límpialo de tu almacenamiento persistente
  }

  // Método para verificar autenticación
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
