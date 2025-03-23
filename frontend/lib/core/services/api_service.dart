import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:my_money/core/services/local_storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final Dio _dio = Dio();

  final String _baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000/api';

  Future<void> _setupInterceptors() async {
    _dio.interceptors.clear();
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Añadir token de autenticación si existe
          final token = await LocalStorageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          // Manejar errores de autenticación
          if (error.response?.statusCode == 401) {
            // Implementar lógica de refresco de token o logout
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    await _setupInterceptors();
    return await _dio.get(
      '$_baseUrl/$endpoint',
      queryParameters: queryParameters,
    );
  }

  Future<Response> post(String endpoint, {dynamic data}) async {
    await _setupInterceptors();
    return await _dio.post('$_baseUrl/$endpoint', data: data);
  }

  Future<Response> put(String endpoint, {dynamic data}) async {
    await _setupInterceptors();
    return await _dio.put('$_baseUrl/$endpoint', data: data);
  }

  Future<Response> delete(String endpoint) async {
    await _setupInterceptors();
    return await _dio.delete('$_baseUrl/$endpoint');
  }
}
