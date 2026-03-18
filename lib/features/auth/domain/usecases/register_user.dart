import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUser {
  final AuthRepository repository;

  RegisterUser(this.repository);

  Future<Either<String, UserEntity>> call({
    required String email,
    required String password,
    required String prenom,
    required String nom,
  }) {
    return repository.register(
      email: email,
      password: password,
      prenom: prenom,
      nom: nom,
    );
  }
}