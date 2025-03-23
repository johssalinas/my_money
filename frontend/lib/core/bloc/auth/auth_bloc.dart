import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_money/core/services/local_storage_service.dart';

// Eventos
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class CheckAuthStatus extends AuthEvent {}

class LogIn extends AuthEvent {
  final String email;
  final String password;

  const LogIn({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class LogOut extends AuthEvent {}

// Estados
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String userData;

  const AuthAuthenticated(this.userData);

  @override
  List<Object> get props => [userData];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LogIn>(_onLogIn);
    on<LogOut>(_onLogOut);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final token = await LocalStorageService.getToken();
      final userData = LocalStorageService.getUserData();

      if (token != null && userData != null) {
        emit(AuthAuthenticated(userData));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError('Error al comprobar estado de autenticación: $e'));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogIn(
    LogIn event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Aquí iría la lógica para autenticar al usuario con API
      // Por ahora simulamos un login exitoso
      await Future.delayed(const Duration(seconds: 1));

      await LocalStorageService.saveToken('token_simulado');
      await LocalStorageService.saveUserData(
          '{"id":"1","name":"Usuario Demo"}');

      final userData = LocalStorageService.getUserData() ?? '{}';
      emit(AuthAuthenticated(userData));
    } catch (e) {
      emit(AuthError('Error al iniciar sesión: $e'));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogOut(
    LogOut event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await LocalStorageService.removeToken();
      await LocalStorageService.removeUserData();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Error al cerrar sesión: $e'));
    }
  }
}
