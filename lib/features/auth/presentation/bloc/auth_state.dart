import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

/// Édition du profil en cours. Étend [AuthAuthenticated] pour que le routage
/// (SplashGate/MainScreen) continue d'afficher l'app avec l'utilisateur courant
/// pendant la requête.
class AuthProfileUpdateInProgress extends AuthAuthenticated {
  const AuthProfileUpdateInProgress({required super.user});
}

/// Édition du profil réussie : [user] porte les valeurs à jour (row `profiles`).
class AuthProfileUpdateSuccess extends AuthAuthenticated {
  const AuthProfileUpdateSuccess({required super.user});
}

/// Échec de l'édition du profil : on conserve l'utilisateur courant intact.
class AuthProfileUpdateFailure extends AuthAuthenticated {
  final String message;

  const AuthProfileUpdateFailure({
    required super.user,
    required this.message,
  });

  @override
  List<Object?> get props => [user, message];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}