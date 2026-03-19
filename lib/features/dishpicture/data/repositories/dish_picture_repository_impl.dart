import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/dish_picture.dart';
import '../../domain/repositories/dish_picture_repository.dart';
import '../datasources/dish_picture_remote_data_source.dart';

class DishPictureRepositoryImpl implements DishPictureRepository {
  final DishPictureRemoteDataSource remoteDataSource;

  DishPictureRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, DishPicture>> uploadPicture(String userId, String fileName, Uint8List fileBytes) async {
    try {
      final picture = await remoteDataSource.uploadPicture(userId, fileName, fileBytes);
      return Right(picture);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.runtimeType}'));
    }
  }
}
