import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_money/core/models/user_model.dart';
import 'package:my_money/features/auth/services/auth_service.dart';

// Eventos
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthLoginEvent extends AuthEvent {
  final String email;
  final String password;
  
  AuthLoginEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  
  AuthRegisterEvent({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}

class AuthCheckStatusEvent extends AuthEvent {}

class AuthLogoutEvent extends AuthEvent {}

// Estados
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthenticatedState extends AuthState {
  final User user;
  
  AuthenticatedState({required this.user});

  @override
  List<Object?> get props => [user];
}

class UnauthenticatedState extends AuthState {}

class AuthErrorState extends AuthState {
  final String error;
  
  AuthErrorState({required this.error});

  @override
  List<Object?> get props => [error];
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  
  AuthBloc({required AuthService authService})
      : _authService = authService,
        super(AuthInitialState()) {
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
      emit(AuthenticatedState(user: user));
    } catch (e) {
      emit(AuthErrorState(error: e.toString()));
    }
  }
  
  Future<void> _onRegister(AuthRegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      final user = await _authService.register(
        event.name,
        event.email,
        event.password,
      );
      emit(AuthenticatedState(user: user));
    } catch (e) {
      emit(AuthErrorState(error: e.toString()));
    }
  }
  
  Future<void> _onCheckStatus(AuthCheckStatusEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      final isAuthenticated = await _authService.isAuthenticated();
      
      if (isAuthenticated) {
        final user = await _authService.getCurrentUser();
        emit(AuthenticatedState(user: user));
      } else {
        emit(UnauthenticatedState());
      }
    } catch (e) {
      emit(UnauthenticatedState());
    }
  }
  
  Future<void> _onLogout(AuthLogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      await _authService.logout();
      emit(UnauthenticatedState());
    } catch (e) {
      emit(AuthErrorState(error: e.toString()));
    }
  }
} 