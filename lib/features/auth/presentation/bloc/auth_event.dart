import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginWithEmailPasswordEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginWithEmailPasswordEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class RegisterWithEmailPasswordEvent extends AuthEvent {
  final String email;
  final String password;
  final String prenom;
  final String nom;

  const RegisterWithEmailPasswordEvent({
    required this.email,
    required this.password,
    required this.prenom,
    required this.nom,
  });

  @override
  List<Object?> get props => [email, password, prenom, nom];
}

class LoginWithGoogleEvent extends AuthEvent {
  const LoginWithGoogleEvent();
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}