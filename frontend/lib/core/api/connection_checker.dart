import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';

class ConnectionChecker {
  static Future<bool> verificarConexion(BuildContext context) async {
    try {
      // Intenta hacer una petición simple al backend
      final response = await ApiService.dio.get('${ApiService.baseUrl}/health');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Conectado al backend correctamente!'),
            backgroundColor: Colors.green,
          ),
        );
        return true;
      }
      return false;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }
}
