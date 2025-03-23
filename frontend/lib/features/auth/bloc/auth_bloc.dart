import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_money/core/models/user_model.dart';
import 'package:my_money/features/auth/services/auth_service.dart';

// Eventos
abstract class AuthEvent {}

class AuthLoginEvent extends AuthEvent {
  final String email;
  final String password;
  
  AuthLoginEvent({required this.email, required this.password});
}

class AuthRegisterEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  
  AuthRegisterEvent({required this.name, required this.email, required this.password});
}

class AuthCheckStatusEvent extends AuthEvent {}

class AuthLogoutEvent extends AuthEvent {}

// Estados
abstract class AuthState {}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthAuthenticatedState extends AuthState {
  final User user;
  
  AuthAuthenticatedState({required this.user});
}

class AuthUnauthenticatedState extends AuthState {}

class AuthErrorState extends AuthState {
  final String error;
  
  AuthErrorState({required this.error});
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  
  AuthBloc(this._authService) : super(AuthInitialState()) {
    on<AuthLoginEvent>(_onLogin);
    on<AuthRegisterEvent>(_onRegister);
    on<AuthCheckStatusEvent>(_onCheckStatus);
    on<AuthLogoutEvent>(_onLogout);
  }
  
  Future<void> _onLogin(AuthLoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    
    try {
      await _authService.login(event.email, event.password);
      final user = await _authService.getCurrentUser();
      emit(AuthAuthenticatedState(user: user));
    } catch (error) {
      emit(AuthErrorState(error: error.toString()));
    }
  }
  
  Future<void> _onRegister(AuthRegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    
    try {
      final user = await _authService.register(event.name, event.email, event.password);
      emit(AuthAuthenticatedState(user: user));
    } catch (error) {
      emit(AuthErrorState(error: error.toString()));
    }
  }
  
  Future<void> _onCheckStatus(AuthCheckStatusEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    
    try {
      final isAuthenticated = await _authService.isAuthenticated();
      
      if (isAuthenticated) {
        final user = await _authService.getCurrentUser();
        emit(AuthAuthenticatedState(user: user));
      } else {
        emit(AuthUnauthenticatedState());
      }
    } catch (error) {
      emit(AuthUnauthenticatedState());
    }
  }
  
  Future<void> _onLogout(AuthLogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    
    try {
      await _authService.logout();
      emit(AuthUnauthenticatedState());
    } catch (error) {
      emit(AuthErrorState(error: error.toString()));
    }
  }
} 