import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<String, UserEntity>> register({
    required String email,
    required String password,
    required String prenom,
    required String nom,
  });

  Future<Either<String, UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<String, void>> logout();

  Future<Either<String, void>> updateProfile({
    required String userId,
    String? niveau,
    String? preference,
    String? objectif,
  });

  UserEntity? getCurrentUser();
}