import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // URL base del backend
  final String _baseUrl = 'http://localhost:3000/api';
  
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
  }

  // Método genérico para realizar solicitudes GET
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(
        path, 
        queryParameters: queryParameters,
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
      final response = await _dio.post(
        path,
        data: data,
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Método genérico para realizar solicitudes PUT
  Future<dynamic> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Método genérico para realizar solicitudes PATCH
  Future<dynamic> patch(String path, {dynamic data}) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
      );
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
  
  // Guardar token de autenticación
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }
  
  // Eliminar token (logout)
  Future<void> clearToken() async {
    await _storage.delete(key: 'token');
  }
  
  // Verificar si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    final token = await _storage.read(key: 'token');
    return token != null;
  }
} 