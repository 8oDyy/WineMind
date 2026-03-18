import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/register_user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser loginUser;
  final RegisterUser registerUser;
  final LogoutUser logoutUser;
  final AuthRepository authRepository;

  AuthBloc({
    required this.loginUser,
    required this.registerUser,
    required this.logoutUser,
    required this.authRepository,
  }) : super(const AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginWithEmailPasswordEvent>(_onLoginWithEmailPassword);
    on<RegisterWithEmailPasswordEvent>(_onRegisterWithEmailPassword);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    final user = authRepository.getCurrentUser();
    if (user != null) {
      emit(AuthAuthenticated(user: user));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginWithEmailPassword(
    LoginWithEmailPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await loginUser(LoginParams(
      email: event.email,
      password: event.password,
    ));

    result.fold(
      (failure) => emit(AuthError(message: _mapFailure(failure))),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onRegisterWithEmailPassword(
    RegisterWithEmailPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await registerUser(RegisterParams(
      email: event.email,
      password: event.password,
      prenom: event.prenom,
      nom: event.nom,
    ));

    result.fold(
      (failure) => emit(AuthError(message: _mapFailure(failure))),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await logoutUser(NoParams());

    result.fold(
      (failure) => emit(AuthError(message: _mapFailure(failure))),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  String _mapFailure(Failure failure) {
    if (failure is AuthFailure) {
      final e = failure.message.toLowerCase();
      if (e.contains('invalid') || e.contains('credentials')) {
        return 'Email ou mot de passe incorrect.';
      } else if (e.contains('email not confirmed')) {
        return 'Confirmez votre email avant de vous connecter.';
      } else if (e.contains('too many')) {
        return 'Trop de tentatives. Réessayez dans quelques minutes.';
      }
      return failure.message;
    }
    return 'Une erreur est survenue.';
  }
}