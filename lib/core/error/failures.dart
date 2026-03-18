import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure();
}

class ServerFailure extends Failure {
  final String message;

  const ServerFailure([this.message = 'Erreur serveur']);

  @override
  List<Object?> get props => [message];
}

class CacheFailure extends Failure {
  final String message;

  const CacheFailure([this.message = 'Erreur de cache']);

  @override
  List<Object?> get props => [message];
}

class AuthFailure extends Failure {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}
