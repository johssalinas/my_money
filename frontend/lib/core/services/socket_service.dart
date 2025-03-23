import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:my_money/core/services/local_storage_service.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  late IO.Socket _socket;

  Future<void> initSocket() async {
    final token = await LocalStorageService.getToken();
    final serverUrl = dotenv.env['SOCKET_URL'] ?? 'http://localhost:3000';

    _socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .build(),
    );

    _socket.connect();

    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    _socket.onConnect((_) {
      print('Conexión establecida con el servidor de WebSockets');
    });

    _socket.onDisconnect((_) {
      print('Desconexión del servidor de WebSockets');
    });

    _socket.onError((error) {
      print('Error de conexión WebSocket: $error');
    });
  }

  void emit(String event, dynamic data) {
    if (_socket.connected) {
      _socket.emit(event, data);
    } else {
      print('Socket no conectado. No se puede emitir el evento: $event');
    }
  }

  void subscribe(String event, Function(dynamic) callback) {
    _socket.on(event, callback);
  }

  void unsubscribe(String event) {
    _socket.off(event);
  }

  void disconnect() {
    if (_socket.connected) {
      _socket.disconnect();
    }
  }

  bool get isConnected => _socket.connected;
}
