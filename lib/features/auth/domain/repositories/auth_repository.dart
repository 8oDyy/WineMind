import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String prenom,
    required String nom,
  });

  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, void>> updateProfile({
    required String userId,
    String? niveau,
    String? preference,
    String? objectif,
  });

  Future<Either<Failure, void>> deleteAccount({required String userId});

  UserEntity? getCurrentUser();
}